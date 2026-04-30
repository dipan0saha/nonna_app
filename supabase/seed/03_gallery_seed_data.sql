DO $$ 
DECLARE
  v_user_id uuid;
  v_follower_id uuid;
  v_baby1_id uuid;

  -- Generate specific UUIDs for photos so we can reliably add comments/squishes
  v_photo1_id uuid := gen_random_uuid();
  v_photo2_id uuid := gen_random_uuid();
  v_photo3_id uuid := gen_random_uuid();
  v_photo4_id uuid := gen_random_uuid();
  v_photo5_id uuid := gen_random_uuid();
  v_photo6_id uuid := gen_random_uuid();
  v_photo7_id uuid := gen_random_uuid();
  v_photo8_id uuid := gen_random_uuid();
BEGIN
  -- 1. Identify users and baby profiles
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'dipan.saha@gmail.com' LIMIT 1;
  IF v_user_id IS NULL THEN
     RAISE NOTICE 'Target user dipan.saha@gmail.com not found. Skipping gallery seed.';
     RETURN;
  END IF;

  SELECT baby_profile_id INTO v_baby1_id FROM baby_memberships WHERE user_id = v_user_id LIMIT 1;
  IF v_baby1_id IS NULL THEN
     RAISE NOTICE 'No baby profiles found for the target user. Skipping gallery seed.';
     RETURN;
  END IF;

  -- Create a dummy follower user if not exists
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'aunt.mary@gmail.com') THEN
      SELECT id INTO v_follower_id FROM auth.users WHERE email != 'dipan.saha@gmail.com' LIMIT 1;
  ELSE
      SELECT id INTO v_follower_id FROM auth.users WHERE email = 'aunt.mary@gmail.com' LIMIT 1;
  END IF;

  IF v_follower_id IS NULL THEN
      v_follower_id := v_user_id; -- fallback
  END IF;

  -- 2. Insert Photos with various captions and tags
  INSERT INTO photos (id, baby_profile_id, uploaded_by_user_id, storage_path, caption, tags)
  VALUES 
    (v_photo1_id, v_baby1_id, v_user_id, 'https://images.unsplash.com/photo-1544126592-807ade215a0b?q=80&w=400', 'Bath time fun! 🛁🦆', ARRAY['bath', 'water', 'fun']),
    (v_photo2_id, v_baby1_id, v_user_id, 'https://images.unsplash.com/photo-1519689680058-324335c77eba?q=80&w=400', 'First steps! We are so proud. 😊', ARRAY['first_steps', 'milestone']),
    (v_photo3_id, v_baby1_id, v_follower_id, 'https://images.unsplash.com/photo-1511295742362-92c96b12a3d1?q=80&w=400', 'Sleeping like an angel 😴💤', ARRAY['sleep', 'nap']),
    (v_photo4_id, v_baby1_id, v_user_id, 'https://images.unsplash.com/photo-1522771731478-44bf1051126a?q=80&w=400', 'Eating solid food for the first time! 🥕', ARRAY['food', 'messy']),
    (v_photo5_id, v_baby1_id, v_follower_id, 'https://images.unsplash.com/photo-1492552181161-62217fc3076d?q=80&w=400', 'Playing in the park today 🌳☀️', ARRAY['park', 'outdoors']),
    (v_photo6_id, v_baby1_id, v_user_id, 'https://plus.unsplash.com/premium_photo-1661603525134-8fbdfa3dd317?q=80&w=400', 'Hanging out with grandma!', ARRAY['family', 'grandma']),
    (v_photo7_id, v_baby1_id, v_user_id, 'https://images.unsplash.com/photo-1503454537195-1dc534825562?q=80&w=400', 'Tummy time! Look at that strong neck.', ARRAY['tummy_time']),
    (v_photo8_id, v_baby1_id, v_user_id, 'https://images.unsplash.com/photo-1555252136-114cb6d6cc99?q=80&w=400', 'Messy face after eating carrots! 😂', ARRAY['messy', 'food'])
  ON CONFLICT DO NOTHING;

  -- 3. Insert Photo Squishes (Likes)
  -- Give photo 2 a ton of squishes so it shows up in favorites
  INSERT INTO photo_squishes (id, photo_id, user_id) 
  VALUES 
    (gen_random_uuid(), v_photo2_id, v_follower_id), 
    (gen_random_uuid(), v_photo2_id, v_user_id),
    (gen_random_uuid(), v_photo4_id, v_user_id),
    (gen_random_uuid(), v_photo5_id, v_follower_id),
    (gen_random_uuid(), v_photo8_id, v_user_id),
    (gen_random_uuid(), v_photo8_id, v_follower_id)
  ON CONFLICT DO NOTHING;

  -- 4. Insert Photo Comments
  INSERT INTO photo_comments (id, photo_id, user_id, body)
  VALUES 
    (gen_random_uuid(), v_photo2_id, v_follower_id, 'Oh my goodness, they are walking already?!'),
    (gen_random_uuid(), v_photo2_id, v_user_id, 'I know, right? Time flies!'),
    (gen_random_uuid(), v_photo4_id, v_follower_id, 'Hahaha the carrot face is classic!'),
    (gen_random_uuid(), v_photo8_id, v_user_id, 'Such a beautiful mess!'),
    (gen_random_uuid(), v_photo5_id, v_follower_id, 'Love the outfit you picked for the park.')
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'Successfully seeded gallery images for testing.';
END $$;