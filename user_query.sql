SELECT p.user_id, p.display_name, bp.id, bm.role
FROM profiles p
JOIN auth.users au ON p.user_id = au.id
LEFT JOIN baby_memberships bm ON p.user_id = bm.user_id
LEFT JOIN baby_profiles bp ON bm.baby_profile_id = bp.id
WHERE au.email = 'dipan.saha@gmail.com';
