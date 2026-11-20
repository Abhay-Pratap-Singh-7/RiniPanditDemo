import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { signUp, signIn, getMe, signOut, refreshToken } from '../controllers/auth.controller.js';
import { getAstrologers, getAstrologerById } from '../controllers/astrologers.controller.js';
import { getUserProfile, updateUserProfile } from '../controllers/user.controller.js';
import { getWalletBalance, rechargeWallet, getTransactions } from '../controllers/wallet.controller.js';
import { getConsultationHistory, getConsultationMessages } from '../controllers/consultations.controller.js';
import { getHoroscope, getAllHoroscopes, generateKundli } from '../controllers/astrology.controller.js';
import {
  getPanditProfile,
  updatePanditStatus,
  getPanditEarnings,
  getPanditSessions,
  panditLogin,
} from '../controllers/pandit.controller.js';

const router = Router();

// Apply global bearer token extractor middleware across all routes
router.use(authenticate);

// ==========================================
// SUPABASE AUTHENTICATION APIS (With Aliases)
// ==========================================
router.post('/auth/signup', signUp);
router.post('/auth/sign-up', signUp);
router.post('/auth/register', signUp);
router.post('/auth/create-account', signUp);

router.post('/auth/login', signIn);
router.post('/auth/signin', signIn);
router.post('/auth/sign-in', signIn);

router.get('/auth/me', getMe);
router.post('/auth/logout', signOut);
router.post('/auth/signout', signOut);
router.post('/auth/refresh', refreshToken);

// Pandit / Astrologer authentication
router.post('/auth/pandit-login', panditLogin);

// ==========================================
// USER PROFILE APIS
// ==========================================
router.get('/user/profile', getUserProfile);
router.put('/user/profile', updateUserProfile);

// ==========================================
// PANDIT / ASTROLOGER MANAGEMENT APIS
// ==========================================
router.get('/pandit/profile', getPanditProfile);
router.put('/pandit/status', updatePanditStatus);
router.get('/pandit/earnings/:id', getPanditEarnings);
router.get('/pandit/sessions/:id', getPanditSessions);

// ==========================================
// ASTROLOGERS MARKETPLACE APIS
// ==========================================
router.get('/astrologers', getAstrologers);
router.get('/astrologers/:id', getAstrologerById);

// ==========================================
// WALLET & LEDGER APIS
// ==========================================
router.get('/wallet/balance', getWalletBalance);
router.post('/wallet/recharge', rechargeWallet);
router.get('/wallet/transactions', getTransactions);

// ==========================================
// CONSULTATIONS & CHAT HISTORY
// ==========================================
router.get('/consultations/history', getConsultationHistory);
router.get('/consultations/:id/messages', getConsultationMessages);

// ==========================================
// ASTROLOGY TOOLS
// ==========================================
router.get('/astrology/horoscopes', getAllHoroscopes);
router.get('/astrology/horoscope', getHoroscope);
router.post('/astrology/kundli', generateKundli);

export default router;
