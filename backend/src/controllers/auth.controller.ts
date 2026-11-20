import { Request, Response } from 'express';
import { supabase, supabaseAdmin } from '../config/supabase.js';
import { ENV } from '../config/env.js';
import { store, Profile, Astrologer } from '../services/store.js';
import { AuthRequest } from '../middleware/auth.middleware.js';

export async function signUp(req: Request, res: Response) {
  try {
    const {
      email,
      password,
      fullName = 'Devotee / Client',
      phone = '+919876543210',
      role = 'user',
      specialties = ['Vedic', 'Kundli'],
      languages = ['Hindi', 'English'],
      experienceYears = 5,
      ratePerMinute = 25.0,
      bio = '',
    } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required for registration.',
      });
    }

    let authUserId: string = '';
    let accessToken: string = '';
    let refreshToken: string = '';

    // 1. Try Supabase Admin API first (bypasses Supabase SMTP email rate limits and auto-confirms email)
    if (ENV.SUPABASE_SERVICE_ROLE_KEY && supabaseAdmin && supabaseAdmin.auth?.admin) {
      try {
        const { data: adminData, error: adminError } = await supabaseAdmin.auth.admin.createUser({
          email,
          password,
          email_confirm: true,
          user_metadata: {
            full_name: fullName,
            phone,
            role,
          },
        });

        if (!adminError && adminData?.user) {
          authUserId = adminData.user.id;
          if (supabase) {
            const { data: signInData } = await supabase.auth.signInWithPassword({
              email,
              password,
            });
            if (signInData?.session) {
              accessToken = signInData.session.access_token;
              refreshToken = signInData.session.refresh_token;
            }
          }
          if (!accessToken) {
            accessToken = `token_${authUserId}`;
          }
        } else if (adminError) {
          const errLower = adminError.message.toLowerCase();
          if (errLower.includes('already') || errLower.includes('registered')) {
            return res.status(400).json({
              success: false,
              message: 'An account with this email already exists. Please sign in instead.',
            });
          }
        }
      } catch (adminEx) {
        // Fall back to standard sign up
      }
    }

    // 2. If not created via admin API, use standard Supabase signUp
    if (!authUserId && supabase) {
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName,
            phone,
            role,
          },
        },
      });

      if (authError) {
        let cleanMsg = authError.message;
        if (cleanMsg.toLowerCase().includes('rate limit')) {
          cleanMsg =
            'Email rate limit exceeded. Supabase free tier limits signup emails. Please disable "Confirm email" in Supabase Dashboard (Authentication -> Providers -> Email -> uncheck "Confirm email") or add SUPABASE_SERVICE_ROLE_KEY in Render.';
        }
        return res.status(400).json({
          success: false,
          message: cleanMsg,
        });
      }

      if (!authData.user) {
        return res.status(400).json({
          success: false,
          message: 'Failed to create account.',
        });
      }

      authUserId = authData.user.id;
      accessToken = authData.session?.access_token || `token_${authUserId}`;
      refreshToken = authData.session?.refresh_token || '';

      // Auto-confirm if admin client is available
      if (ENV.SUPABASE_SERVICE_ROLE_KEY && supabaseAdmin && (!authData.session || !authData.user.confirmed_at)) {
        try {
          await supabaseAdmin.auth.admin.updateUserById(authUserId, {
            email_confirm: true,
          });
          const { data: signInData } = await supabase.auth.signInWithPassword({
            email,
            password,
          });
          if (signInData?.session) {
            accessToken = signInData.session.access_token;
            refreshToken = signInData.session.refresh_token;
          }
        } catch (_) {}
      }
    }

    // 3. Fallback if offline
    if (!authUserId) {
      authUserId = `user_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`;
      accessToken = `token_${authUserId}`;
    }

    // 4. Create User Profile in Supabase & Local Store
    const initialWalletBalance = role === 'pandit' ? 0.0 : 100.0;
    const newProfile: Profile = {
      id: authUserId,
      phone,
      full_name: fullName,
      gender: 'male',
      dob: '1995-01-01',
      tob: '10:00',
      pob_city: 'Delhi',
      pob_country: 'India',
      wallet_balance: initialWalletBalance,
      avatar_url: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    };

    const savedProfile = await store.updateProfile(authUserId, newProfile);

    // 5. If Role is Pandit, create Astrologer Record
    let savedAstrologer: Astrologer | null = null;
    if (role === 'pandit') {
      const newAstrologer: Astrologer = {
        id: authUserId,
        display_name: fullName,
        specialties: Array.isArray(specialties) ? specialties : ['Vedic', 'Kundli'],
        languages: Array.isArray(languages) ? languages : ['Hindi', 'English'],
        experience_years: Number(experienceYears) || 5,
        rate_per_minute: Number(ratePerMinute) || 25.0,
        rating: 5.0,
        total_reviews: 0,
        is_online: true,
        is_busy: false,
        bio: bio || 'Certified Vedic Astrologer & Kundli Specialist',
        avatar_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      };

      if (supabase) {
        await supabase.from('astrologers').upsert({
          ...newAstrologer,
          profile_id: authUserId,
        });
      }
      savedAstrologer = await store.updateAstrologer(authUserId, newAstrologer);
    }

    return res.status(201).json({
      success: true,
      message: 'Account created and authenticated successfully via Supabase.',
      token: accessToken,
      refreshToken,
      user: {
        id: authUserId,
        email,
        phone,
        role,
      },
      profile: savedProfile,
      astrologer: savedAstrologer,
      role,
    });
  } catch (err: any) {
    return res.status(500).json({
      success: false,
      message: err.message || 'Internal server error during registration.',
    });
  }
}

export async function signIn(req: Request, res: Response) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required.',
      });
    }

    let authUserId: string = '';
    let accessToken: string = '';
    let refreshToken: string = '';
    let detectedEmail: string = email;
    let detectedRole: string = 'user';

    // 1. Supabase Authentication
    if (supabase) {
      const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (signInError || !signInData.user) {
        let cleanMsg = signInError?.message || 'Invalid email or password.';
        if (cleanMsg.toLowerCase().includes('invalid login credentials')) {
          cleanMsg = 'Invalid email or password. Please verify your credentials or sign up.';
        }
        return res.status(401).json({
          success: false,
          message: cleanMsg,
        });
      }

      authUserId = signInData.user.id;
      accessToken = signInData.session?.access_token || '';
      refreshToken = signInData.session?.refresh_token || '';
      detectedEmail = signInData.user.email || email;
      detectedRole = signInData.user.user_metadata?.role || 'user';
    } else {
      const profile = await store.getProfile(email);
      if (!profile) {
        return res.status(401).json({
          success: false,
          message: 'Account not found. Please register first.',
        });
      }
      authUserId = profile.id;
      accessToken = `token_${authUserId}`;
    }

    // 2. Fetch User Profile
    const profile = await store.getProfile(authUserId);

    // 3. Determine Role & Astrologer record
    const astrologer = await store.getAstrologer(authUserId);
    const role = detectedRole === 'pandit' || astrologer ? 'pandit' : 'user';

    return res.json({
      success: true,
      message: 'Logged in successfully.',
      token: accessToken,
      refreshToken,
      user: {
        id: authUserId,
        email: detectedEmail,
        phone: profile?.phone,
        role,
      },
      profile,
      astrologer,
      role,
    });
  } catch (err: any) {
    return res.status(500).json({
      success: false,
      message: err.message || 'Internal server error during login.',
    });
  }
}

export async function getMe(req: AuthRequest, res: Response) {
  try {
    const userId = req.user?.id || (req.query.userId as string);
    if (!userId) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }
    const profile = await store.getProfile(userId);
    const astrologer = await store.getAstrologer(userId);
    const role = astrologer ? 'pandit' : (req.user?.role || 'user');

    return res.json({
      success: true,
      user: {
        id: userId,
        email: req.user?.email || (profile ? `${profile.phone}@rinipandit.com` : ''),
        phone: profile?.phone,
        role,
      },
      profile,
      astrologer,
      role,
      walletBalance: profile ? profile.wallet_balance : 0,
    });
  } catch (err: any) {
    return res.status(500).json({
      success: false,
      error: err.message,
    });
  }
}

export async function signOut(req: Request, res: Response) {
  try {
    if (supabase) {
      await supabase.auth.signOut();
    }
    return res.json({
      success: true,
      message: 'Signed out successfully.',
    });
  } catch (err: any) {
    return res.status(500).json({
      success: false,
      error: err.message,
    });
  }
}

export async function refreshToken(req: Request, res: Response) {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token is required.',
      });
    }

    if (supabase) {
      const { data, error } = await supabase.auth.refreshSession({
        refresh_token: refreshToken,
      });

      if (error || !data.session) {
        return res.status(401).json({
          success: false,
          message: error?.message || 'Invalid or expired refresh token.',
        });
      }

      return res.json({
        success: true,
        token: data.session.access_token,
        refreshToken: data.session.refresh_token,
      });
    }

    return res.json({
      success: true,
      token: `token_${Date.now()}`,
    });
  } catch (err: any) {
    return res.status(500).json({
      success: false,
      error: err.message,
    });
  }
}
