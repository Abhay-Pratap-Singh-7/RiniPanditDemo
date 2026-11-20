import { Request, Response } from 'express';
import { store } from '../services/store.js';

export async function getConsultationHistory(req: Request, res: Response) {
  try {
    const userId = (req.query.userId as string) || (req as any).user?.id;
    if (!userId) {
      return res.status(400).json({ success: false, message: 'User ID is required' });
    }
    const history = await store.getConsultationsByUser(userId);
    res.json({ success: true, data: history });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function getConsultationMessages(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const messages = await store.getMessages(id as string);
    res.json({ success: true, data: messages });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}
