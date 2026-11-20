import { Router } from 'express';
import { getAstrologers, getAstrologerById } from '../controllers/astrologers.controller.js';
import { getUserProfile, updateUserProfile, mockLogin } from '../controllers/user.controller.js';
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

// Auth & User Routes
router.post('/auth/login', mockLogin);
router.post('/auth/pandit-login', panditLogin);
router.get('/user/profile', getUserProfile);
router.put('/user/profile', updateUserProfile);

// Pandit / Astrologer Dashboard & Management
router.get('/pandit/profile', getPanditProfile);
router.put('/pandit/status', updatePanditStatus);
router.get('/pandit/earnings/:id', getPanditEarnings);
router.get('/pandit/sessions/:id', getPanditSessions);

// Astrologers Marketplace
router.get('/astrologers', getAstrologers);
router.get('/astrologers/:id', getAstrologerById);

// Wallet Ledger & Recharge
router.get('/wallet/balance', getWalletBalance);
router.post('/wallet/recharge', rechargeWallet);
router.get('/wallet/transactions', getTransactions);

// Consultations & Chat Logs
router.get('/consultations/history', getConsultationHistory);
router.get('/consultations/:id/messages', getConsultationMessages);

// Astrology Tools
router.get('/astrology/horoscopes', getAllHoroscopes);
router.get('/astrology/horoscope', getHoroscope);
router.post('/astrology/kundli', generateKundli);

export default router;
