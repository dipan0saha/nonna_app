DO $$ 
DECLARE
    v_user_id uuid;
    v_oliver_id uuid;
    v_amelia_id uuid;
BEGIN
    -- Find the primary user to own the records
    SELECT id INTO v_user_id FROM auth.users WHERE email = 'dipan.saha@gmail.com' LIMIT 1;
    
    IF v_user_id IS NULL THEN
        SELECT id INTO v_user_id FROM auth.users ORDER BY created_at LIMIT 1;
    END IF;

    IF v_user_id IS NULL THEN
        RAISE NOTICE 'No auth user found. Skipping sample data creation.';
        RETURN;
    END IF;

    -- Resolve Oliver
    SELECT id INTO v_oliver_id FROM baby_profiles WHERE name = 'Oliver' LIMIT 1;
    IF v_oliver_id IS NULL THEN
        INSERT INTO baby_profiles (name, expected_birth_date, gender, created_by)
        VALUES ('Oliver', CURRENT_DATE - INTERVAL '3 months', 'male', v_user_id)
        RETURNING id INTO v_oliver_id;
        
        INSERT INTO baby_memberships (baby_profile_id, user_id, role, relationship_label)
        VALUES (v_oliver_id, v_user_id, 'owner', 'Parent');
    END IF;

    -- Resolve Amelia
    SELECT id INTO v_amelia_id FROM baby_profiles WHERE name = 'Amelia' LIMIT 1;
    IF v_amelia_id IS NULL THEN
        INSERT INTO baby_profiles (name, expected_birth_date, gender, created_by)
        VALUES ('Amelia', CURRENT_DATE + INTERVAL '1 month', 'female', v_user_id)
        RETURNING id INTO v_amelia_id;

        INSERT INTO baby_memberships (baby_profile_id, user_id, role, relationship_label)
        VALUES (v_amelia_id, v_user_id, 'owner', 'Parent');
    END IF;

    -- --- Insert Sample Photos ---
    INSERT INTO photos (baby_profile_id, uploaded_by_user_id, storage_path, caption)
    SELECT v_oliver_id, v_user_id, 'https://picsum.photos/seed/oliver_new1/400/400', 'Oliver playing with blocks'
    WHERE NOT EXISTS (SELECT 1 FROM photos WHERE storage_path = 'https://picsum.photos/seed/oliver_new1/400/400');

    INSERT INTO photos (baby_profile_id, uploaded_by_user_id, storage_path, caption)
    SELECT v_oliver_id, v_user_id, 'https://picsum.photos/seed/oliver_new2/400/400', 'First steps!'
    WHERE NOT EXISTS (SELECT 1 FROM photos WHERE storage_path = 'https://picsum.photos/seed/oliver_new2/400/400');

    INSERT INTO photos (baby_profile_id, uploaded_by_user_id, storage_path, caption)
    SELECT v_amelia_id, v_user_id, 'https://picsum.photos/seed/amelia_new1/400/400', 'Amelia at the park'
    WHERE NOT EXISTS (SELECT 1 FROM photos WHERE storage_path = 'https://picsum.photos/seed/amelia_new1/400/400');
    
    INSERT INTO photos (baby_profile_id, uploaded_by_user_id, storage_path, caption)
    SELECT v_amelia_id, v_user_id, 'https://picsum.photos/seed/amelia_new2/400/400', 'Smiling Amelia'
    WHERE NOT EXISTS (SELECT 1 FROM photos WHERE storage_path = 'https://picsum.photos/seed/amelia_new2/400/400');

    -- --- Insert Sample Events ---
    INSERT INTO events (baby_profile_id, created_by_user_id, title, starts_at, ends_at, description, location)
    SELECT v_oliver_id, v_user_id, 'Oliver 100 Days Celebration', NOW() + INTERVAL '7 days', NOW() + INTERVAL '7 days 4 hours', 'A small gathering to celebrate 100 days of Oliver.', 'Local Park'
    WHERE NOT EXISTS (SELECT 1 FROM events WHERE title = 'Oliver 100 Days Celebration');

    INSERT INTO events (baby_profile_id, created_by_user_id, title, starts_at, ends_at, description, location)
    SELECT v_amelia_id, v_user_id, 'Amelia Baby Shower', NOW() + INTERVAL '14 days', NOW() + INTERVAL '14 days 3 hours', 'Celebrating the upcoming arrival of Amelia!', 'Grandma''s House'
    WHERE NOT EXISTS (SELECT 1 FROM events WHERE title = 'Amelia Baby Shower');

    -- --- Insert Registry Items ---
    INSERT INTO registry_items (baby_profile_id, created_by_user_id, name, description, link_url, priority)
    SELECT v_oliver_id, v_user_id, 'Baby Stroller', 'A nice compact baby stroller.', 'https://amazon.com/sample', 5
    WHERE NOT EXISTS (SELECT 1 FROM registry_items WHERE name = 'Baby Stroller');

    INSERT INTO registry_items (baby_profile_id, created_by_user_id, name, description, link_url, priority)
    SELECT v_amelia_id, v_user_id, 'Crib Mattress', 'Firm and safe crib mattress.', 'https://amazon.com/sample2', 4
    WHERE NOT EXISTS (SELECT 1 FROM registry_items WHERE name = 'Crib Mattress');

    -- --- Insert Sample Notifications ---
    INSERT INTO notifications (recipient_user_id, baby_profile_id, type, payload)
    SELECT v_user_id, v_oliver_id, 'event_invite', '{"message": "You have been invited to Oliver 100 Days Celebration!"}'::jsonb
    WHERE NOT EXISTS (SELECT 1 FROM notifications WHERE type = 'event_invite' AND baby_profile_id = v_oliver_id);

    INSERT INTO notifications (recipient_user_id, baby_profile_id, type, payload)
    SELECT v_user_id, v_amelia_id, 'registry_update', '{"message": "A new item was added to Amelia''s registry."}'::jsonb
    WHERE NOT EXISTS (SELECT 1 FROM notifications WHERE type = 'registry_update' AND baby_profile_id = v_amelia_id);

END $$;
