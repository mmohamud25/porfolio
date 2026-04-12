-- ============================================================
-- SUPABASE UPDATE FOR mmohamud.me
-- Run this in Supabase → SQL Editor → Run
-- Safe to run multiple times (IF NOT EXISTS / IF EXISTS guards)
-- ============================================================

-- ── BLOGS TABLE: add scheduling support ──
ALTER TABLE blogs ADD COLUMN IF NOT EXISTS scheduled_at timestamptz;
ALTER TABLE blogs ADD COLUMN IF NOT EXISTS tags text;
ALTER TABLE blogs ADD COLUMN IF NOT EXISTS status text DEFAULT 'published';
ALTER TABLE blogs ADD COLUMN IF NOT EXISTS views integer DEFAULT 0;
ALTER TABLE blogs ADD COLUMN IF NOT EXISTS image_url text;

-- ── COMMENTS TABLE: add admin reply support ──
ALTER TABLE comments ADD COLUMN IF NOT EXISTS admin_reply text;
ALTER TABLE comments ADD COLUMN IF NOT EXISTS replied_at timestamptz;

-- ── PROJECTS TABLE: add tags ──
ALTER TABLE projects ADD COLUMN IF NOT EXISTS tags text;

-- ── IMAGES TABLE: image library ──
CREATE TABLE IF NOT EXISTS images (
  id         uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  name       text,
  url        text,
  data       text,
  size_kb    integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE images ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_all_images" ON images;
CREATE POLICY "anon_all_images" ON images FOR ALL USING (true) WITH CHECK (true);

-- ── SNIPPETS TABLE: reusable content blocks ──
CREATE TABLE IF NOT EXISTS snippets (
  id         uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  name       text NOT NULL,
  content    text NOT NULL,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE snippets ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_all_snippets" ON snippets;
CREATE POLICY "anon_all_snippets" ON snippets FOR ALL USING (true) WITH CHECK (true);

-- ── SETTINGS TABLE: global site settings (email notifs etc) ──
CREATE TABLE IF NOT EXISTS site_settings (
  key   text PRIMARY KEY,
  value text
);
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_all_settings" ON site_settings;
CREATE POLICY "anon_all_settings" ON site_settings FOR ALL USING (true) WITH CHECK (true);

-- ── Default settings ──
INSERT INTO site_settings (key,value) VALUES ('notify_email','false') ON CONFLICT (key) DO NOTHING;
INSERT INTO site_settings (key,value) VALUES ('notify_endpoint','https://formspree.io/f/xyknjrdo') ON CONFLICT (key) DO NOTHING;

-- ── Fix any NULL status rows ──
UPDATE blogs SET status='published' WHERE status IS NULL;
UPDATE comments SET status='pending' WHERE status IS NULL;

-- ── Reload schema cache ──
NOTIFY pgrst, 'reload schema';

-- ── Confirm all columns ──
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('blogs','comments','projects','images','snippets','site_settings')
ORDER BY table_name, ordinal_position;
