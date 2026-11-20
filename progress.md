# Rini Pandit Demo - Implementation Progress

## 1. Supabase & Database Layer
- [x] **1.1 Database Schema Initialization**
  - [x] Execute UUID extension and custom enum types (`session_type`, `session_status`, `tx_type`)
  - [x] Create `profiles` table with birth detail fields (`dob`, `tob`, `pob_city`, `wallet_balance`)
  - [x] Create `astrologers` table with specialties, rate per minute, and rating
  - [x] Create `consultations` table for session tracking
  - [x] Create `chat_messages` table for consultation message logs
  - [x] Create `wallet_transactions` ledger table
- [x] **1.2 Supabase Storage & Security**
  - [x] Configure avatars and document storage bucket
  - [x] Apply Row-Level Security (RLS) policies for user data isolation
- [x] **1.3 Seed Data**
  - [x] Seed verified astrologers across categories (Vedic, Tarot, Numerology, Vastu)
  - [x] Seed test user accounts with pre-loaded mock wallet balance

---

## 2. Express.js Backend Architecture
- [ ] **2.1 Project Setup & Configuration**
  - [ ] Initialize Node.js + TypeScript environment (`package.json`, `tsconfig.json`)
  - [ ] Install dependencies (`express`, `ws`, `@supabase/supabase-js`, `zod`, `dotenv`, `cors`)
  - [ ] Configure Supabase Service Role client and environment loader
- [ ] **2.2 Middleware & Security**
  - [ ] JWT / Supabase Auth validation middleware
  - [ ] Error handler and request validation middleware
- [ ] **2.3 REST Endpoints**
  - [ ] `POST /api/auth/verify-token` — User session sync
  - [ ] `GET /api/user/profile` & `PUT /api/user/profile` — Fetch/update birth details & balance
  - [ ] `GET /api/astrologers` & `GET /api/astrologers/:id` — Listing with filters & detail view
  - [ ] `GET /api/wallet/balance` & `POST /api/wallet/recharge` — Mock wallet top-up & balance check
  - [ ] `GET /api/wallet/transactions` — Transaction history
  - [ ] `GET /api/consultations/history` & `GET /api/consultations/:id/messages` — Session & chat logs
  - [ ] `GET /api/astrology/horoscope` — Daily zodiac horoscope predictions
  - [ ] `POST /api/astrology/kundli` — Basic planetary & ascendant calculation engine
- [ ] **2.4 WebSocket & Realtime Engine**
  - [ ] Setup WebSocket server (`ws`) attached to HTTP server instance
  - [ ] Client connection authentication and `userId -> WebSocket` session registry
  - [ ] Event handler: `consultation:initiate` (with minimum balance validation)
  - [ ] Event handler: `consultation:accept` and `consultation:started`
  - [ ] Real-time per-minute billing worker (atomic wallet debit every 60s)
  - [ ] Insufficient balance detection and automatic session termination
  - [ ] Event handler: `chat:send` with message persistence and recipient dispatch
  - [ ] Event handler: `consultation:end` and summary calculation

---

## 3. Flutter Client Architecture
- [ ] **3.1 Project Scaffolding & Theme**
  - [ ] Flutter app initialization and package dependencies (`dio`, `web_socket_channel`, `supabase_flutter`, `provider`)
  - [ ] Unified Material 3 AppTheme implementation (Astro brand colors, typography, input & button styles)
  - [ ] Reusable core widgets (CustomButton, AstrologerCard, BalancePill, LoadingState, ErrorBanner)
- [ ] **3.2 Data Models & Network Layer**
  - [ ] Models: `UserProfile`, `Astrologer`, `ConsultationSession`, `ChatMessage`, `WalletTransaction`, `Horoscope`
  - [ ] REST API client with interceptors for auth tokens
  - [ ] WebSocket service manager with reconnect logic and stream broadcasting
- [ ] **3.3 Screens & UI Flow**
  - [ ] **Auth / Onboarding Screen**: Phone/OTP mock login & birth details input
  - [ ] **Home Dashboard**: Top banners, category selector (Vedic, Tarot, etc.), Daily Horoscope card, quick Kundli button
  - [ ] **Astrologer Marketplace**: Filterable list by specialty/rate, status badge (Online/Busy), detailed profile page
  - [ ] **Live Consultation Chat Screen**:
    - [ ] Real-time message list with bubble UI
    - [ ] Active call/chat header with live per-minute billing timer & balance counter
    - [ ] Input bar with send button
    - [ ] Low-balance warning alerts & end-call confirmation dialog
  - [ ] **Wallet Screen**: Current balance display, preset recharge options (₹100, ₹500, ₹1000), transaction history
  - [ ] **Free Astrology Tools**: Daily Horoscope screen & basic Kundli result view

---

## 4. End-to-End Testing & Verification
- [ ] Full consultation lifecycle test: Top-up wallet -> Select astrologer -> Initiate chat -> Timer debits balance -> End session
- [ ] Auto-cutoff verification when balance hits ₹0
- [ ] Disconnect & reconnect recovery during active consultation
- [ ] Backend & frontend build verification for demo presentation

---

## Milestone Status

| Phase | Description | Status |
| :--- | :--- | :--- |
| **Phase 1** | Requirements & System Architecture Specification | Completed |
| **Phase 2** | Supabase Setup & Database Schema Initialization | Completed |
| **Phase 3** | Express.js REST API & WebSocket Realtime Server | In Progress |
| **Phase 4** | Flutter App Theme, Components & Screens | Pending |
| **Phase 5** | End-to-End WebSocket Consultation & Billing Integration | Pending |
| **Phase 6** | Demo Hardening & Final Walkthrough | Pending |
