-- ============================================================
-- SUPABASE SETUP FOR mmohamud.me
-- Run this entire file in: Supabase → SQL Editor → Run
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROJECTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS projects (
  id          uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  title       text NOT NULL,
  description text,
  category    text DEFAULT 'cybersecurity',
  role        text,
  problem     text,
  process     text,
  impact      text,
  skills      text,
  tags        text,
  live_link   text,
  github_link text,
  youtube_id  text,
  image_url   text,
  featured    boolean DEFAULT false,
  views       integer DEFAULT 0,
  date        text,
  created_at  timestamptz DEFAULT now()
);

-- ============================================================
-- BLOGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS blogs (
  id         uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  title      text NOT NULL,
  excerpt    text,
  content    text,
  category   text DEFAULT 'Cybersecurity',
  tags       text,
  image_url  text,
  date       text,
  status     text DEFAULT 'published',
  views      integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- ============================================================
-- COMMENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS comments (
  id         uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  blog_id    text NOT NULL,
  name       text NOT NULL,
  email      text NOT NULL,
  content    text NOT NULL,
  status     text DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE blogs    ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies first to avoid conflicts on re-run
DROP POLICY IF EXISTS "anon_select_projects"  ON projects;
DROP POLICY IF EXISTS "anon_insert_projects"  ON projects;
DROP POLICY IF EXISTS "anon_update_projects"  ON projects;
DROP POLICY IF EXISTS "anon_delete_projects"  ON projects;

DROP POLICY IF EXISTS "anon_select_blogs"     ON blogs;
DROP POLICY IF EXISTS "anon_insert_blogs"     ON blogs;
DROP POLICY IF EXISTS "anon_update_blogs"     ON blogs;
DROP POLICY IF EXISTS "anon_delete_blogs"     ON blogs;

DROP POLICY IF EXISTS "anon_select_comments"  ON comments;
DROP POLICY IF EXISTS "anon_insert_comments"  ON comments;
DROP POLICY IF EXISTS "anon_update_comments"  ON comments;
DROP POLICY IF EXISTS "anon_delete_comments"  ON comments;

-- PROJECTS policies
CREATE POLICY "anon_select_projects" ON projects FOR SELECT USING (true);
CREATE POLICY "anon_insert_projects" ON projects FOR INSERT WITH CHECK (true);
CREATE POLICY "anon_update_projects" ON projects FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "anon_delete_projects" ON projects FOR DELETE USING (true);

-- BLOGS policies
CREATE POLICY "anon_select_blogs"    ON blogs FOR SELECT USING (true);
CREATE POLICY "anon_insert_blogs"    ON blogs FOR INSERT WITH CHECK (true);
CREATE POLICY "anon_update_blogs"    ON blogs FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "anon_delete_blogs"    ON blogs FOR DELETE USING (true);

-- COMMENTS policies
-- Public can only read approved comments
CREATE POLICY "anon_select_comments" ON comments FOR SELECT USING (status = 'approved');
-- Anyone can submit a comment (goes to pending)
CREATE POLICY "anon_insert_comments" ON comments FOR INSERT WITH CHECK (true);
-- Admin updates status (approve/reject)
CREATE POLICY "anon_update_comments" ON comments FOR UPDATE USING (true) WITH CHECK (true);
-- Admin can delete comments
CREATE POLICY "anon_delete_comments" ON comments FOR DELETE USING (true);

-- ============================================================
-- VIEW INCREMENT FUNCTIONS
-- These let the site safely increment view counts
-- ============================================================
CREATE OR REPLACE FUNCTION increment_projects_views(row_id uuid)
RETURNS void
LANGUAGE sql
AS $$
  UPDATE projects SET views = COALESCE(views, 0) + 1 WHERE id = row_id;
$$;

CREATE OR REPLACE FUNCTION increment_blogs_views(row_id uuid)
RETURNS void
LANGUAGE sql
AS $$
  UPDATE blogs SET views = COALESCE(views, 0) + 1 WHERE id = row_id;
$$;

-- ============================================================
-- DONE
-- After running this:
-- 1. Go to Supabase → Table Editor and confirm
--    projects, blogs, comments tables exist
-- 2. Your site will now read and write data correctly
-- ============================================================
