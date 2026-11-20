import { Request, Response } from 'express';
import { store } from '../services/store.js';

export async function getPanditProfile(req: Request, res: Response) {
  try {
    const id = (req.query.id as string) || 'b0000000-0000-0000-0000-000000000001';
    const astro = await store.getAstrologer(id);
    if (!astro) {
      return res.status(404).json({ success: false, message: 'Pandit not found' });
    }
    const earnings = await store.getAstrologerEarnings(id);
    res.json({
      success: true,
      data: {
        ...astro,
        earnings,
      },
    });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function updatePanditStatus(req: Request, res: Response) {
  try {
    const {
      id = 'b0000000-0000-0000-0000-000000000001',
      isOnline,
      isBusy,
      ratePerMinute,
      bio,
      specialties,
      experienceYears,
      displayName,
    } = req.body;
    const updates: any = {};
    if (isOnline !== undefined) updates.is_online = isOnline;
    if (isBusy !== undefined) updates.is_busy = isBusy;
    if (ratePerMinute !== undefined) updates.rate_per_minute = Number(ratePerMinute);
    if (bio !== undefined) updates.bio = bio;
    if (specialties !== undefined) updates.specialties = Array.isArray(specialties) ? specialties : [specialties];
    if (experienceYears !== undefined) updates.experience_years = Number(experienceYears);
    if (displayName !== undefined) updates.display_name = displayName;

    const updated = await store.updateAstrologer(id, updates);
    res.json({ success: true, data: updated });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
}

export async function getPanditEarnings(req: Request, res: Response) {
  try {
    const id = (req.params.id as string) || 'b0000000-0000-0000-0000-000000000001';
    const earnings = await store.getAstrologerEarnings(id);
    res.json({ success: true, data: earnings });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function getPanditSessions(req: Request, res: Response) {
  try {
    const id = (req.params.id as string) || 'b0000000-0000-0000-0000-000000000001';
    const sessions = await store.getConsultationsByAstrologer(id);
    res.json({ success: true, data: sessions });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function panditLogin(req: Request, res: Response) {
  try {
    const { id = 'b0000000-0000-0000-0000-000000000001' } = req.body;
    const astro = await store.getAstrologer(id);
    if (!astro) {
      return res.status(404).json({ success: false, message: 'Pandit not found' });
    }
    res.json({
      success: true,
      data: astro,
      role: 'pandit',
      token: `demo_pandit_token_${astro.id}`,
    });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}
