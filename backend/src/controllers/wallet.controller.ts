import { Response } from 'express';
import { store } from '../services/store.js';
import { AuthRequest } from '../middleware/auth.middleware.js';

export async function getWalletBalance(req: AuthRequest, res: Response) {
  try {
    const userId = req.user?.id || (req.query.userId as string);
    if (!userId) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }
    const profile = await store.getProfile(userId);
    res.json({
      success: true,
      data: {
        userId,
        walletBalance: profile ? profile.wallet_balance : 0,
      },
    });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function rechargeWallet(req: AuthRequest, res: Response) {
  try {
    const userId = req.user?.id || req.body.userId;
    if (!userId) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }
    const { amount } = req.body;
    if (!amount || Number(amount) <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid recharge amount' });
    }

    const result = await store.rechargeWallet(userId, Number(amount));
    res.json({
      success: true,
      data: {
        newBalance: result.profile.wallet_balance,
        transaction: result.tx,
      },
    });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function getTransactions(req: AuthRequest, res: Response) {
  try {
    const userId = req.user?.id || (req.query.userId as string);
    if (!userId) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }
    const transactions = await store.getTransactions(userId);
    res.json({ success: true, data: transactions });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}
