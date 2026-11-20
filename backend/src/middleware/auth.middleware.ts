import { Request, Response, NextFunction } from 'express';
import { supabase } from '../config/supabase.js';
import { store } from '../services/store.js';

export interface AuthenticatedUser {
  id: string;
  email?: string;
  phone?: string;
  role?: string;
}

export interface AuthRequest extends Request {
  user?: AuthenticatedUser;
}

export async function authenticate(req: AuthRequest, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      // Optional authentication: check query or body for fallback ID
      const fallbackId = (req.query.userId as string) || (req.body?.userId as string);
      if (fallbackId) {
        req.user = { id: fallbackId };
      }
      return next();
    }

    const token = authHeader.substring(7).trim();

    // 1. Check if token is a Supabase JWT
    if (supabase) {
      try {
        const { data, error } = await supabase.auth.getUser(token);
        if (!error && data?.user) {
          const profile = await store.getProfile(data.user.id);
          req.user = {
            id: data.user.id,
            email: data.user.email,
            phone: profile?.phone,
            role: (data.user.user_metadata?.role as string) || 'user',
          };
          return next();
        }
      } catch (sbErr) {
        // Fall through to local token parsing
      }
    }

    // Default passthrough
    return next();
  } catch (err) {
    return next();
  }
}

export function requireAuth(req: AuthRequest, res: Response, next: NextFunction) {
  if (!req.user || !req.user.id) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required. Please log in with Supabase.',
    });
  }
  next();
}
