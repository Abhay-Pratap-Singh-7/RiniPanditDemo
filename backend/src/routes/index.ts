import { Router } from 'express';
import { getAstrologers, getAstrologerById } from '../controllers/astrologers.controller.js';
import { getUserProfile, updateUserProfile, mockLogin } from '../controllers/user.controller.js';
import { getWalletBalance, rechargeWallet, getTransactions } from '../controllers/wallet.controller.js';
import { getConsultationHistory, getConsultationMessages } from '../controllers/consultations.controller.js';
import { getHoroscope, generateKundli } from '../controllers/astrology.controller.js';

const router = Router();

// Auth & User Routes
router.post('/auth/login', mockLogin);
router.get('/user/profile', getUserProfile);
router.put('/user/profile', updateUserProfile);

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
router.get('/astrology/horoscope', getHoroscope);
router.post('/astrology/kundli', generateKundli);

export default router;
