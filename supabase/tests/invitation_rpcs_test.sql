BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

SELECT plan(17);

-- New invitation columns
SELECT has_column('public', 'invitations', 'invitee_name', 'invitations has invitee_name');
SELECT has_column('public', 'invitations', 'relationship_label', 'invitations has relationship_label');
SELECT has_column('public', 'invitations', 'invited_role', 'invitations has invited_role');

-- RPC functions exist
SELECT has_function(
  'public',
  'get_invitation_preview',
  ARRAY['text'],
  'get_invitation_preview RPC exists'
);

SELECT has_function(
  'public',
  'accept_invitation',
  ARRAY['text'],
  'accept_invitation RPC exists'
);

-- Preview returns null for unknown token
SELECT is(
  public.get_invitation_preview('nonexistent-token-hash'),
  NULL::jsonb,
  'preview returns null for unknown token'
);

-- Seeded preview + role mapping
INSERT INTO auth.users (id, email) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000099', 'owner@test.com');

INSERT INTO public.profiles (user_id, display_name) VALUES
  ('aaaaaaaa-0000-0000-0000-000000000099', 'Test Owner');

INSERT INTO public.baby_profiles (id, name) VALUES
  ('bbbbbbbb-0000-0000-0000-000000000099', 'Preview Baby');

INSERT INTO public.invitations (
  id,
  baby_profile_id,
  invited_by_user_id,
  invitee_email,
  token_hash,
  expires_at,
  status,
  invited_role,
  relationship_label
) VALUES (
  'cccccccc-0000-0000-0000-000000000099',
  'bbbbbbbb-0000-0000-0000-000000000099',
  'aaaaaaaa-0000-0000-0000-000000000099',
  'guest@test.com',
  'preview-token-hash',
  NOW() + INTERVAL '7 days',
  'pending',
  'owner',
  'Partner'
);

SELECT is(
  public.get_invitation_preview('preview-token-hash') ->> 'baby_name',
  'Preview Baby',
  'preview returns baby name'
);

SELECT is(
  public.get_invitation_preview('preview-token-hash') ->> 'invited_role',
  'owner',
  'preview returns invited_role'
);

SELECT is(
  public.get_invitation_preview('preview-token-hash') ->> 'relationship_label',
  'Partner',
  'preview returns relationship_label'
);

UPDATE public.invitations
SET status = 'revoked'
WHERE token_hash = 'preview-token-hash';

SELECT is(
  public.get_invitation_preview('preview-token-hash') ->> 'status',
  'expired',
  'preview returns expired for non-pending invitation'
);

-- check_baby_membership_by_email RPC
SELECT has_function(
  'public',
  'check_baby_membership_by_email',
  ARRAY['uuid', 'text'],
  'check_baby_membership_by_email RPC exists'
);

INSERT INTO auth.users (id, email) VALUES
  ('dddddddd-0000-0000-0000-000000000099', 'member@test.com');

INSERT INTO public.baby_memberships (
  baby_profile_id,
  user_id,
  role,
  created_at,
  updated_at
) VALUES (
  'bbbbbbbb-0000-0000-0000-000000000099',
  'aaaaaaaa-0000-0000-0000-000000000099',
  'owner',
  NOW(),
  NOW()
),
(
  'bbbbbbbb-0000-0000-0000-000000000099',
  'dddddddd-0000-0000-0000-000000000099',
  'follower',
  NOW(),
  NOW()
);

SET LOCAL role authenticated;
SET LOCAL request.jwt.claim.sub = 'aaaaaaaa-0000-0000-0000-000000000099';

SELECT is(
  public.check_baby_membership_by_email(
    'bbbbbbbb-0000-0000-0000-000000000099',
    'member@test.com'
  ),
  TRUE,
  'membership RPC returns true for active member email'
);

SELECT is(
  public.check_baby_membership_by_email(
    'bbbbbbbb-0000-0000-0000-000000000099',
    'stranger@test.com'
  ),
  FALSE,
  'membership RPC returns false for non-member email'
);

SELECT is(
  public.check_baby_membership_by_email(
    'bbbbbbbb-0000-0000-0000-000000000001',
    'member@test.com'
  ),
  FALSE,
  'membership RPC returns false for member on different baby'
);

SELECT * FROM finish();

ROLLBACK;
