-- ==============================================================================
-- RINI PANDIT ASTROLOGY MARKETPLACE - SEED DATA
-- ==============================================================================

-- 1. Insert Demo User Profile
INSERT INTO public.profiles (
    id,
    phone,
    full_name,
    gender,
    dob,
    tob,
    pob_city,
    pob_country,
    wallet_balance,
    avatar_url
) VALUES (
    'a0000000-0000-0000-0000-000000000001',
    '+919876543210',
    'Rahul Sharma',
    'male',
    '1995-08-15',
    '07:30:00',
    'New Delhi',
    'India',
    500.00,
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80'
) ON CONFLICT (phone) DO UPDATE SET wallet_balance = 500.00;

-- 2. Insert Initial Wallet Transaction for Demo User
INSERT INTO public.wallet_transactions (
    user_id,
    amount,
    type,
    description,
    balance_after
) VALUES (
    'a0000000-0000-0000-0000-000000000001',
    500.00,
    'recharge',
    'Initial Welcome Demo Credits',
    500.00
);

-- 3. Seed Astrologers
INSERT INTO public.astrologers (
    id,
    display_name,
    specialties,
    languages,
    experience_years,
    rate_per_minute,
    rating,
    total_reviews,
    is_online,
    is_busy,
    bio,
    avatar_url
) VALUES 
(
    'b0000000-0000-0000-0000-000000000001',
    'Acharya Rini Pandit',
    ARRAY['Vedic', 'Kundli', 'Vastu', 'Career Guidance'],
    ARRAY['Hindi', 'English'],
    25,
    35.00,
    4.9,
    14820,
    true,
    false,
    'Gold Medalist Astro-Scientist with 25+ years of experience in Vedic Astrology, Career, and Marital remedies.',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80'
),
(
    'b0000000-0000-0000-0000-000000000002',
    'Pt. Radhe Shyam',
    ARRAY['Vedic', 'Kundli Matching', 'Prashna Chart'],
    ARRAY['Hindi'],
    16,
    25.00,
    4.8,
    8920,
    true,
    false,
    'Specialist in Kundli Milan (36 Guna), Manglik Dosh analysis, and gemstone recommendations.',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80'
),
(
    'b0000000-0000-0000-0000-000000000003',
    'Tarot Priya',
    ARRAY['Tarot Reading', 'Psychic Reading', 'Relationship Guidance'],
    ARRAY['English', 'Hindi'],
    8,
    20.00,
    4.9,
    5410,
    true,
    false,
    'Intuitive Tarot reader and crystal consultant guiding relationship healing and spiritual pathfinding.',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80'
),
(
    'b0000000-0000-0000-0000-000000000004',
    'Dr. Vivek Shastri',
    ARRAY['Numerology', 'Vastu Consultation', 'Business Astrologer'],
    ARRAY['Hindi', 'English', 'Gujarati'],
    19,
    40.00,
    4.7,
    7340,
    true,
    false,
    'PhD in Astro-Numerology. Trusted advisor to businesses, startups, and corporate leaders across India.',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80'
)
ON CONFLICT (id) DO NOTHING;
