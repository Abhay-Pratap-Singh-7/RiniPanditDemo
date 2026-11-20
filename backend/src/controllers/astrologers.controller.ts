import { Request, Response } from 'express';
import { store } from '../services/store.js';

export async function getAstrologers(req: Request, res: Response) {
  try {
    const specialty = req.query.specialty as string | undefined;
    const astrologers = await store.listAstrologers(specialty);
    res.json({ success: true, data: astrologers });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function getAstrologerById(req: Request, res: Response) {
  try {
    const astro = await store.getAstrologer(req.params.id as string);
    if (!astro) {
      return res.status(404).json({ success: false, message: 'Astrologer not found' });
    }
    res.json({ success: true, data: astro });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}
