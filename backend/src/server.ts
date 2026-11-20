import express from 'express';
import http from 'http';
import cors from 'cors';
import { WebSocketServer } from 'ws';
import { ENV } from './config/env.js';
import routes from './routes/index.js';
import { setupConsultationSockets } from './sockets/consultation.socket.js';

const app = express();
const server = http.createServer(app);

// Enable CORS and JSON parsing
app.use(cors({ origin: '*' }));
app.use(express.json());

// Comprehensive HTTP Request Logger for Debugging
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[HTTP ${req.method}] ${req.originalUrl || req.url} -> ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Rini Pandit Astrology API & WebSocket Gateway',
    timestamp: new Date(),
  });
});

// API Routes mounted on both /api and / for maximum endpoint compatibility
app.use('/api', routes);
app.use('/', routes);

// WebSocket Server for Consultation & Realtime Billing
const wss = new WebSocketServer({ server, path: '/ws/consultation' });
setupConsultationSockets(wss);

server.listen(ENV.PORT, () => {
  console.log(`=======================================================`);
  console.log(`🔮 RINI PANDIT ASTROLOGY SERVER RUNNING`);
  console.log(`🚀 HTTP REST API: http://localhost:${ENV.PORT}/api`);
  console.log(`⚡ WebSocket URL: ws://localhost:${ENV.PORT}/ws/consultation`);
  console.log(`=======================================================`);
});
