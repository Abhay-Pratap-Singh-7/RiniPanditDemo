import { Request, Response } from 'express';
import { calculateKundli, getDailyHoroscope } from '../services/astrology.js';

export async function getHoroscope(req: Request, res: Response) {
  try {
    const sign = (req.query.sign as string) || 'aries';
    const horoscope = getDailyHoroscope(sign);
    res.json({ success: true, sign, data: horoscope });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}

export async function generateKundli(req: Request, res: Response) {
  try {
    const { name = 'Rahul Sharma', gender = 'male', dob = '1995-08-15', tob = '07:30', pobCity = 'New Delhi' } = req.body;
    const kundli = calculateKundli({ name, gender, dob, tob, pobCity });
    res.json({ success: true, data: kundli });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
}
