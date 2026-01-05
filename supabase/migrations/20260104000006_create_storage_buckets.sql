-- ============================================================================
-- Migration: 20260105084209_create_storage_buckets.sql
-- Description: Create storage buckets and RLS policies for Nonna App
-- ============================================================================
-- Bucket 1: user-avatars (Public)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'user-avatars') THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'user-avatars',
            'user-avatars',
            true,
            5242880, -- 5MB in bytes
            ARRAY['image/jpeg', 'image/png', 'image/webp']
        );
    END IF;
END $$;

-- Bucket 2: baby-profile-photos (Public)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'baby-profile-photos') THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'baby-profile-photos',
            'baby-profile-photos',
            true,
            5242880, -- 5MB in bytes
            ARRAY['image/jpeg', 'image/png', 'image/webp']
        );
    END IF;
END $$;

-- Bucket 3: gallery-photos (Private with RLS)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'gallery-photos') THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'gallery-photos',
            'gallery-photos',
            false, -- Private
            10485760, -- 10MB in bytes
            ARRAY['image/jpeg', 'image/png']
        );
    END IF;
END $$;

-- Bucket 4: event-photos (Private with RLS)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'event-photos') THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'event-photos',
            'event-photos',
            false, -- Private
            10485760, -- 10MB in bytes
            ARRAY['image/jpeg', 'image/png']
        );
    END IF;
END $$;


-- ============================================================================
-- SECTION 2: Row-Level Security (RLS) Policies for Storage Buckets
-- ============================================================================
-- Bucket 1: user-avatars (Public)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow public read on user-avatars') THEN
        CREATE POLICY "Allow public read on user-avatars" ON storage.objects
        FOR SELECT USING (bucket_id = 'user-avatars');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated insert on user-avatars') THEN
        CREATE POLICY "Allow authenticated insert on user-avatars" ON storage.objects
        FOR INSERT WITH CHECK (bucket_id = 'user-avatars' AND auth.role() = 'authenticated');
    END IF;
END $$;

-- Bucket 2: baby-profile-photos (Public)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow public read on baby-profile-photos') THEN
        CREATE POLICY "Allow public read on baby-profile-photos" ON storage.objects
        FOR SELECT USING (bucket_id = 'baby-profile-photos');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated insert on baby-profile-photos') THEN
        CREATE POLICY "Allow authenticated insert on baby-profile-photos" ON storage.objects
        FOR INSERT WITH CHECK (bucket_id = 'baby-profile-photos' AND auth.role() = 'authenticated');
    END IF;
END $$;

-- Bucket 3: gallery-photos (Private)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated read on gallery-photos') THEN
        CREATE POLICY "Allow authenticated read on gallery-photos" ON storage.objects
        FOR SELECT USING (bucket_id = 'gallery-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated insert on gallery-photos') THEN
        CREATE POLICY "Allow authenticated insert on gallery-photos" ON storage.objects
        FOR INSERT WITH CHECK (bucket_id = 'gallery-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated update on gallery-photos') THEN
        CREATE POLICY "Allow authenticated update on gallery-photos" ON storage.objects
        FOR UPDATE USING (bucket_id = 'gallery-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated delete on gallery-photos') THEN
        CREATE POLICY "Allow authenticated delete on gallery-photos" ON storage.objects
        FOR DELETE USING (bucket_id = 'gallery-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

-- Bucket 4: event-photos (Private)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated read on event-photos') THEN
        CREATE POLICY "Allow authenticated read on event-photos" ON storage.objects
        FOR SELECT USING (bucket_id = 'event-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated insert on event-photos') THEN
        CREATE POLICY "Allow authenticated insert on event-photos" ON storage.objects
        FOR INSERT WITH CHECK (bucket_id = 'event-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated update on event-photos') THEN
        CREATE POLICY "Allow authenticated update on event-photos" ON storage.objects
        FOR UPDATE USING (bucket_id = 'event-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND policyname = 'Allow authenticated delete on event-photos') THEN
        CREATE POLICY "Allow authenticated delete on event-photos" ON storage.objects
        FOR DELETE USING (bucket_id = 'event-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
    END IF;
END $$;
