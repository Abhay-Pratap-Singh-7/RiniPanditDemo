import { Request, Response } from 'express';
import { store } from '../services/store.js';

export async function getPanditProfile(req: Request, res: Response) {
  try {
    const id = (req.query.id as string) || (req as any).user?.id;
    if (!id) {
      return res.status(400).json({ success: false, message: 'Astrologer ID is required' });
    }
    let astro = await store.getAstrologer(id);
    if (!astro) {
      const user = (req as any).user;
      if (user && user.role === 'pandit') {
        const profile = await store.getProfile(id);
        astro = await store.updateAstrologer(id, {
          display_name: user.user_metadata?.full_name || profile?.full_name || 'Acharya',
          specialties: ['Vedic', 'Kundli'],
          languages: ['Hindi', 'English'],
          experience_years: 5,
          rate_per_minute: 25.0,
          bio: '',
        });
      }
    }
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
    const userId = (req as any).user?.id;
    const {
      id = userId,
      isOnline,
      isBusy,
      ratePerMinute,
      bio,
      specialties,
      experienceYears,
      displayName,
    } = req.body;

    const targetId = id || userId;
    if (!targetId) {
      return res.status(400).json({ success: false, message: 'Astrologer ID is required' });
    }

    const updates: any = {};
    if (isOnline !== undefined) updates.is_online = isOnline;
    if (isBusy !== undefined) updates.is_busy = isBusy;
    if (ratePerMinute !== undefined) updates.rate_per_minute = Number(ratePerMinute);
    if (bio !== undefined) updates.bio = bio;
    if (specialties !== undefined) updates.specialties = Array.isArray(specialties) ? specialties : [specialties];
    if (experienceYears !== undefined) updates.experience_years = Number(experienceYears);
    if (displayName !== undefined) updates.display_name = displayName;

    const updated = await store.updateAstrologer(targetId, updates);
    if (!updated) {
      return res.status(500).json({ success: false, message: 'Failed to update pandit status' });
    }
    res.json({ success: true, data: updated });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
}

export async function getPanditEarnings(req: Request, res: Response) {
  try {
    const id = (req.params.id as string) || (req as any).user?.id;
    if (!id) {
      return res.status(400).json({ success: false, message: 'Astrologer ID is required' });
    }
    const earnings = await store.getAstrologerEarnings(id);
    res.json({ success: true, data: earnings });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function getPanditSessions(req: Request, res: Response) {
  try {
    const id = (req.params.id as string) || (req as any).user?.id;
    if (!id) {
      return res.status(400).json({ success: false, message: 'Astrologer ID is required' });
    }
    const sessions = await store.getConsultationsByAstrologer(id);
    res.json({ success: true, data: sessions });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function panditLogin(req: Request, res: Response) {
  try {
    const { id } = req.body;
    if (!id) {
      return res.status(400).json({ success: false, message: 'Astrologer ID is required' });
    }
    const astro = await store.getAstrologer(id);
    if (!astro) {
      return res.status(404).json({ success: false, message: 'Pandit not found' });
    }
    res.json({
      success: true,
      data: astro,
      role: 'pandit',
    });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}