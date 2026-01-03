-- Generated auth.users and auth.identities INSERTs

BEGIN;

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000001-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000001@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000001-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000001-1001-1001-1001-000000001001','seed+10000001@example.local')::jsonb, 'email', '10000001-1001-1001-1001-000000001001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000002-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000002@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000002-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000002-1001-1001-1001-000000001001','seed+10000002@example.local')::jsonb, 'email', '10000002-1001-1001-1001-000000001001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000003-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000003@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000003-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000003-1001-1001-1001-000000001001','seed+10000003@example.local')::jsonb, 'email', '10000003-1001-1001-1001-000000001001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000004-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000004@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000004-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000004-1001-1001-1001-000000001001','seed+10000004@example.local')::jsonb, 'email', '10000004-1001-1001-1001-000000001001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000005-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000005@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000005-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000005-1001-1001-1001-000000001001','seed+10000005@example.local')::jsonb, 'email', '10000005-1001-1001-1001-000000001001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000006-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000006@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000006-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000006-1001-1001-1001-000000001001','seed+10000006@example.local')::jsonb, 'email', '10000006-1001-1001-1001-000000001001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000007-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000007@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000007-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000007-1001-1001-1001-000000001001','seed+10000007@example.local')::jsonb, 'email', '10000007-1001-1001-1001-000000001001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000008-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000008@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000008-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000008-1001-1001-1001-000000001001','seed+10000008@example.local')::jsonb, 'email', '10000008-1001-1001-1001-000000001001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '10000009-1001-1001-1001-000000001001', 'authenticated', 'authenticated', 'seed+10000009@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '10000009-1001-1001-1001-000000001001', format('{"sub":"%s","email":"%s"}','10000009-1001-1001-1001-000000001001','seed+10000009@example.local')::jsonb, 'email', '10000009-1001-1001-1001-000000001001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000000-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000000@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000000-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000000-2001-2001-2001-000000002001','seed+20000000@example.local')::jsonb, 'email', '20000000-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000001-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000001@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000001-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000001-2001-2001-2001-000000002001','seed+20000001@example.local')::jsonb, 'email', '20000001-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000002-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000002@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000002-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000002-2001-2001-2001-000000002001','seed+20000002@example.local')::jsonb, 'email', '20000002-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000003-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000003@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000003-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000003-2001-2001-2001-000000002001','seed+20000003@example.local')::jsonb, 'email', '20000003-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000004-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000004@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000004-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000004-2001-2001-2001-000000002001','seed+20000004@example.local')::jsonb, 'email', '20000004-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000005-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000005@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000005-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000005-2001-2001-2001-000000002001','seed+20000005@example.local')::jsonb, 'email', '20000005-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000006-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000006@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000006-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000006-2001-2001-2001-000000002001','seed+20000006@example.local')::jsonb, 'email', '20000006-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000007-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000007@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000007-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000007-2001-2001-2001-000000002001','seed+20000007@example.local')::jsonb, 'email', '20000007-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000008-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000008@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000008-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000008-2001-2001-2001-000000002001','seed+20000008@example.local')::jsonb, 'email', '20000008-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '20000009-2001-2001-2001-000000002001', 'authenticated', 'authenticated', 'seed+20000009@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '20000009-2001-2001-2001-000000002001', format('{"sub":"%s","email":"%s"}','20000009-2001-2001-2001-000000002001','seed+20000009@example.local')::jsonb, 'email', '20000009-2001-2001-2001-000000002001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000000-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000000@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000000-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000000-4001-4001-4001-000000004001','seed+40000000@example.local')::jsonb, 'email', '40000000-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000001-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000001@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000001-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000001-4001-4001-4001-000000004001','seed+40000001@example.local')::jsonb, 'email', '40000001-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000002-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000002@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000002-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000002-4001-4001-4001-000000004001','seed+40000002@example.local')::jsonb, 'email', '40000002-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000003-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000003@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000003-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000003-4001-4001-4001-000000004001','seed+40000003@example.local')::jsonb, 'email', '40000003-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000004-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000004@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000004-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000004-4001-4001-4001-000000004001','seed+40000004@example.local')::jsonb, 'email', '40000004-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000005-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000005@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000005-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000005-4001-4001-4001-000000004001','seed+40000005@example.local')::jsonb, 'email', '40000005-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000006-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000006@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000006-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000006-4001-4001-4001-000000004001','seed+40000006@example.local')::jsonb, 'email', '40000006-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000007-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000007@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000007-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000007-4001-4001-4001-000000004001','seed+40000007@example.local')::jsonb, 'email', '40000007-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000008-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000008@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000008-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000008-4001-4001-4001-000000004001','seed+40000008@example.local')::jsonb, 'email', '40000008-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000009-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000009@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000009-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000009-4001-4001-4001-000000004001','seed+40000009@example.local')::jsonb, 'email', '40000009-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000a-4001-4001-4001-000000004001','seed+4000000a@example.local')::jsonb, 'email', '4000000a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000b-4001-4001-4001-000000004001','seed+4000000b@example.local')::jsonb, 'email', '4000000b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000c-4001-4001-4001-000000004001','seed+4000000c@example.local')::jsonb, 'email', '4000000c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000d-4001-4001-4001-000000004001','seed+4000000d@example.local')::jsonb, 'email', '4000000d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000e-4001-4001-4001-000000004001','seed+4000000e@example.local')::jsonb, 'email', '4000000e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000000f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000000f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000000f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000000f-4001-4001-4001-000000004001','seed+4000000f@example.local')::jsonb, 'email', '4000000f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000010-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000010@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000010-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000010-4001-4001-4001-000000004001','seed+40000010@example.local')::jsonb, 'email', '40000010-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000011-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000011@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000011-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000011-4001-4001-4001-000000004001','seed+40000011@example.local')::jsonb, 'email', '40000011-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000012-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000012@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000012-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000012-4001-4001-4001-000000004001','seed+40000012@example.local')::jsonb, 'email', '40000012-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000013-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000013@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000013-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000013-4001-4001-4001-000000004001','seed+40000013@example.local')::jsonb, 'email', '40000013-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000014-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000014@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000014-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000014-4001-4001-4001-000000004001','seed+40000014@example.local')::jsonb, 'email', '40000014-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000015-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000015@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000015-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000015-4001-4001-4001-000000004001','seed+40000015@example.local')::jsonb, 'email', '40000015-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000016-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000016@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000016-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000016-4001-4001-4001-000000004001','seed+40000016@example.local')::jsonb, 'email', '40000016-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000017-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000017@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000017-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000017-4001-4001-4001-000000004001','seed+40000017@example.local')::jsonb, 'email', '40000017-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000018-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000018@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000018-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000018-4001-4001-4001-000000004001','seed+40000018@example.local')::jsonb, 'email', '40000018-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000019-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000019@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000019-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000019-4001-4001-4001-000000004001','seed+40000019@example.local')::jsonb, 'email', '40000019-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001a-4001-4001-4001-000000004001','seed+4000001a@example.local')::jsonb, 'email', '4000001a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001b-4001-4001-4001-000000004001','seed+4000001b@example.local')::jsonb, 'email', '4000001b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001c-4001-4001-4001-000000004001','seed+4000001c@example.local')::jsonb, 'email', '4000001c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001d-4001-4001-4001-000000004001','seed+4000001d@example.local')::jsonb, 'email', '4000001d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001e-4001-4001-4001-000000004001','seed+4000001e@example.local')::jsonb, 'email', '4000001e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000001f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000001f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000001f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000001f-4001-4001-4001-000000004001','seed+4000001f@example.local')::jsonb, 'email', '4000001f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000020-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000020@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000020-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000020-4001-4001-4001-000000004001','seed+40000020@example.local')::jsonb, 'email', '40000020-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000021-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000021@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000021-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000021-4001-4001-4001-000000004001','seed+40000021@example.local')::jsonb, 'email', '40000021-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000022-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000022@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000022-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000022-4001-4001-4001-000000004001','seed+40000022@example.local')::jsonb, 'email', '40000022-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000023-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000023@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000023-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000023-4001-4001-4001-000000004001','seed+40000023@example.local')::jsonb, 'email', '40000023-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000024-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000024@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000024-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000024-4001-4001-4001-000000004001','seed+40000024@example.local')::jsonb, 'email', '40000024-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000025-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000025@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000025-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000025-4001-4001-4001-000000004001','seed+40000025@example.local')::jsonb, 'email', '40000025-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000026-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000026@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000026-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000026-4001-4001-4001-000000004001','seed+40000026@example.local')::jsonb, 'email', '40000026-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000027-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000027@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000027-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000027-4001-4001-4001-000000004001','seed+40000027@example.local')::jsonb, 'email', '40000027-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000028-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000028@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000028-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000028-4001-4001-4001-000000004001','seed+40000028@example.local')::jsonb, 'email', '40000028-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000029-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000029@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000029-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000029-4001-4001-4001-000000004001','seed+40000029@example.local')::jsonb, 'email', '40000029-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002a-4001-4001-4001-000000004001','seed+4000002a@example.local')::jsonb, 'email', '4000002a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002b-4001-4001-4001-000000004001','seed+4000002b@example.local')::jsonb, 'email', '4000002b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002c-4001-4001-4001-000000004001','seed+4000002c@example.local')::jsonb, 'email', '4000002c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002d-4001-4001-4001-000000004001','seed+4000002d@example.local')::jsonb, 'email', '4000002d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002e-4001-4001-4001-000000004001','seed+4000002e@example.local')::jsonb, 'email', '4000002e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000002f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000002f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000002f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000002f-4001-4001-4001-000000004001','seed+4000002f@example.local')::jsonb, 'email', '4000002f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000030-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000030@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000030-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000030-4001-4001-4001-000000004001','seed+40000030@example.local')::jsonb, 'email', '40000030-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000031-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000031@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000031-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000031-4001-4001-4001-000000004001','seed+40000031@example.local')::jsonb, 'email', '40000031-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000032-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000032@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000032-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000032-4001-4001-4001-000000004001','seed+40000032@example.local')::jsonb, 'email', '40000032-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000033-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000033@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000033-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000033-4001-4001-4001-000000004001','seed+40000033@example.local')::jsonb, 'email', '40000033-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000034-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000034@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000034-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000034-4001-4001-4001-000000004001','seed+40000034@example.local')::jsonb, 'email', '40000034-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000035-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000035@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000035-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000035-4001-4001-4001-000000004001','seed+40000035@example.local')::jsonb, 'email', '40000035-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000036-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000036@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000036-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000036-4001-4001-4001-000000004001','seed+40000036@example.local')::jsonb, 'email', '40000036-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000037-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000037@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000037-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000037-4001-4001-4001-000000004001','seed+40000037@example.local')::jsonb, 'email', '40000037-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000038-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000038@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000038-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000038-4001-4001-4001-000000004001','seed+40000038@example.local')::jsonb, 'email', '40000038-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000039-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000039@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000039-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000039-4001-4001-4001-000000004001','seed+40000039@example.local')::jsonb, 'email', '40000039-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003a-4001-4001-4001-000000004001','seed+4000003a@example.local')::jsonb, 'email', '4000003a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003b-4001-4001-4001-000000004001','seed+4000003b@example.local')::jsonb, 'email', '4000003b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003c-4001-4001-4001-000000004001','seed+4000003c@example.local')::jsonb, 'email', '4000003c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003d-4001-4001-4001-000000004001','seed+4000003d@example.local')::jsonb, 'email', '4000003d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003e-4001-4001-4001-000000004001','seed+4000003e@example.local')::jsonb, 'email', '4000003e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000003f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000003f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000003f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000003f-4001-4001-4001-000000004001','seed+4000003f@example.local')::jsonb, 'email', '4000003f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000040-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000040@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000040-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000040-4001-4001-4001-000000004001','seed+40000040@example.local')::jsonb, 'email', '40000040-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000041-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000041@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000041-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000041-4001-4001-4001-000000004001','seed+40000041@example.local')::jsonb, 'email', '40000041-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000042-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000042@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000042-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000042-4001-4001-4001-000000004001','seed+40000042@example.local')::jsonb, 'email', '40000042-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000043-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000043@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000043-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000043-4001-4001-4001-000000004001','seed+40000043@example.local')::jsonb, 'email', '40000043-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000044-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000044@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000044-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000044-4001-4001-4001-000000004001','seed+40000044@example.local')::jsonb, 'email', '40000044-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000045-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000045@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000045-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000045-4001-4001-4001-000000004001','seed+40000045@example.local')::jsonb, 'email', '40000045-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000046-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000046@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000046-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000046-4001-4001-4001-000000004001','seed+40000046@example.local')::jsonb, 'email', '40000046-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000047-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000047@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000047-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000047-4001-4001-4001-000000004001','seed+40000047@example.local')::jsonb, 'email', '40000047-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000048-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000048@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000048-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000048-4001-4001-4001-000000004001','seed+40000048@example.local')::jsonb, 'email', '40000048-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000049-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000049@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000049-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000049-4001-4001-4001-000000004001','seed+40000049@example.local')::jsonb, 'email', '40000049-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004a-4001-4001-4001-000000004001','seed+4000004a@example.local')::jsonb, 'email', '4000004a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004b-4001-4001-4001-000000004001','seed+4000004b@example.local')::jsonb, 'email', '4000004b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004c-4001-4001-4001-000000004001','seed+4000004c@example.local')::jsonb, 'email', '4000004c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004d-4001-4001-4001-000000004001','seed+4000004d@example.local')::jsonb, 'email', '4000004d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004e-4001-4001-4001-000000004001','seed+4000004e@example.local')::jsonb, 'email', '4000004e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000004f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000004f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000004f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000004f-4001-4001-4001-000000004001','seed+4000004f@example.local')::jsonb, 'email', '4000004f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000050-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000050@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000050-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000050-4001-4001-4001-000000004001','seed+40000050@example.local')::jsonb, 'email', '40000050-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000051-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000051@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000051-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000051-4001-4001-4001-000000004001','seed+40000051@example.local')::jsonb, 'email', '40000051-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000052-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000052@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000052-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000052-4001-4001-4001-000000004001','seed+40000052@example.local')::jsonb, 'email', '40000052-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000053-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000053@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000053-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000053-4001-4001-4001-000000004001','seed+40000053@example.local')::jsonb, 'email', '40000053-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000054-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000054@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000054-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000054-4001-4001-4001-000000004001','seed+40000054@example.local')::jsonb, 'email', '40000054-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000055-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000055@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000055-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000055-4001-4001-4001-000000004001','seed+40000055@example.local')::jsonb, 'email', '40000055-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000056-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000056@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000056-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000056-4001-4001-4001-000000004001','seed+40000056@example.local')::jsonb, 'email', '40000056-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000057-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000057@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000057-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000057-4001-4001-4001-000000004001','seed+40000057@example.local')::jsonb, 'email', '40000057-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000058-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000058@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000058-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000058-4001-4001-4001-000000004001','seed+40000058@example.local')::jsonb, 'email', '40000058-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000059-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000059@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000059-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000059-4001-4001-4001-000000004001','seed+40000059@example.local')::jsonb, 'email', '40000059-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005a-4001-4001-4001-000000004001','seed+4000005a@example.local')::jsonb, 'email', '4000005a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005b-4001-4001-4001-000000004001','seed+4000005b@example.local')::jsonb, 'email', '4000005b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005c-4001-4001-4001-000000004001','seed+4000005c@example.local')::jsonb, 'email', '4000005c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005d-4001-4001-4001-000000004001','seed+4000005d@example.local')::jsonb, 'email', '4000005d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005e-4001-4001-4001-000000004001','seed+4000005e@example.local')::jsonb, 'email', '4000005e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000005f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000005f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000005f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000005f-4001-4001-4001-000000004001','seed+4000005f@example.local')::jsonb, 'email', '4000005f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000060-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000060@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000060-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000060-4001-4001-4001-000000004001','seed+40000060@example.local')::jsonb, 'email', '40000060-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000061-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000061@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000061-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000061-4001-4001-4001-000000004001','seed+40000061@example.local')::jsonb, 'email', '40000061-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000062-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000062@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000062-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000062-4001-4001-4001-000000004001','seed+40000062@example.local')::jsonb, 'email', '40000062-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000063-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000063@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000063-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000063-4001-4001-4001-000000004001','seed+40000063@example.local')::jsonb, 'email', '40000063-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000064-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000064@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000064-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000064-4001-4001-4001-000000004001','seed+40000064@example.local')::jsonb, 'email', '40000064-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000065-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000065@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000065-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000065-4001-4001-4001-000000004001','seed+40000065@example.local')::jsonb, 'email', '40000065-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000066-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000066@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000066-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000066-4001-4001-4001-000000004001','seed+40000066@example.local')::jsonb, 'email', '40000066-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000067-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000067@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000067-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000067-4001-4001-4001-000000004001','seed+40000067@example.local')::jsonb, 'email', '40000067-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000068-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000068@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000068-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000068-4001-4001-4001-000000004001','seed+40000068@example.local')::jsonb, 'email', '40000068-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000069-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000069@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000069-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000069-4001-4001-4001-000000004001','seed+40000069@example.local')::jsonb, 'email', '40000069-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006a-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006a@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006a-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006a-4001-4001-4001-000000004001','seed+4000006a@example.local')::jsonb, 'email', '4000006a-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006b-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006b@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006b-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006b-4001-4001-4001-000000004001','seed+4000006b@example.local')::jsonb, 'email', '4000006b-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006c-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006c@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006c-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006c-4001-4001-4001-000000004001','seed+4000006c@example.local')::jsonb, 'email', '4000006c-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006d-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006d@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006d-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006d-4001-4001-4001-000000004001','seed+4000006d@example.local')::jsonb, 'email', '4000006d-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006e-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006e@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006e-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006e-4001-4001-4001-000000004001','seed+4000006e@example.local')::jsonb, 'email', '4000006e-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '4000006f-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+4000006f@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '4000006f-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','4000006f-4001-4001-4001-000000004001','seed+4000006f@example.local')::jsonb, 'email', '4000006f-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000070-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000070@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000070-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000070-4001-4001-4001-000000004001','seed+40000070@example.local')::jsonb, 'email', '40000070-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000071-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000071@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000071-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000071-4001-4001-4001-000000004001','seed+40000071@example.local')::jsonb, 'email', '40000071-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000072-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000072@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000072-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000072-4001-4001-4001-000000004001','seed+40000072@example.local')::jsonb, 'email', '40000072-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000073-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000073@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000073-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000073-4001-4001-4001-000000004001','seed+40000073@example.local')::jsonb, 'email', '40000073-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000074-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000074@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000074-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000074-4001-4001-4001-000000004001','seed+40000074@example.local')::jsonb, 'email', '40000074-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000075-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000075@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000075-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000075-4001-4001-4001-000000004001','seed+40000075@example.local')::jsonb, 'email', '40000075-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000076-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000076@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000076-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000076-4001-4001-4001-000000004001','seed+40000076@example.local')::jsonb, 'email', '40000076-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '40000077-4001-4001-4001-000000004001', 'authenticated', 'authenticated', 'seed+40000077@example.local', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{"provider":"email","providers":["email"]}', '{}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '40000077-4001-4001-4001-000000004001', format('{"sub":"%s","email":"%s"}','40000077-4001-4001-4001-000000004001','seed+40000077@example.local')::jsonb, 'email', '40000077-4001-4001-4001-000000004001', NOW(), NOW(), NOW());

COMMIT;
