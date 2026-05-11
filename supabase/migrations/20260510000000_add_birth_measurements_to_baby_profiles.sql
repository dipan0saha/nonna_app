-- Migration: Add birth weight and height to baby_profiles
-- Date: 2026-05-10
-- Purpose: Support the NewBabyWelcomeTile which displays birth stats
--          (weight in kg, height in cm) on the owner home screen
--          for 7 days after the actual birth date.

ALTER TABLE baby_profiles
  ADD COLUMN IF NOT EXISTS birth_weight_kg NUMERIC(5, 3) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS birth_height_cm NUMERIC(5, 1) DEFAULT NULL;

COMMENT ON COLUMN baby_profiles.birth_weight_kg IS 'Birth weight in kilograms (e.g. 3.450)';
COMMENT ON COLUMN baby_profiles.birth_height_cm IS 'Birth height/length in centimetres (e.g. 51.0)';
