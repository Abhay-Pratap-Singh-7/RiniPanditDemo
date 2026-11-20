import { supabase } from '../config/supabase.js';

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
  status: 'requested' | 'accepted' | 'active' | 'completed' | 'cancelled' | 'insufficient_balance';
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
  type: 'recharge' | 'consultation_debit' | 'refund' | 'promo_credit';
  reference_id?: string;
  description: string;
  balance_after: number;
  created_at: string;
}

// In-Memory Seed Data Fallback Store
class DataStore {
  private profiles: Map<string, Profile> = new Map();
  private astrologers: Map<string, Astrologer> = new Map();
  private consultations: Map<string, Consultation> = new Map();
  private messages: ChatMessage[] = [];
  private transactions: WalletTransaction[] = [];

  constructor() {
    this.initSeeds();
  }

  private initSeeds() {
    const seedAstrologers: Astrologer[] = [
      {
        id: 'b0000000-0000-0000-0000-000000000001',
        display_name: 'Acharya Rini Pandit',
        specialties: ['Vedic', 'Kundli', 'Vastu', 'Career Guidance'],
        languages: ['Hindi', 'English'],
        experience_years: 25,
        rate_per_minute: 35.0,
        rating: 4.9,
        total_reviews: 14820,
        is_online: true,
        is_busy: false,
        bio: 'Gold Medalist Astro-Scientist with 25+ years of experience in Vedic Astrology, Career, and Marital remedies.',
        avatar_url: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      },
      {
        id: 'b0000000-0000-0000-0000-000000000002',
        display_name: 'Pt. Radhe Shyam',
        specialties: ['Vedic', 'Kundli Matching', 'Prashna Chart'],
        languages: ['Hindi'],
        experience_years: 16,
        rate_per_minute: 25.0,
        rating: 4.8,
        total_reviews: 8920,
        is_online: true,
        is_busy: false,
        bio: 'Specialist in Kundli Milan (36 Guna), Manglik Dosh analysis, and gemstone recommendations.',
        avatar_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      },
      {
        id: 'b0000000-0000-0000-0000-000000000003',
        display_name: 'Tarot Priya',
        specialties: ['Tarot Reading', 'Psychic Reading', 'Relationship Guidance'],
        languages: ['English', 'Hindi'],
        experience_years: 8,
        rate_per_minute: 20.0,
        rating: 4.9,
        total_reviews: 5410,
        is_online: true,
        is_busy: false,
        bio: 'Intuitive Tarot reader and crystal consultant guiding relationship healing and spiritual pathfinding.',
        avatar_url: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
      },
      {
        id: 'b0000000-0000-0000-0000-000000000004',
        display_name: 'Dr. Vivek Shastri',
        specialties: ['Numerology', 'Vastu Consultation', 'Business Astrologer'],
        languages: ['Hindi', 'English', 'Gujarati'],
        experience_years: 19,
        rate_per_minute: 40.0,
        rating: 4.7,
        total_reviews: 7340,
        is_online: true,
        is_busy: false,
        bio: 'PhD in Astro-Numerology. Trusted advisor to businesses, startups, and corporate leaders across India.',
        avatar_url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      },
    ];

    seedAstrologers.forEach((astro) => this.astrologers.set(astro.id, astro));
  }

  // Profile operations
  async getProfile(idOrPhone: string): Promise<Profile | null> {
    if (supabase) {
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .or(`id.eq.${idOrPhone},phone.eq.${idOrPhone}`)
        .single();
      if (data) return data as Profile;
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
    this.profiles.set(updated.phone, updated);
    if (supabase) {
      await supabase.from('profiles').upsert(updated);
    }
    return updated;
  }

  // Astrologer operations
  async listAstrologers(specialty?: string): Promise<Astrologer[]> {
    if (supabase) {
      let query = supabase.from('astrologers').select('*');
      if (specialty) {
        query = query.contains('specialties', [specialty]);
      }
      const { data } = await query;
      if (data && data.length > 0) return data as Astrologer[];
    }
    const all = Array.from(this.astrologers.values());
    if (!specialty) return all;
    return all.filter((a) =>
      a.specialties.some((s) => s.toLowerCase().includes(specialty.toLowerCase()))
    );
  }

  async getAstrologer(id: string): Promise<Astrologer | null> {
    if (supabase) {
      const { data } = await supabase.from('astrologers').select('*').eq('id', id).single();
      if (data) return data as Astrologer;
    }
    return this.astrologers.get(id) || null;
  }

  async setAstrologerBusy(id: string, isBusy: boolean) {
    const astro = await this.getAstrologer(id);
    if (astro) {
      astro.is_busy = isBusy;
      this.astrologers.set(id, astro);
      if (supabase) {
        await supabase.from('astrologers').update({ is_busy: isBusy }).eq('id', id);
      }
    }
  }

  async updateAstrologer(id: string, updates: Partial<Astrologer>): Promise<Astrologer | null> {
    const astro = await this.getAstrologer(id);
    if (!astro) {
      const profile = await this.getProfile(id);
      const newAstro: Astrologer = {
        id,
        display_name: profile?.full_name || 'Acharya',
        specialties: ['Vedic', 'Kundli'],
        languages: ['Hindi', 'English'],
        experience_years: 5,
        rate_per_minute: 25.0,
        rating: 5.0,
        total_reviews: 0,
        is_online: true,
        is_busy: false,
        bio: '',
        avatar_url: profile?.avatar_url || 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
        ...updates,
      };
      this.astrologers.set(id, newAstro);
      if (supabase) {
        await supabase.from('astrologers').upsert({
          ...newAstro,
          profile_id: id,
        });
      }
      return newAstro;
    }
    const updated = { ...astro, ...updates };
    this.astrologers.set(id, updated);
    if (supabase) {
      await supabase.from('astrologers').update(updates).eq('id', id);
    }
    return updated;
  }

  async getConsultationsByAstrologer(astrologerId: string): Promise<Consultation[]> {
    if (supabase) {
      const { data } = await supabase
        .from('consultations')
        .select('*')
        .eq('astrologer_id', astrologerId)
        .order('created_at', { ascending: false });
      if (data) return data as Consultation[];
    }
    return Array.from(this.consultations.values())
      .filter((c) => c.astrologer_id === astrologerId)
      .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
  }

  async getAstrologerEarnings(astrologerId: string) {
    const sessions = await this.getConsultationsByAstrologer(astrologerId);
    const totalMinutes = sessions.reduce((acc, s) => acc + Math.ceil(s.duration_seconds / 60), 0);
    const totalEarned = sessions.reduce((acc, s) => acc + (s.total_deducted || 0), 0);
    return {
      astrologerId,
      totalEarned,
      totalMinutes,
      completedSessions: sessions.filter((s) => s.status === 'completed').length,
      recentSessions: sessions.slice(0, 10),
    };
  }

  // Wallet operations
  async rechargeWallet(userId: string, amount: number): Promise<{ profile: Profile; tx: WalletTransaction }> {
    const profile = (await this.getProfile(userId)) || {
      id: userId,
      phone: '+919876543210',
      full_name: 'Rahul Sharma',
      gender: 'male',
      dob: '1995-08-15',
      tob: '07:30',
      pob_city: 'New Delhi',
      pob_country: 'India',
      wallet_balance: 0,
      avatar_url: '',
    };

    profile.wallet_balance = Number(profile.wallet_balance) + Number(amount);
    await this.updateProfile(userId, { wallet_balance: profile.wallet_balance });

    const tx: WalletTransaction = {
      id: `tx_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      user_id: userId,
      amount,
      type: 'recharge',
      description: `Wallet top-up (Demo Instant Recharge)`,
      balance_after: profile.wallet_balance,
      created_at: new Date().toISOString(),
    };
    this.transactions.unshift(tx);
    if (supabase) {
      await supabase.from('wallet_transactions').insert(tx);
    }
    return { profile, tx };
  }

  async deductConsultationMinute(
    userId: string,
    sessionId: string,
    amount: number
  ): Promise<{ success: boolean; newBalance: number }> {
    const profile = await this.getProfile(userId);
    if (!profile || profile.wallet_balance < amount) {
      return { success: false, newBalance: profile?.wallet_balance || 0 };
    }

    profile.wallet_balance = Math.max(0, Number((profile.wallet_balance - amount).toFixed(2)));
    await this.updateProfile(userId, { wallet_balance: profile.wallet_balance });

    const tx: WalletTransaction = {
      id: `tx_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      user_id: userId,
      amount: -amount,
      type: 'consultation_debit',
      reference_id: sessionId,
      description: `Per-minute Consultation Debit`,
      balance_after: profile.wallet_balance,
      created_at: new Date().toISOString(),
    };
    this.transactions.unshift(tx);
    if (supabase) {
      await supabase.from('wallet_transactions').insert(tx);
    }

    return { success: true, newBalance: profile.wallet_balance };
  }

  async getTransactions(userId: string): Promise<WalletTransaction[]> {
    if (supabase) {
      const { data } = await supabase
        .from('wallet_transactions')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });
      if (data) return data as WalletTransaction[];
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
    if (supabase) {
      await supabase.from('consultations').insert(session);
    }
    return session;
  }

  async getConsultation(id: string): Promise<Consultation | null> {
    if (supabase) {
      const { data } = await supabase.from('consultations').select('*').eq('id', id).single();
      if (data) return data as Consultation;
    }
    return this.consultations.get(id) || null;
  }

  async updateConsultation(id: string, updates: Partial<Consultation>): Promise<Consultation | null> {
    const session = await this.getConsultation(id);
    if (!session) return null;
    const updated = { ...session, ...updates };
    this.consultations.set(id, updated);
    if (supabase) {
      await supabase.from('consultations').update(updates).eq('id', id);
    }
    return updated;
  }

  async getConsultationsByUser(userId: string): Promise<Consultation[]> {
    if (supabase) {
      const { data } = await supabase
        .from('consultations')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });
      if (data) return data as Consultation[];
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
    if (supabase) {
      await supabase.from('chat_messages').insert(fullMsg);
    }
    return fullMsg;
  }

  async getMessages(consultationId: string): Promise<ChatMessage[]> {
    if (supabase) {
      const { data } = await supabase
        .from('chat_messages')
        .select('*')
        .eq('consultation_id', consultationId)
        .order('created_at', { ascending: true });
      if (data) return data as ChatMessage[];
    }
    return this.messages.filter((m) => m.consultation_id === consultationId);
  }
}

export const store = new DataStore();
