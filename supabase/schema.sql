-- ==============================================================================
-- RINI PANDIT ASTROLOGY MARKETPLACE - SUPABASE SCHEMA DEFINITION
-- ==============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Custom Enumerations
DO $$ BEGIN
    CREATE TYPE session_type AS ENUM ('chat', 'voice', 'video');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE session_status AS ENUM ('requested', 'accepted', 'active', 'completed', 'cancelled', 'insufficient_balance');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE tx_type AS ENUM ('recharge', 'consultation_debit', 'refund', 'promo_credit');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- 3. User Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_user_id UUID UNIQUE,
    phone VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10) DEFAULT 'male',
    dob DATE,
    tob TIME,
    pob_city VARCHAR(100),
    pob_country VARCHAR(100) DEFAULT 'India',
    wallet_balance DECIMAL(10, 2) DEFAULT 0.00 CHECK (wallet_balance >= 0.00),
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Astrologers Marketplace Table
CREATE TABLE IF NOT EXISTS public.astrologers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    display_name VARCHAR(100) NOT NULL,
    specialties TEXT[] NOT NULL DEFAULT '{}',
    languages TEXT[] NOT NULL DEFAULT '{"English", "Hindi"}',
    experience_years INT DEFAULT 1,
    rate_per_minute DECIMAL(10, 2) NOT NULL DEFAULT 20.00,
    rating DECIMAL(2, 1) DEFAULT 5.0,
    total_reviews INT DEFAULT 0,
    is_online BOOLEAN DEFAULT true,
    is_busy BOOLEAN DEFAULT false,
    bio TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Consultation Sessions Table
CREATE TABLE IF NOT EXISTS public.consultations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    astrologer_id UUID NOT NULL REFERENCES public.astrologers(id) ON DELETE CASCADE,
    type session_type NOT NULL DEFAULT 'chat',
    status session_status NOT NULL DEFAULT 'requested',
    rate_per_minute DECIMAL(10, 2) NOT NULL,
    duration_seconds INT DEFAULT 0,
    total_deducted DECIMAL(10, 2) DEFAULT 0.00,
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Realtime Chat Messages Table
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    consultation_id UUID NOT NULL REFERENCES public.consultations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Wallet Transactions Ledger
CREATE TABLE IF NOT EXISTS public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    type tx_type NOT NULL,
    reference_id UUID,
    description VARCHAR(255),
    balance_after DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Indexes for High-Frequency Real-time Queries
CREATE INDEX IF NOT EXISTS idx_consultations_user_id ON public.consultations(user_id);
CREATE INDEX IF NOT EXISTS idx_consultations_astrologer_id ON public.consultations(astrologer_id);
CREATE INDEX IF NOT EXISTS idx_consultations_status ON public.consultations(status);
CREATE INDEX IF NOT EXISTS idx_chat_messages_consultation_id ON public.chat_messages(consultation_id);
CREATE INDEX IF NOT EXISTS idx_wallet_tx_user_id ON public.wallet_transactions(user_id);

-- 9. Row Level Security (RLS) Enablement
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.astrologers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
