export interface KundliInput {
  name: string;
  gender: string;
  dob: string; // YYYY-MM-DD
  tob: string; // HH:mm
  pobCity: string;
}

export interface KundliResult {
  ascendant: string;
  moonSign: string;
  sunSign: string;
  nakshatra: string;
  planetaryPositions: Array<{
    planet: string;
    sign: string;
    degree: string;
    house: number;
    status: string;
  }>;
  doshas: {
    manglik: boolean;
    kaalSarp: boolean;
    pitraDosh: boolean;
    remedy: string;
  };
  prediction: string;
}

const ZODIAC_SIGNS = [
  'Aries (Mesh)',
  'Taurus (Vrishabha)',
  'Gemini (Mithuna)',
  'Cancer (Karka)',
  'Leo (Simha)',
  'Virgo (Kanya)',
  'Libra (Tula)',
  'Scorpio (Vrishchika)',
  'Sagittarius (Dhanu)',
  'Capricorn (Makara)',
  'Aquarius (Kumbha)',
  'Pisces (Meena)',
];

const NAKSHATRAS = [
  'Ashwini',
  'Bharani',
  'Krittika',
  'Rohini',
  'Mrigashirsha',
  'Ardra',
  'Punarvasu',
  'Pushya',
  'Ashlesha',
  'Magha',
  'Purva Phalguni',
  'Uttara Phalguni',
  'Hasta',
  'Chitra',
  'Swati',
  'Vishakha',
  'Anuradha',
  'Jyeshtha',
  'Mula',
  'Purva Ashadha',
  'Uttara Ashadha',
  'Shravana',
  'Dhanishta',
  'Shatabhisha',
  'Purva Bhadrapada',
  'Uttara Bhadrapada',
  'Revati',
];

export function calculateKundli(input: KundliInput): KundliResult {
  const dateObj = new Date(input.dob);
  const day = dateObj.getDate() || 15;
  const month = dateObj.getMonth() || 7;
  const year = dateObj.getFullYear() || 1995;

  const ascIndex = (day + month + (input.tob ? parseInt(input.tob.split(':')[0], 10) : 7)) % 12;
  const moonIndex = (day * 2 + month) % 12;
  const sunIndex = (month + (day > 21 ? 1 : 0)) % 12;
  const nakIndex = (day * 3 + month * 2) % 27;

  return {
    ascendant: ZODIAC_SIGNS[ascIndex],
    moonSign: ZODIAC_SIGNS[moonIndex],
    sunSign: ZODIAC_SIGNS[sunIndex],
    nakshatra: NAKSHATRAS[nakIndex],
    planetaryPositions: [
      { planet: 'Sun (Surya)', sign: ZODIAC_SIGNS[sunIndex], degree: '18° 24\'', house: 1, status: 'Exalted' },
      { planet: 'Moon (Chandra)', sign: ZODIAC_SIGNS[moonIndex], degree: '04° 12\'', house: 4, status: 'Friendly' },
      { planet: 'Mars (Mangal)', sign: ZODIAC_SIGNS[(ascIndex + 2) % 12], degree: '22° 45\'', house: 3, status: 'Own Sign' },
      { planet: 'Mercury (Budh)', sign: ZODIAC_SIGNS[(sunIndex + 1) % 12], degree: '12° 08\'', house: 2, status: 'Neutral' },
      { planet: 'Jupiter (Brihaspati)', sign: ZODIAC_SIGNS[(ascIndex + 4) % 12], degree: '28° 50\'', house: 5, status: 'Benefic' },
      { planet: 'Venus (Shukra)', sign: ZODIAC_SIGNS[(ascIndex + 6) % 12], degree: '15° 33\'', house: 7, status: 'Strong' },
      { planet: 'Saturn (Shani)', sign: ZODIAC_SIGNS[(ascIndex + 9) % 12], degree: '09° 17\'', house: 10, status: 'Karmic' },
      { planet: 'Rahu', sign: ZODIAC_SIGNS[(ascIndex + 1) % 12], degree: '05° 40\'', house: 2, status: 'Neutral' },
      { planet: 'Ketu', sign: ZODIAC_SIGNS[(ascIndex + 7) % 12], degree: '05° 40\'', house: 8, status: 'Neutral' },
    ],
    doshas: {
      manglik: (day % 4 === 0),
      kaalSarp: (day % 7 === 0),
      pitraDosh: false,
      remedy: (day % 4 === 0)
        ? 'Chant Hanuman Chalisa daily and offer red flowers on Tuesdays.'
        : 'Worship Lord Shiva with milk and water every Monday morning for mental peace and career growth.',
    },
    prediction: `The alignment of Jupiter in the 5th house signifies strong intellect and success in communication and finance. Favorable period for career advancement and personal ventures over the coming 6 months.`,
  };
}

export function getDailyHoroscope(sign: string) {
  const normalized = sign.toLowerCase();
  const horoscopes: Record<string, { luckyColor: string; luckyNumber: number; rating: number; prediction: string }> = {
    aries: {
      luckyColor: 'Coral Red',
      luckyNumber: 9,
      rating: 4.5,
      prediction: 'Energy levels are peaked today. Channel your drive into decisive career projects. Avoid unnecessary arguments during financial negotiations.',
    },
    taurus: {
      luckyColor: 'Emerald Green',
      luckyNumber: 6,
      rating: 4.8,
      prediction: 'Financial gains are strongly indicated through past investments. Harmonious relationship vibrations will bring peace to your home life.',
    },
    gemini: {
      luckyColor: 'Bright Yellow',
      luckyNumber: 5,
      rating: 4.2,
      prediction: 'Communications are favored today. A surprise call or message may open up a promising collaboration opportunity.',
    },
    cancer: {
      luckyColor: 'Silver White',
      luckyNumber: 2,
      rating: 4.0,
      prediction: 'Listen to your intuition regarding career matters. Focus on meditation and self-care in the evening hours.',
    },
    leo: {
      luckyColor: 'Royal Gold',
      luckyNumber: 1,
      rating: 4.9,
      prediction: 'Leadership skills shine today. You will receive appreciation from seniors and peers. Financial flow remains steady.',
    },
    virgo: {
      luckyColor: 'Sky Blue',
      luckyNumber: 7,
      rating: 4.3,
      prediction: 'Attention to detail will resolve a lingering project bottleneck. Take time to celebrate minor milestones.',
    },
    libra: {
      luckyColor: 'Pastel Pink',
      luckyNumber: 3,
      rating: 4.6,
      prediction: 'Balanced mind brings harmony to team dynamics. Favorable day for business agreements and creative expressions.',
    },
    scorpio: {
      luckyColor: 'Deep Crimson',
      luckyNumber: 8,
      rating: 4.4,
      prediction: 'A transformational breakthrough awaits you in a personal endeavor. Trust your research and take calculated strides.',
    },
    sagittarius: {
      luckyColor: 'Saffron',
      luckyNumber: 12,
      rating: 4.7,
      prediction: 'Optimism and fortune surround your actions today. Ideal day for higher learning, travel plans, and spiritual practices.',
    },
    capricorn: {
      luckyColor: 'Charcoal Grey',
      luckyNumber: 10,
      rating: 4.5,
      prediction: 'Discipline yields high returns today. Financial discipline ensures steady stability for upcoming family obligations.',
    },
    aquarius: {
      luckyColor: 'Electric Violet',
      luckyNumber: 11,
      rating: 4.1,
      prediction: 'Innovative solutions come naturally to you today. Connect with friends and communities to exchange visionary concepts.',
    },
    pisces: {
      luckyColor: 'Ocean Teal',
      luckyNumber: 4,
      rating: 4.6,
      prediction: 'Empathy and creative imagination are your greatest strengths today. Wonderful progress in artistic and healing pursuits.',
    },
  };

  return horoscopes[normalized] || horoscopes['aries'];
}
