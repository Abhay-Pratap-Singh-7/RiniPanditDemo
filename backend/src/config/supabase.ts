import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { ENV } from './env.js';

let supabase: SupabaseClient | null = null;
let supabaseAdmin: SupabaseClient | null = null;

if (ENV.SUPABASE_URL && ENV.SUPABASE_ANON_KEY) {
  supabase = createClient(ENV.SUPABASE_URL, ENV.SUPABASE_ANON_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  console.log('[Supabase] Initialized client successfully with anon key.');
}

if (ENV.SUPABASE_URL && ENV.SUPABASE_SERVICE_ROLE_KEY) {
  supabaseAdmin = createClient(ENV.SUPABASE_URL, ENV.SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  console.log('[Supabase] Initialized admin client with service role key.');
} else if (supabase) {
  supabaseAdmin = supabase;
}

export { supabase, supabaseAdmin };
