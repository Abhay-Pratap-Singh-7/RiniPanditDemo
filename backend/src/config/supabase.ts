import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { ENV } from './env.js';

let supabase: SupabaseClient | null = null;

if (ENV.SUPABASE_URL && (ENV.SUPABASE_SERVICE_ROLE_KEY || ENV.SUPABASE_ANON_KEY)) {
  const key = ENV.SUPABASE_SERVICE_ROLE_KEY || ENV.SUPABASE_ANON_KEY;
  supabase = createClient(ENV.SUPABASE_URL, key, {
    auth: { persistSession: false },
  });
  console.log('[Supabase] Initialized with remote endpoint:', ENV.SUPABASE_URL);
} else {
  console.log('[Supabase] No remote credentials found. Running in hybrid local memory mode.');
}

export { supabase };
