import { WebSocketServer, WebSocket } from 'ws';
import { IncomingMessage } from 'http';
import { store } from '../services/store.js';
import { billingEngine, ActiveBillingSession } from '../services/billing.js';

interface AuthenticatedSocket extends WebSocket {
  userId?: string;
  astrologerId?: string;
  isAlive?: boolean;
}

export function setupConsultationSockets(wss: WebSocketServer) {
  const userSocketMap = new Map<string, AuthenticatedSocket>();

  // Setup callbacks for real-time per-minute billing
  billingEngine.setCallbacks(
    (session: ActiveBillingSession, clientBalance: number, panditBalance?: number) => {
      broadcastToUser(session.userId, {
        event: 'billing:tick',
        data: {
          sessionId: session.sessionId,
          elapsedMinutes: Math.floor(session.elapsedSeconds / 60),
          totalDeducted: session.totalDeducted,
          walletBalance: clientBalance,
        },
      });

      const panditPayload = {
        event: 'billing:tick',
        data: {
          sessionId: session.sessionId,
          elapsedMinutes: Math.floor(session.elapsedSeconds / 60),
          earnedAmount: session.totalDeducted,
          walletBalance: panditBalance,
        },
      };

      broadcastToUser(session.astrologerId, panditPayload);
      store.getAstrologer(session.astrologerId).then((astro) => {
        if (astro && (astro as any).profile_id) {
          broadcastToUser((astro as any).profile_id, panditPayload);
        }
      });
    },
    async (session: ActiveBillingSession, reason: string) => {
      await store.updateConsultation(session.sessionId, {
        status: 'insufficient_balance',
        ended_at: new Date().toISOString(),
      });
      await store.setAstrologerBusy(session.astrologerId, false);

      const payload = {
        event: 'consultation:ended',
        data: {
          sessionId: session.sessionId,
          reason,
          message: 'Session ended automatically due to insufficient wallet balance.',
        },
      };

      broadcastToUser(session.userId, payload);
      broadcastToUser(session.astrologerId, payload);
    }
  );

  function broadcastToUser(targetId: string, message: any): boolean {
    if (!targetId) return false;

    // 1. Direct map lookup
    const ws = userSocketMap.get(targetId);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
      return true;
    }

    // 2. Scan connected sockets for matching user/astro ID
    for (const [id, socket] of userSocketMap.entries()) {
      if (
        (id === targetId || socket.userId === targetId || socket.astrologerId === targetId) &&
        socket.readyState === WebSocket.OPEN
      ) {
        socket.send(JSON.stringify(message));
        return true;
      }
    }

    console.log(`[WebSocket] Recipient not currently connected: ${targetId}`);
    return false;
  }

  wss.on('connection', (ws: AuthenticatedSocket, req: IncomingMessage) => {
    ws.isAlive = true;
    ws.on('pong', () => (ws.isAlive = true));

    // Extract query params e.g. /ws/consultation?userId=...
    const url = new URL(req.url || '', 'http://localhost');
    const userId = url.searchParams.get('userId') || url.searchParams.get('user_id');
    if (!userId) {
      ws.close(1008, 'User ID required');
      return;
    }

    ws.userId = userId;
    userSocketMap.set(userId, ws);

    console.log(`[WebSocket] Client connected: ${userId}`);

    // Preload astrologer & profile associations for reliable routing
    store.getAstrologer(userId).then((astro) => {
      if (astro) {
        ws.astrologerId = astro.id;
        userSocketMap.set(astro.id, ws);
        if ((astro as any).profile_id) {
          userSocketMap.set((astro as any).profile_id, ws);
        }
        console.log(`[WebSocket] Associated astrologer ID ${astro.id} with socket for ${userId}`);
      }
    });

    store.getProfile(userId).then((prof) => {
      if (prof) {
        userSocketMap.set(prof.id, ws);
        if (prof.phone) userSocketMap.set(prof.phone, ws);
      }
    });

    ws.on('message', async (rawData) => {
      try {
        const payload = JSON.parse(rawData.toString());
        const { event, data } = payload;

        switch (event) {
          case 'consultation:initiate': {
            const { astrologerId } = data;
            let astro = await store.getAstrologer(astrologerId);
            if (!astro) {
              const all = await store.listAstrologers();
              astro = all.find((a) => a.id === astrologerId || (a as any).profile_id === astrologerId) || null;
            }

            if (!astro) {
              ws.send(JSON.stringify({ event: 'error', data: { message: 'Astrologer not found' } }));
              return;
            }

            let user = await store.getProfile(userId);
            if (!user) {
              user = {
                id: userId,
                phone: '',
                full_name: 'Devotee / Client',
                gender: 'male',
                dob: '',
                tob: '',
                pob_city: '',
                pob_country: 'India',
                wallet_balance: 100.0,
                avatar_url: '',
              };
              await store.updateProfile(userId, user);
            }

            // Ensure sufficient initial testing balance
            if (user.wallet_balance < astro.rate_per_minute) {
              user.wallet_balance = 500.0;
              await store.updateProfile(userId, { wallet_balance: user.wallet_balance });
            }

            // Create consultation session record
            const consultation = await store.createConsultation({
              user_id: userId,
              astrologer_id: astro.id,
              type: 'chat',
              status: 'active',
              rate_per_minute: astro.rate_per_minute,
              duration_seconds: 0,
              total_deducted: 0,
              started_at: new Date().toISOString(),
            });

            await store.setAstrologerBusy(astro.id, true);

            // Send confirmation to client that connection is established
            const startedPayload = {
              event: 'consultation:started',
              data: {
                session: consultation,
                astrologer: astro,
                user: user,
                message: `Connection established with ${astro.display_name}`,
              },
            };
            ws.send(JSON.stringify(startedPayload));

            // Forward incoming request to pandit
            const incomingPayload = {
              event: 'consultation:incoming_request',
              data: {
                session: consultation,
                user: user,
                astrologer: astro,
              },
            };

            const delivered =
              broadcastToUser(astro.id, incomingPayload) ||
              ((astro as any).profile_id && broadcastToUser((astro as any).profile_id, incomingPayload));

            if (delivered) {
              console.log(`[WebSocket] Live consultation request delivered to pandit ${astro.display_name}`);
            } else {
              console.log(`[WebSocket] Pandit ${astro.display_name} (${astro.id}) is offline. Session waiting.`);
            }
            break;
          }

          case 'consultation:accept': {
            const { sessionId } = data;
            const consultation = await store.getConsultation(sessionId);
            if (consultation) {
              await store.updateConsultation(sessionId, { status: 'active' });
              const astro = await store.getAstrologer(consultation.astrologer_id);
              const user = await store.getProfile(consultation.user_id);
              const startedPayload = {
                event: 'consultation:started',
                data: {
                  session: consultation,
                  astrologer: astro,
                  user: user,
                },
              };
              broadcastToUser(consultation.user_id, startedPayload);
              broadcastToUser(consultation.astrologer_id, startedPayload);
            }
            break;
          }

          case 'chat:send': {
            const { sessionId, content } = data;
            const consultation = await store.getConsultation(sessionId);
            if (!consultation) {
              ws.send(JSON.stringify({ event: 'error', data: { message: 'Consultation session not found' } }));
              return;
            }

            // Save message to store and database
            const savedMsg = await store.addMessage({
              consultation_id: sessionId,
              sender_id: userId,
              content,
              is_read: true,
            });

            // Echo back to sender
            ws.send(
              JSON.stringify({
                event: 'chat:message',
                data: savedMsg,
              })
            );

            // Send directly to the other participant
            const isClient = userId === consultation.user_id;
            const targetRecipientId = isClient ? consultation.astrologer_id : consultation.user_id;

            let delivered = broadcastToUser(targetRecipientId, {
              event: 'chat:message',
              data: savedMsg,
            });

            if (isClient && !delivered) {
              const astro = await store.getAstrologer(consultation.astrologer_id);
              if (astro && (astro as any).profile_id) {
                delivered = broadcastToUser((astro as any).profile_id, {
                  event: 'chat:message',
                  data: savedMsg,
                });
              }
            }

            if (delivered) {
              console.log(`[WebSocket] Chat message forwarded successfully from ${userId} to ${targetRecipientId}`);
            }

            // Start timer and billing on first message from user
            if (isClient && !billingEngine.isSessionActive(sessionId)) {
              console.log(`[Billing] First message from client ${userId}. Transferring first minute payment to pandit...`);
              await billingEngine.startBillingSession(
                consultation.id,
                consultation.user_id,
                consultation.astrologer_id,
                consultation.rate_per_minute
              );

              const timerStartedPayload = {
                event: 'consultation:timer_started',
                data: {
                  sessionId: consultation.id,
                  startedAt: new Date().toISOString(),
                  ratePerMinute: consultation.rate_per_minute,
                },
              };
              ws.send(JSON.stringify(timerStartedPayload));
              broadcastToUser(consultation.astrologer_id, timerStartedPayload);
              const astro = await store.getAstrologer(consultation.astrologer_id);
              if (astro && (astro as any).profile_id) {
                broadcastToUser((astro as any).profile_id, timerStartedPayload);
              }
            }
            break;
          }

          case 'consultation:end': {
            const { sessionId } = data;
            const session = billingEngine.stopBillingSession(sessionId);
            const consultation = await store.getConsultation(sessionId);

            if (consultation) {
              const updated = await store.updateConsultation(sessionId, {
                status: 'completed',
                ended_at: new Date().toISOString(),
                duration_seconds: session?.elapsedSeconds || consultation.duration_seconds,
                total_deducted: session?.totalDeducted || consultation.total_deducted,
              });

              await store.setAstrologerBusy(consultation.astrologer_id, false);

              const summaryPayload = {
                event: 'consultation:summary',
                data: {
                  sessionId,
                  totalMinutes: Math.ceil((updated?.duration_seconds || 60) / 60),
                  totalDeducted: updated?.total_deducted || 0,
                  endedAt: updated?.ended_at,
                },
              };

              ws.send(JSON.stringify(summaryPayload));
              broadcastToUser(consultation.astrologer_id, summaryPayload);
            }
            break;
          }

          case 'ping': {
            ws.send(JSON.stringify({ event: 'pong' }));
            break;
          }

          default:
            console.log(`[WebSocket] Unknown event: ${event}`);
        }
      } catch (err: any) {
        console.error('[WebSocket] Error processing message:', err.message);
      }
    });

    ws.on('close', () => {
      console.log(`[WebSocket] Client disconnected: ${userId}`);
      userSocketMap.delete(userId);
      if (ws.astrologerId) userSocketMap.delete(ws.astrologerId);
    });
  });

  // Ping keepalive every 30s
  const pingInterval = setInterval(() => {
    wss.clients.forEach((client: any) => {
      if (!client.isAlive) return client.terminate();
      client.isAlive = false;
      client.ping();
    });
  }, 30000);

  wss.on('close', () => clearInterval(pingInterval));
}
