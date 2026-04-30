DO $$ 
DECLARE
  v_user_id uuid;
  v_baby1_id uuid;
  v_baby2_id uuid;
  v_follower_id uuid;
  v_item1_id uuid := gen_random_uuid();
  v_item2_id uuid := gen_random_uuid();
  v_item3_id uuid := gen_random_uuid();
  v_event1_id uuid := gen_random_uuid();
  v_event2_id uuid := gen_random_uuid();
  v_photo1_id uuid := gen_random_uuid();
  v_photo2_id uuid := gen_random_uuid();
BEGIN
  -- Get active developer user
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'dipan.saha@gmail.com' LIMIT 1;
  IF v_user_id IS NULL THEN
     RAISE NOTICE 'Target user dipan.saha@gmail.com not found. Skipping seed.';
     RETURN;
  END IF;

  -- Create a dummy follower user if not exists
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'aunt.mary@gmail.com') THEN
      SELECT id INTO v_follower_id FROM auth.users WHERE email != 'dipan.saha@gmail.com' LIMIT 1;
  ELSE
      SELECT id INTO v_follower_id FROM auth.users WHERE email = 'aunt.mary@gmail.com' LIMIT 1;
  END IF;

  IF v_follower_id IS NULL THEN
      v_follower_id := v_user_id;
  END IF;

  -- Get baby profiles via memberships
  SELECT baby_profile_id INTO v_baby1_id FROM baby_memberships WHERE user_id = v_user_id LIMIT 1;
  IF v_baby1_id IS NULL THEN
     RAISE NOTICE 'No baby profiles found for the target user.';
     RETURN;
  END IF;

  -- 1. REGISTRY ITEMS & PURCHASES (For Highlights, Deals, and Recent Purchases)
  INSERT INTO registry_items (id, baby_profile_id, created_by_user_id, name, description, priority, link_url)
  VALUES 
    (v_item1_id, v_baby1_id, v_user_id, 'Premium Stroller System', 'The best stroller in the market with 4-wheel suspension.', 5, 'https://amazon.com/stroller'),
    (v_item2_id, v_baby1_id, v_user_id, 'Organic Cotton Swaddles', 'Soft packs of 5.', 3, 'https://amazon.com/swaddle'),
    (v_item3_id, v_baby1_id, v_user_id, 'High-Tech Baby Monitor', 'Wi-Fi enabled 1080p camera monitor.', 4, 'https://amazon.com/monitor')
  ON CONFLICT DO NOTHING;

  INSERT INTO registry_purchases (id, registry_item_id, purchased_by_user_id, note)
  VALUES (gen_random_uuid(), v_item2_id, v_follower_id, 'So excited for the baby!')
  ON CONFLICT DO NOTHING;

  -- 2. EVENTS & RSVPs (For UpcomingEvents, RsvpTasks)
  INSERT INTO events (id, baby_profile_id, created_by_user_id, title, description, starts_at, ends_at, location)
  VALUES 
    (v_event1_id, v_baby1_id, v_user_id, 'Virtual Baby Shower', 'Join us on Zoom!', NOW() + INTERVAL '7 days', NOW() + INTERVAL '7 days 2 hours', 'Zoom Link: xyz'),
    (v_event2_id, v_baby1_id, v_user_id, 'Gender Reveal Party', 'Come over to our backyard', NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days 4 hours', 'Our House')
  ON CONFLICT DO NOTHING;

  INSERT INTO event_rsvps (id, event_id, user_id, status)
  VALUES 
    (gen_random_uuid(), v_event1_id, v_user_id, 'yes'),
    (gen_random_uuid(), v_event2_id, v_follower_id, 'maybe')
  ON CONFLICT DO NOTHING;

  -- 3. PHOTOS & SQUISHES (For RecentPhotos, GalleryFavorites)
  INSERT INTO photos (id, baby_profile_id, uploaded_by_user_id, storage_path, caption)
  VALUES 
    (v_photo1_id, v_baby1_id, v_user_id, 'https://images.unsplash.com/photo-1519689680058-324335c77eba', 'Morning smiles! 😊'),
    (v_photo2_id, v_baby1_id, v_user_id, 'https://images.unsplash.com/photo-1522771731478-44bf1051126a', 'First time sitting up!')
  ON CONFLICT DO NOTHING;

  INSERT INTO photo_squishes (id, photo_id, user_id) 
  VALUES 
    (gen_random_uuid(), v_photo1_id, v_follower_id), 
    (gen_random_uuid(), v_photo2_id, v_user_id)
  ON CONFLICT DO NOTHING;

  -- 4. INVITATIONS (For InvitesStatusTile)
  INSERT INTO invitations (id, baby_profile_id, invited_by_user_id, invitee_email, token_hash, expires_at, status)
  VALUES 
    (gen_random_uuid(), v_baby1_id, v_user_id, 'grandma@gmail.com', gen_random_uuid()::text, NOW() + INTERVAL '5 days', 'pending'),
    (gen_random_uuid(), v_baby1_id, v_user_id, 'uncle@gmail.com', gen_random_uuid()::text, NOW() - INTERVAL '1 days', 'expired'),
    (gen_random_uuid(), v_baby1_id, v_user_id, 'cousin@gmail.com', gen_random_uuid()::text, NOW() + INTERVAL '5 days', 'accepted')
  ON CONFLICT DO NOTHING;

  -- 5. NOTIFICATIONS
  INSERT INTO notifications (id, recipient_user_id, baby_profile_id, type, payload)
  VALUES 
    (gen_random_uuid(), v_user_id, v_baby1_id, 'system', '{"title": "Welcome to Nonna App!", "body": "Start capturing memories today."}'),
    (gen_random_uuid(), v_user_id, v_baby1_id, 'photo_comment', '{"title": "New Comment", "body": "Aunt Mary commented on your photo."}'),
    (gen_random_uuid(), v_user_id, v_baby1_id, 'registry_purchase', '{"title": "Registry Updated", "body": "Someone just purchased the Organic Cotton Swaddles!"}')
  ON CONFLICT DO NOTHING;

  -- 6. ACTIVITY EVENTS (For ActivityListTile)
  INSERT INTO activity_events (id, baby_profile_id, actor_user_id, type, payload)
  VALUES 
    (gen_random_uuid(), v_baby1_id, v_follower_id, 'squish', ('{"entity_id": "' || v_photo1_id || '", "entity_type": "photo", "title": "Liked a photo"}')::jsonb),
    (gen_random_uuid(), v_baby1_id, v_user_id, 'photo_upload', ('{"entity_id": "' || v_photo2_id || '", "entity_type": "photo", "title": "Uploaded a new photo"}')::jsonb),
    (gen_random_uuid(), v_baby1_id, v_user_id, 'create_event', ('{"entity_id": "' || v_event1_id || '", "entity_type": "event", "title": "Created Virtual Baby Shower"}')::jsonb)
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'Successfully seeded comprehensively for all UI Tiles.';
END $$;
