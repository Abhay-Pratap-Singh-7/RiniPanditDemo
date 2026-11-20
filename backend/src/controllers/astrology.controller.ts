import { Request, Response } from 'express';
import { calculateKundli, getDailyHoroscope, getAllDailyHoroscopes } from '../services/astrology.js';

export async function getHoroscope(req: Request, res: Response) {
  try {
    const sign = (req.query.sign as string) || 'all';
    if (sign.toLowerCase() === 'all') {
      const allHoroscopes = getAllDailyHoroscopes();
      return res.json({ success: true, data: allHoroscopes });
    }
    const horoscope = getDailyHoroscope(sign);
    res.json({ success: true, sign, data: horoscope });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function getAllHoroscopes(req: Request, res: Response) {
  try {
    const all = getAllDailyHoroscopes();
    res.json({ success: true, data: all });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function generateKundli(req: Request, res: Response) {
  try {
    const { name = '', gender = '', dob = '', tob = '', pobCity = '' } = req.body;
    if (!dob) {
      return res.status(400).json({ success: false, message: 'Date of birth (dob) is required' });
    }
    const kundli = calculateKundli({ name, gender, dob, tob, pobCity });
    res.json({ success: true, data: kundli });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}
