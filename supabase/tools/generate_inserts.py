import re

# Read the original file
with open(
    "/Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/supabase/auth_users_seed.sql",
    "r",
) as f:
    content = f.read()

# Regex to find INSERT statements
insert_pattern = r"INSERT INTO auth\.users \(id, email, aud, role, email_confirmed_at, created_at\) VALUES \('([^']+)', '([^']+)', 'authenticated', 'authenticated', NOW\(\), NOW\(\)\) ON CONFLICT \(id\) DO NOTHING;"

matches = re.findall(insert_pattern, content)

# Generate new INSERTs
new_inserts = []

for match in matches:
    user_id, email = match

    # 1. auth.users INSERT
    users_insert = f"""-- 1. Create a user in the auth.users table
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, raw_app_meta_data, raw_user_meta_data, is_super_admin, phone) VALUES ('00000000-0000-0000-0000-000000000000', '{user_id}', 'authenticated', 'authenticated', '{email}', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '', '', '{{"provider":"email","providers":["email"]}}', '{{}}', FALSE, NULL);

-- 2. Create the corresponding identity
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at) VALUES (gen_random_uuid(), '{user_id}', format('{{"sub":"%s","email":"%s"}}','{user_id}','{email}')::jsonb, 'email', '{user_id}', NOW(), NOW(), NOW());
"""
    new_inserts.append(users_insert)

# Write to new file
with open(
    "/Users/dipansaha/Neo_Workspace/CodeSpace/Git_Repos/nonna_app/supabase/auth_users_with_identities.sql",
    "w",
) as f:
    f.write("-- Generated auth.users and auth.identities INSERTs\n\n")
    f.write("BEGIN;\n\n")
    for insert in new_inserts:
        f.write(insert + "\n")
    f.write("COMMIT;\n")

print("Generated file: auth_users_with_identities.sql")
