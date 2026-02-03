-- ========================================
-- Force Update Mechanism - App Versions Table
-- ========================================
-- Purpose: Store minimum required app versions per platform for force update mechanism
-- Date: 2026-02-03

-- Table: app_versions
-- Stores minimum required versions and store URLs for each platform
CREATE TABLE IF NOT EXISTS public.app_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  platform TEXT NOT NULL UNIQUE CHECK (platform IN ('android', 'ios', 'macos', 'windows', 'linux', 'web')),
  minimum_version TEXT NOT NULL,
  store_url TEXT,
  release_notes TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index on platform for faster lookups
CREATE INDEX IF NOT EXISTS idx_app_versions_platform ON public.app_versions(platform);

-- Create index on active versions
CREATE INDEX IF NOT EXISTS idx_app_versions_active ON public.app_versions(is_active) WHERE is_active = true;

-- Enable RLS
ALTER TABLE public.app_versions ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Allow all authenticated users to read app versions
CREATE POLICY "Allow authenticated users to read app versions"
  ON public.app_versions
  FOR SELECT
  TO authenticated
  USING (true);

-- RLS Policy: Allow public access to app versions (for version check before login)
CREATE POLICY "Allow public read access to app versions"
  ON public.app_versions
  FOR SELECT
  TO anon
  USING (is_active = true);

-- Insert default values for each platform
INSERT INTO public.app_versions (platform, minimum_version, store_url, release_notes) VALUES
  ('android', '1.0.0', 'https://play.google.com/store/apps/details?id=com.example.nonna', 'Initial release'),
  ('ios', '1.0.0', 'https://apps.apple.com/app/id123456789', 'Initial release'),
  ('macos', '1.0.0', 'https://apps.apple.com/app/id123456789', 'Initial release'),
  ('windows', '1.0.0', 'https://www.microsoft.com/store/apps/windows', 'Initial release'),
  ('linux', '1.0.0', '', 'Initial release'),
  ('web', '1.0.0', '', 'Initial release')
ON CONFLICT (platform) DO NOTHING;

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_app_versions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER app_versions_updated_at
  BEFORE UPDATE ON public.app_versions
  FOR EACH ROW
  EXECUTE FUNCTION update_app_versions_updated_at();

-- Add comment to table
COMMENT ON TABLE public.app_versions IS 'Stores minimum required app versions per platform for force update mechanism';
COMMENT ON COLUMN public.app_versions.platform IS 'Target platform (android, ios, macos, windows, linux, web)';
COMMENT ON COLUMN public.app_versions.minimum_version IS 'Minimum app version required (semantic versioning)';
COMMENT ON COLUMN public.app_versions.store_url IS 'App store URL for the platform';
COMMENT ON COLUMN public.app_versions.release_notes IS 'Release notes for the version';
COMMENT ON COLUMN public.app_versions.is_active IS 'Whether this version configuration is active';
