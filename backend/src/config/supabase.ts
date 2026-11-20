import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { ENV } from './env.js';

let supabase: SupabaseClient | null = null;
let supabaseAdmin: SupabaseClient | null = null;

const serviceKey = ENV.SUPABASE_SERVICE_ROLE_KEY || ENV.SUPABASE_ANON_KEY;

if (ENV.SUPABASE_URL && serviceKey) {
  supabase = createClient(ENV.SUPABASE_URL, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  supabaseAdmin = supabase;
  console.log('[Supabase] Initialized successfully with endpoint:', ENV.SUPABASE_URL);
} else {
  console.log('[Supabase] No remote credentials found. Running in hybrid local memory mode.');
}

export { supabase, supabaseAdmin };
