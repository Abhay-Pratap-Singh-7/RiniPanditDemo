import { WebSocketServer, WebSocket } from 'ws';
import { IncomingMessage } from 'http';
import { store } from '../services/store.js';
import { billingEngine, ActiveBillingSession } from '../services/billing.js';

interface AuthenticatedSocket extends WebSocket {
  userId?: string;
  isAlive?: boolean;
}

export function setupConsultationSockets(wss: WebSocketServer) {
  const userSocketMap = new Map<string, AuthenticatedSocket>();

  // Setup callbacks for real-time per-minute billing
  billingEngine.setCallbacks(
    (session: ActiveBillingSession, walletBalance: number) => {
      broadcastToUser(session.userId, {
        event: 'billing:tick',
        data: {
          sessionId: session.sessionId,
          elapsedMinutes: Math.floor(session.elapsedSeconds / 60),
          totalDeducted: session.totalDeducted,
          walletBalance,
        },
      });

      broadcastToUser(session.astrologerId, {
        event: 'billing:tick',
        data: {
          sessionId: session.sessionId,
          elapsedMinutes: Math.floor(session.elapsedSeconds / 60),
          earnedAmount: session.totalDeducted,
        },
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

  function broadcastToUser(userId: string, message: any) {
    const ws = userSocketMap.get(userId);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(message));
    }
  }

  wss.on('connection', (ws: AuthenticatedSocket, req: IncomingMessage) => {
    ws.isAlive = true;
    ws.on('pong', () => (ws.isAlive = true));

    // Extract query params e.g. ws://localhost:5001/ws/consultation?userId=...
    const url = new URL(req.url || '', `http://${req.headers.host}`);
    const userId = url.searchParams.get('userId') || 'a0000000-0000-0000-0000-000000000001';
    ws.userId = userId;
    userSocketMap.set(userId, ws);

    console.log(`[WebSocket] Client connected: ${userId}`);

    ws.on('message', async (rawData) => {
      try {
        const payload = JSON.parse(rawData.toString());
        const { event, data } = payload;

        switch (event) {
          case 'consultation:initiate': {
            const { astrologerId } = data;
            const astro = await store.getAstrologer(astrologerId);
            const user = await store.getProfile(userId);

            if (!astro) {
              ws.send(JSON.stringify({ event: 'error', data: { message: 'Astrologer not found' } }));
              return;
            }

            if (!user || user.wallet_balance < astro.rate_per_minute) {
              ws.send(
                JSON.stringify({
                  event: 'error',
                  data: {
                    code: 'LOW_BALANCE',
                    message: `Minimum wallet balance of ₹${astro.rate_per_minute} required to start consultation.`,
                  },
                })
              );
              return;
            }

            // Create consultation record
            const consultation = await store.createConsultation({
              user_id: userId,
              astrologer_id: astrologerId,
              type: 'chat',
              status: 'active',
              rate_per_minute: astro.rate_per_minute,
              duration_seconds: 0,
              total_deducted: 0,
              started_at: new Date().toISOString(),
            });

            await store.setAstrologerBusy(astrologerId, true);

            // Start per-minute billing engine
            await billingEngine.startBillingSession(
              consultation.id,
              userId,
              astrologerId,
              astro.rate_per_minute
            );

            // Send confirmation to user
            const responsePayload = {
              event: 'consultation:started',
              data: {
                session: consultation,
                astrologer: astro,
                message: `Consultation started with ${astro.display_name}`,
              },
            };
            ws.send(JSON.stringify(responsePayload));

            // Demo Helper: Send a warm welcome message from the astrologer
            setTimeout(async () => {
              const welcomeMsg = await store.addMessage({
                consultation_id: consultation.id,
                sender_id: astrologerId,
                content: `Namaste ${user.full_name || 'ji'}! 🙏 I have opened your birth chart. Please tell me your question or concern.`,
                is_read: true,
              });

              ws.send(
                JSON.stringify({
                  event: 'chat:message',
                  data: welcomeMsg,
                })
              );
            }, 1000);
            break;
          }

          case 'chat:send': {
            const { sessionId, content } = data;
            const consultation = await store.getConsultation(sessionId);
            if (!consultation || consultation.status !== 'active') {
              ws.send(JSON.stringify({ event: 'error', data: { message: 'Session is not active' } }));
              return;
            }

            // Save user message
            const savedMsg = await store.addMessage({
              consultation_id: sessionId,
              sender_id: userId,
              content,
              is_read: true,
            });

            // Echo back to user
            ws.send(
              JSON.stringify({
                event: 'chat:message',
                data: savedMsg,
              })
            );

            // Send to astrologer if connected
            broadcastToUser(consultation.astrologer_id, {
              event: 'chat:message',
              data: savedMsg,
            });

            // Demo Auto-Reply Simulator: If testing as single user, simulate astrologer guidance
            setTimeout(async () => {
              const replies = [
                'I see a strong Jupiter transit influencing your 10th house. This signifies auspicious career movements.',
                'Your current Mahadasha suggests focusing on patience. Chanting Gayatri mantra will bring mental clarity.',
                'The alignment shows good financial prospects. Wear a silver ring or consult for gemstone suitability.',
                'Yes, I recommend performing a simple Shani remedy on Saturday evening to ease obstacles.',
              ];
              const randomReply = replies[Math.floor(Math.random() * replies.length)];

              const astroMsg = await store.addMessage({
                consultation_id: sessionId,
                sender_id: consultation.astrologer_id,
                content: randomReply,
                is_read: true,
              });

              ws.send(
                JSON.stringify({
                  event: 'chat:message',
                  data: astroMsg,
                })
              );
            }, 1500);

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
        console.error('[WebSocket] Error handling message:', err.message);
      }
    });

    ws.on('close', () => {
      console.log(`[WebSocket] Client disconnected: ${userId}`);
      userSocketMap.delete(userId);
    });
  });

  // Keep-alive heartbeat interval
  const pingInterval = setInterval(() => {
    wss.clients.forEach((client: any) => {
      if (!client.isAlive) return client.terminate();
      client.isAlive = false;
      client.ping();
    });
  }, 30000);

  wss.on('close', () => clearInterval(pingInterval));
}
