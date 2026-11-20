import { store } from './store.js';

export interface ActiveBillingSession {
  sessionId: string;
  userId: string;
  astrologerId: string;
  ratePerMinute: number;
  elapsedSeconds: number;
  totalDeducted: number;
  timer?: NodeJS.Timeout;
}

export class BillingEngine {
  private activeSessions: Map<string, ActiveBillingSession> = new Map();
  private onTickCallback?: (session: ActiveBillingSession, walletBalance: number) => void;
  private onLowBalanceCallback?: (session: ActiveBillingSession, reason: string) => void;

  setCallbacks(
    onTick: (session: ActiveBillingSession, walletBalance: number) => void,
    onLowBalance: (session: ActiveBillingSession, reason: string) => void
  ) {
    this.onTickCallback = onTick;
    this.onLowBalanceCallback = onLowBalance;
  }

  async startBillingSession(sessionId: string, userId: string, astrologerId: string, ratePerMinute: number) {
    // End any existing session for safety
    this.stopBillingSession(sessionId);

    const active: ActiveBillingSession = {
      sessionId,
      userId,
      astrologerId,
      ratePerMinute,
      elapsedSeconds: 0,
      totalDeducted: 0,
    };

    // First minute debit check
    const deductRes = await store.deductConsultationMinute(userId, sessionId, ratePerMinute);
    if (!deductRes.success) {
      if (this.onLowBalanceCallback) {
        this.onLowBalanceCallback(active, 'insufficient_balance');
      }
      return false;
    }

    active.totalDeducted += ratePerMinute;
    active.elapsedSeconds += 60;

    // Heartbeat every 60 seconds
    active.timer = setInterval(async () => {
      active.elapsedSeconds += 60;
      const res = await store.deductConsultationMinute(userId, sessionId, ratePerMinute);

      if (!res.success) {
        this.stopBillingSession(sessionId);
        if (this.onLowBalanceCallback) {
          this.onLowBalanceCallback(active, 'insufficient_balance');
        }
      } else {
        active.totalDeducted += ratePerMinute;
        await store.updateConsultation(sessionId, {
          duration_seconds: active.elapsedSeconds,
          total_deducted: active.totalDeducted,
        });

        if (this.onTickCallback) {
          this.onTickCallback(active, res.newBalance);
        }
      }
    }, 60000);

    this.activeSessions.set(sessionId, active);
    return true;
  }

  stopBillingSession(sessionId: string): ActiveBillingSession | null {
    const session = this.activeSessions.get(sessionId);
    if (session) {
      if (session.timer) {
        clearInterval(session.timer);
      }
      this.activeSessions.delete(sessionId);
      return session;
    }
    return null;
  }

  getSession(sessionId: string): ActiveBillingSession | undefined {
    return this.activeSessions.get(sessionId);
  }
}

export const billingEngine = new BillingEngine();
