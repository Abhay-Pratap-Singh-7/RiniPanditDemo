import { Request, Response } from 'express';
import { store } from '../services/store.js';
import { AuthRequest } from '../middleware/auth.middleware.js';

export async function getUserProfile(req: AuthRequest, res: Response) {
  try {
    const userId = req.user?.id || (req.query.userId as string) || 'a0000000-0000-0000-0000-000000000001';
    const profile = await store.getProfile(userId);
    if (!profile) {
      return res.status(404).json({ success: false, message: 'Profile not found' });
    }
    res.json({ success: true, data: profile });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function updateUserProfile(req: AuthRequest, res: Response) {
  try {
    const userId = req.user?.id || (req.body.userId as string) || 'a0000000-0000-0000-0000-000000000001';
    const updated = await store.updateProfile(userId, req.body);
    res.json({ success: true, data: updated });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function mockLogin(req: Request, res: Response) {
  try {
    const { phone } = req.body;
    let profile = await store.getProfile(phone || '+919876543210');
    if (!profile) {
      profile = await store.updateProfile(`user_${Date.now()}`, {
        phone: phone || '+919876543210',
        full_name: 'Devotee / Client',
        gender: 'male',
        dob: '1996-01-01',
        tob: '10:00',
        pob_city: 'Delhi',
        pob_country: 'India',
        wallet_balance: 300.0,
        avatar_url: '',
      });
    }
    res.json({ success: true, data: profile, token: `demo_jwt_token_${profile.id}` });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}
