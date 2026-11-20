import { supabase, supabaseAdmin, getDbClient } from '../config/supabase.js';

export interface Profile {
  id: string;
  phone: string;
  full_name: string;
  gender: string;
  dob: string;
  tob: string;
  pob_city: string;
  pob_country: string;
  wallet_balance: number;
  avatar_url: string;
}

export interface Astrologer {
  id: string;
  display_name: string;
  specialties: string[];
  languages: string[];
  experience_years: number;
  rate_per_minute: number;
  rating: number;
  total_reviews: number;
  is_online: boolean;
  is_busy: boolean;
  bio: string;
  avatar_url: string;
}

export interface Consultation {
  id: string;
  user_id: string;
  astrologer_id: string;
  type: 'chat' | 'voice' | 'video';
  status: 'requested' | 'pending' | 'accepted' | 'active' | 'completed' | 'cancelled' | 'declined' | 'insufficient_balance';
  rate_per_minute: number;
  duration_seconds: number;
  total_deducted: number;
  started_at?: string;
  ended_at?: string;
  created_at: string;
}

export interface ChatMessage {
  id: string;
  consultation_id: string;
  sender_id: string;
  content: string;
  is_read: boolean;
  created_at: string;
}

export interface WalletTransaction {
  id: string;
  user_id: string;
  amount: number;
  type: 'recharge' | 'consultation_debit' | 'consultation_credit' | 'refund' | 'promo_credit';
  reference_id?: string;
  description: string;
  balance_after: number;
  created_at: string;
}

// In-Memory Fallback & Cache Store
class DataStore {
  private profiles: Map<string, Profile> = new Map();
  private astrologers: Map<string, Astrologer> = new Map();
  private consultations: Map<string, Consultation> = new Map();
  private messages: ChatMessage[] = [];
  private transactions: WalletTransaction[] = [];

  constructor() {}

  // Profile operations
  async getProfile(idOrPhone: string): Promise<Profile | null> {
    const db = getDbClient();
    if (db) {
      try {
        const { data, error } = await db
          .from('profiles')
          .select('*')
          .or(`id.eq.${idOrPhone},phone.eq.${idOrPhone}`)
          .maybeSingle();
        if (error) {
          console.error('[Supabase Error] getProfile:', error.message);
        }
        if (data) {
          const prof = data as Profile;
          this.profiles.set(prof.id, prof);
          if (prof.phone) this.profiles.set(prof.phone, prof);
          return prof;
        }
      } catch (ex: any) {
        console.error('[Supabase Exception] getProfile:', ex?.message || ex);
      }
    }
    return (
      this.profiles.get(idOrPhone) ||
      Array.from(this.profiles.values()).find(
        (p) => p.id === idOrPhone || p.phone === idOrPhone
      ) ||
      null
    );
  }

  async updateProfile(id: string, updates: Partial<Profile>): Promise<Profile> {
    const current = await this.getProfile(id);
    const updated = { ...(current || {}), ...updates, id } as Profile;
    this.profiles.set(id, updated);
    if (updated.phone) {
      this.profiles.set(updated.phone, updated);
    }
    const db = getDbClient();
    if (db) {
      try {
        const profileRow = {
          id: updated.id,
          phone: updated.phone || `+91${Date.now().toString().slice(-10)}`,
          full_name: updated.full_name || '',
          gender: updated.gender || 'male',
          dob: updated.dob || null,
          tob: updated.tob || null,
          pob_city: updated.pob_city || '',
          pob_country: updated.pob_country || 'India',
          wallet_balance: updated.wallet_balance !== undefined ? updated.wallet_balance : 0.0,
          avatar_url: updated.avatar_url || '',
        };
        const { error } = await db.from('profiles').upsert(profileRow, { onConflict: 'id' });
        if (error) {
          console.error('[Supabase Error] updateProfile upsert:', error.message);
        }
      } catch (ex: any) {
        console.error('[Supabase Exception] updateProfile:', ex?.message || ex);
      }
    }
    return updated;
  }

  // Astrologer operations
  async listAstrologers(specialty?: string): Promise<Astrologer[]> {
    const db = getDbClient();
    if (db) {
      try {
        let query = db.from('astrologers').select('*').order('created_at', { ascending: false });
        if (specialty) {
          query = query.contains('specialties', [specialty]);
        }
        const { data, error } = await query;
        if (error) {
          console.error('[Supabase Error] listAstrologers:', error.message);
        }
        if (data && data.length > 0) {
          data.forEach((a: any) => this.astrologers.set(a.id, a as Astrologer));
          return data as Astrologer[];
        }
      } catch (ex: any) {
        console.error('[Supabase Exception] listAstrologers:', ex?.message || ex);
      }
    }
    const all = Array.from(this.astrologers.values());
    if (!specialty) return all;
    return all.filter((a) =>
      a.specialties?.some((s) => s.toLowerCase().includes(specialty.toLowerCase()))
    );
  }

  async getAstrologer(id: string): Promise<Astrologer | null> {
    const db = getDbClient();
    if (db) {
      try {
        const { data, error } = await db.from('astrologers').select('*').eq('id', id).maybeSingle();
        if (error) {
          console.error('[Supabase Error] getAstrologer:', error.message);
        }
        if (data) {
          const astro = data as Astrologer;
          this.astrologers.set(id, astro);
          return astro;
        }
      } catch (ex: any) {
        console.error('[Supabase Exception] getAstrologer:', ex?.message || ex);
      }
    }
    return this.astrologers.get(id) || null;
  }

  async setAstrologerBusy(id: string, isBusy: boolean) {
    const astro = await this.getAstrologer(id);
    if (astro) {
      astro.is_busy = isBusy;
      this.astrologers.set(id, astro);
      const db = getDbClient();
      if (db) {
        try {
          await db.from('astrologers').update({ is_busy: isBusy }).eq('id', id);
        } catch (_) {}
      }
    }
  }

  async updateAstrologer(id: string, updates: Partial<Astrologer>): Promise<Astrologer | null> {
    const currentAstro = await this.getAstrologer(id);
    const profile = await this.getProfile(id);

    const cleanAstro: Astrologer = {
      id,
      display_name: updates.display_name || currentAstro?.display_name || profile?.full_name || 'Acharya',
      specialties: updates.specialties || currentAstro?.specialties || ['Vedic', 'Kundli'],
      languages: updates.languages || currentAstro?.languages || ['Hindi', 'English'],
      experience_years: updates.experience_years !== undefined ? Number(updates.experience_years) : (currentAstro?.experience_years ?? 5),
      rate_per_minute: updates.rate_per_minute !== undefined ? Number(updates.rate_per_minute) : (currentAstro?.rate_per_minute ?? 25.0),
      rating: currentAstro?.rating ?? 5.0,
      total_reviews: currentAstro?.total_reviews ?? 0,
      is_online: updates.is_online !== undefined ? updates.is_online : (currentAstro?.is_online ?? true),
      is_busy: updates.is_busy !== undefined ? updates.is_busy : (currentAstro?.is_busy ?? false),
      bio: updates.bio !== undefined ? updates.bio : (currentAstro?.bio ?? ''),
      avatar_url: updates.avatar_url || currentAstro?.avatar_url || profile?.avatar_url || '',
    };

    this.astrologers.set(id, cleanAstro);

    const db = getDbClient();
    if (db) {
      try {
        // 1. Ensure profile exists in profiles table so foreign key constraint succeeds
        const profilePhone = profile?.phone || `+91${Date.now().toString().slice(-10)}`;
        const { error: profileErr } = await db.from('profiles').upsert({
          id,
          phone: profilePhone,
          full_name: cleanAstro.display_name,
          wallet_balance: 0.0,
        }, { onConflict: 'id' });
        if (profileErr) {
          console.error('[Supabase Error] Upsert profiles before astrologer:', profileErr.message);
        }

        // 2. Prepare database row strictly conforming to public.astrologers schema
        const astroDbRow: any = {
          id,
          profile_id: !profileErr ? id : null,
          display_name: cleanAstro.display_name,
          specialties: cleanAstro.specialties,
          languages: cleanAstro.languages,
          experience_years: cleanAstro.experience_years,
          rate_per_minute: cleanAstro.rate_per_minute,
          rating: cleanAstro.rating,
          total_reviews: cleanAstro.total_reviews,
          is_online: cleanAstro.is_online,
          is_busy: cleanAstro.is_busy,
          bio: cleanAstro.bio,
          avatar_url: cleanAstro.avatar_url,
        };

        // 3. Upsert into astrologers table
        const { data: upsertData, error: astroErr } = await db
          .from('astrologers')
          .upsert(astroDbRow, { onConflict: 'id' })
          .select();

        if (astroErr) {
          console.error('[Supabase Error] Upsert astrologers failed:', astroErr.message, 'Code:', astroErr.code);
          // If foreign key constraint failed (e.g. code 23503), retry without profile_id
          if (astroErr.code === '23503') {
            delete astroDbRow.profile_id;
            const { data: retryData, error: retryErr } = await db
              .from('astrologers')
              .upsert(astroDbRow, { onConflict: 'id' })
              .select();
            if (retryErr) {
              console.error('[Supabase Error] Retry astrologer upsert without profile_id also failed:', retryErr.message);
            } else {
              console.log('[Supabase Success] Astrologer inserted into Supabase (without profile_id):', id);
            }
          }
        } else {
          console.log('[Supabase Success] Astrologer successfully inserted into Supabase astrologers table:', id);
        }
      } catch (ex: any) {
        console.error('[Supabase Exception] Failed to persist astrologer to Supabase:', ex?.message || ex);
      }
    }

    return cleanAstro;
  }

  async getConsultationsByAstrologer(astrologerId: string): Promise<Consultation[]> {
    const astro = await this.getAstrologer(astrologerId);
    const candidateIds = new Set<string>();
    if (astrologerId) candidateIds.add(astrologerId);
    if (astro) {
      if (astro.id) candidateIds.add(astro.id);
      if ((astro as any).profile_id) candidateIds.add((astro as any).profile_id);
    }
    const ids = Array.from(candidateIds);

    const db = getDbClient();
    if (db) {
      try {
        const { data, error } = await db
          .from('consultations')
          .select('*')
          .in('astrologer_id', ids)
          .order('created_at', { ascending: false });
        if (error) console.error('[Supabase Error] getConsultationsByAstrologer:', error.message);
        if (data && data.length > 0) return data as Consultation[];
      } catch (_) {}
    }
    return Array.from(this.consultations.values())
      .filter((c) => candidateIds.has(c.astrologer_id))
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
  }

  async getAstrologerEarnings(astrologerId: string) {
    const sessions = await this.getConsultationsByAstrologer(astrologerId);
    const totalMinutes = sessions.reduce((acc, s) => acc + Math.ceil((s.duration_seconds || 0) / 60), 0);
    const totalEarnedFromSessions = sessions.reduce((acc, s) => acc + (s.total_deducted || 0), 0);

    const astro = await this.getAstrologer(astrologerId);
    const candidateIds = new Set<string>();
    if (astrologerId) candidateIds.add(astrologerId);
    if (astro) {
      if (astro.id) candidateIds.add(astro.id);
      if ((astro as any).profile_id) candidateIds.add((astro as any).profile_id);
    }

    let maxWalletBalance = 0;
    for (const pid of candidateIds) {
      const p = await this.getProfile(pid);
      if (p && Number(p.wallet_balance || 0) > maxWalletBalance) {
        maxWalletBalance = Number(p.wallet_balance || 0);
      }
    }

    const totalEarned = Math.max(totalEarnedFromSessions, maxWalletBalance);

    return {
      astrologerId,
      totalEarned,
      totalMinutes,
      completedSessions: sessions.filter((s) => s.status === 'completed').length,
      recentSessions: sessions.slice(0, 10),
      walletBalance: maxWalletBalance,
    };
  }

  // Wallet operations
  async rechargeWallet(userId: string, amount: number): Promise<{ profile: Profile; tx: WalletTransaction }> {
    let profile = await this.getProfile(userId);
    if (!profile) {
      profile = {
        id: userId,
        phone: '',
        full_name: '',
        gender: 'male',
        dob: '',
        tob: '',
        pob_city: '',
        pob_country: 'India',
        wallet_balance: 0,
        avatar_url: '',
      };
    }

    profile.wallet_balance = Number(profile.wallet_balance) + Number(amount);
    await this.updateProfile(userId, { wallet_balance: profile.wallet_balance });

    const tx: WalletTransaction = {
      id: `tx_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      user_id: userId,
      amount,
      type: 'recharge',
      description: `Wallet recharge`,
      balance_after: profile.wallet_balance,
      created_at: new Date().toISOString(),
    };
    this.transactions.unshift(tx);
    const db = getDbClient();
    if (db) {
      try {
        const { error } = await db.from('wallet_transactions').insert(tx);
        if (error) console.error('[Supabase Error] rechargeWallet tx insert:', error.message);
      } catch (_) {}
    }
    return { profile, tx };
  }

  async transferConsultationMinute(
    clientId: string,
    astrologerId: string,
    sessionId: string,
    amount: number
  ): Promise<{ success: boolean; clientBalance: number; panditBalance: number }> {
    const clientProfile = await this.getProfile(clientId);
    if (!clientProfile || clientProfile.wallet_balance < amount) {
      return {
        success: false,
        clientBalance: clientProfile?.wallet_balance || 0,
        panditBalance: 0,
      };
    }

    // 1. Debit client account
    clientProfile.wallet_balance = Math.max(0, Number((clientProfile.wallet_balance - amount).toFixed(2)));
    await this.updateProfile(clientId, { wallet_balance: clientProfile.wallet_balance });

    const debitTx: WalletTransaction = {
      id: `tx_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      user_id: clientId,
      amount: -amount,
      type: 'consultation_debit',
      reference_id: sessionId,
      description: 'Consultation minute debit',
      balance_after: clientProfile.wallet_balance,
      created_at: new Date().toISOString(),
    };
    this.transactions.unshift(debitTx);

    // 2. Credit pandit account
    const astro = await this.getAstrologer(astrologerId);
    const candidateIds = new Set<string>();
    if (astrologerId) candidateIds.add(astrologerId);
    if (astro) {
      if (astro.id) candidateIds.add(astro.id);
      if ((astro as any).profile_id) candidateIds.add((astro as any).profile_id);
    }

    let panditWalletBalance = 0;
    const creditTxs: WalletTransaction[] = [];

    for (const pid of candidateIds) {
      let p = await this.getProfile(pid);
      if (!p) {
        p = {
          id: pid,
          phone: '',
          full_name: astro?.display_name || 'Acharya',
          gender: 'male',
          dob: '',
          tob: '',
          pob_city: '',
          pob_country: 'India',
          wallet_balance: 0,
          avatar_url: astro?.avatar_url || '',
        };
      }
      p.wallet_balance = Number((Number(p.wallet_balance || 0) + amount).toFixed(2));
      await this.updateProfile(pid, { wallet_balance: p.wallet_balance });
      panditWalletBalance = p.wallet_balance;

      const creditTx: WalletTransaction = {
        id: `tx_${Date.now() + 1}_${Math.random().toString(36).substring(2, 7)}`,
        user_id: pid,
        amount: amount,
        type: 'consultation_credit',
        reference_id: sessionId,
        description: `Consultation Earning from ${clientProfile.full_name || 'Client'}`,
        balance_after: p.wallet_balance,
        created_at: new Date().toISOString(),
      };
      this.transactions.unshift(creditTx);
      creditTxs.push(creditTx);
    }

    const db = getDbClient();
    if (db) {
      try {
        await db.from('wallet_transactions').insert([debitTx, ...creditTxs]);
      } catch (err: any) {
        console.error('[Supabase Error] transferConsultationMinute tx insert:', err.message);
      }
    }

    return {
      success: true,
      clientBalance: clientProfile.wallet_balance,
      panditBalance: panditWalletBalance,
    };
  }

  async deductConsultationMinute(
    userId: string,
    sessionId: string,
    amount: number
  ): Promise<{ success: boolean; newBalance: number }> {
    const consultation = await this.getConsultation(sessionId);
    const astrologerId = consultation?.astrologer_id || '';
    const res = await this.transferConsultationMinute(userId, astrologerId, sessionId, amount);
    return { success: res.success, newBalance: res.clientBalance };
  }

  async getTransactions(userId: string): Promise<WalletTransaction[]> {
    const db = getDbClient();
    if (db) {
      try {
        const { data, error } = await db
          .from('wallet_transactions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', { ascending: false });
        if (error) console.error('[Supabase Error] getTransactions:', error.message);
        if (data) return data as WalletTransaction[];
      } catch (_) {}
    }
    return this.transactions.filter((t) => t.user_id === userId);
  }

  // Consultation Session operations
  async createConsultation(data: Omit<Consultation, 'id' | 'created_at'>): Promise<Consultation> {
    const session: Consultation = {
      ...data,
      id: `cs_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      created_at: new Date().toISOString(),
    };
    this.consultations.set(session.id, session);
    const db = getDbClient();
    if (db) {
      try {
        const { error } = await db.from('consultations').insert(session);
        if (error) console.error('[Supabase Error] createConsultation:', error.message);
      } catch (_) {}
    }
    return session;
  }

  async getConsultation(id: string): Promise<Consultation | null> {
    const db = getDbClient();
    if (db) {
      try {
        const { data, error } = await db.from('consultations').select('*').eq('id', id).single();
        if (error) console.error('[Supabase Error] getConsultation:', error.message);
        if (data) return data as Consultation;
      } catch (_) {}
    }
    return this.consultations.get(id) || null;
  }

  async updateConsultation(id: string, updates: Partial<Consultation>): Promise<Consultation | null> {
    const session = await this.getConsultation(id);
    if (!session) return null;
    const updated = { ...session, ...updates };
    this.consultations.set(id, updated);
    const db = getDbClient();
    if (db) {
      try {
        const { error } = await db.from('consultations').update(updates).eq('id', id);
        if (error) console.error('[Supabase Error] updateConsultation:', error.message);
      } catch (_) {}
    }
    return updated;
  }

  async getConsultationsByUser(userId: string): Promise<Consultation[]> {
    const db = getDbClient();
    if (db) {
      try {
        const { data, error } = await db
          .from('consultations')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', { ascending: false });
        if (error) console.error('[Supabase Error] getConsultationsByUser:', error.message);
        if (data) return data as Consultation[];
      } catch (_) {}
    }
    return Array.from(this.consultations.values())
      .filter((c) => c.user_id === userId)
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
  }

  // Message operations
  async addMessage(msg: Omit<ChatMessage, 'id' | 'created_at'>): Promise<ChatMessage> {
    const fullMsg: ChatMessage = {
      ...msg,
      id: `msg_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      created_at: new Date().toISOString(),
    };
    this.messages.push(fullMsg);
    const db = getDbClient();
    if (db) {
      try {
        const { error } = await db.from('chat_messages').insert(fullMsg);
        if (error) console.error('[Supabase Error] addMessage:', error.message);
      } catch (_) {}
    }
    return fullMsg;
  }

  async getMessages(consultationId: string): Promise<ChatMessage[]> {
    const db = getDbClient();
    if (db) {
      try {
        const { data, error } = await db
          .from('chat_messages')
          .select('*')
          .eq('consultation_id', consultationId)
          .order('created_at', { ascending: true });
        if (error) console.error('[Supabase Error] getMessages:', error.message);
        if (data) return data as ChatMessage[];
      } catch (_) {}
    }
    return this.messages.filter((m) => m.consultation_id === consultationId);
  }
}

export const store = new DataStore();