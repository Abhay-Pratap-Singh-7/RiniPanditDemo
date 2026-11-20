import { Request, Response } from 'express';
import { store } from '../services/store.js';
import { AuthRequest } from '../middleware/auth.middleware.js';

export async function getUserProfile(req: AuthRequest, res: Response) {
  try {
    const userId = req.user?.id || (req.query.userId as string);
    if (!userId) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }
    let profile = await store.getProfile(userId);
    if (!profile) {
      profile = {
        id: userId,
        phone: req.user?.phone || `+91${Date.now().toString().slice(-10)}`,
        full_name: req.user?.user_metadata?.full_name || 'Acharya / Devotee',
        gender: 'male',
        dob: '1995-01-01',
        tob: '10:00',
        pob_city: 'Delhi',
        pob_country: 'India',
        wallet_balance: req.user?.user_metadata?.role === 'pandit' ? 0.0 : 100.0,
        avatar_url: '',
      };
      await store.updateProfile(userId, profile);
    }
    res.json({ success: true, data: profile });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function updateUserProfile(req: AuthRequest, res: Response) {
  try {
    const userId = req.user?.id || (req.body.userId as string);
    if (!userId) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }
    const updated = await store.updateProfile(userId, req.body);
    res.json({ success: true, data: updated });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}
