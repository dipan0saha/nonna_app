-- Phase 0b: invitation metadata columns + preview/accept RPCs (SECURITY DEFINER)

ALTER TABLE public.invitations
  ADD COLUMN IF NOT EXISTS invitee_name TEXT,
  ADD COLUMN IF NOT EXISTS relationship_label TEXT,
  ADD COLUMN IF NOT EXISTS invited_role TEXT NOT NULL DEFAULT 'follower'
    CHECK (invited_role IN ('owner', 'follower'));

-- Returns safe preview fields for anon/authenticated invitees (bypasses RLS).
CREATE OR REPLACE FUNCTION public.get_invitation_preview(p_token_hash TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_inv public.invitations%ROWTYPE;
  v_baby_name TEXT;
  v_inviter_name TEXT;
BEGIN
  SELECT * INTO v_inv
  FROM public.invitations
  WHERE token_hash = p_token_hash
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  IF v_inv.status != 'pending' OR v_inv.expires_at < NOW() THEN
    RETURN jsonb_build_object('status', 'expired');
  END IF;

  SELECT bp.name INTO v_baby_name
  FROM public.baby_profiles bp
  WHERE bp.id = v_inv.baby_profile_id
    AND bp.deleted_at IS NULL;

  SELECT p.display_name INTO v_inviter_name
  FROM public.profiles p
  WHERE p.user_id = v_inv.invited_by_user_id;

  RETURN jsonb_build_object(
    'invitation_id', v_inv.id,
    'baby_profile_id', v_inv.baby_profile_id,
    'baby_name', COALESCE(v_baby_name, 'Baby'),
    'inviter_display_name', COALESCE(v_inviter_name, 'A family member'),
    'invitee_email', v_inv.invitee_email,
    'relationship_label', v_inv.relationship_label,
    'invited_role', v_inv.invited_role,
    'expires_at', v_inv.expires_at,
    'status', v_inv.status
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_invitation_preview(TEXT) TO anon, authenticated;

-- Accepts invitation server-side (authenticated only).
CREATE OR REPLACE FUNCTION public.accept_invitation(p_token_hash TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_inv public.invitations%ROWTYPE;
  v_user_id UUID := auth.uid();
  v_user_email TEXT;
  v_baby_name TEXT;
  v_existing_role TEXT;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING ERRCODE = '28000';
  END IF;

  SELECT email INTO v_user_email FROM auth.users WHERE id = v_user_id;

  SELECT * INTO v_inv
  FROM public.invitations
  WHERE token_hash = p_token_hash
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('error', 'not_found');
  END IF;

  IF v_inv.status != 'pending' OR v_inv.expires_at < NOW() THEN
    RETURN jsonb_build_object('error', 'expired');
  END IF;

  IF lower(v_user_email) != lower(v_inv.invitee_email) THEN
    RETURN jsonb_build_object(
      'error', 'email_mismatch',
      'invitee_email', v_inv.invitee_email,
      'signed_in_email', v_user_email
    );
  END IF;

  SELECT role INTO v_existing_role
  FROM public.baby_memberships
  WHERE baby_profile_id = v_inv.baby_profile_id
    AND user_id = v_user_id
    AND removed_at IS NULL
  LIMIT 1;

  IF v_existing_role IS NOT NULL THEN
    SELECT name INTO v_baby_name FROM public.baby_profiles WHERE id = v_inv.baby_profile_id;
    RETURN jsonb_build_object(
      'already_member', true,
      'baby_profile_id', v_inv.baby_profile_id,
      'role', v_existing_role,
      'baby_name', COALESCE(v_baby_name, 'Baby')
    );
  END IF;

  -- Single transaction: membership insert + invitation update are atomic.
  INSERT INTO public.baby_memberships (
    baby_profile_id,
    user_id,
    role,
    relationship_label,
    created_at,
    updated_at
  ) VALUES (
    v_inv.baby_profile_id,
    v_user_id,
    v_inv.invited_role,
    v_inv.relationship_label,
    NOW(),
    NOW()
  );

  UPDATE public.invitations
  SET status = 'accepted',
      accepted_at = NOW(),
      accepted_by_user_id = v_user_id,
      updated_at = NOW()
  WHERE id = v_inv.id;

  SELECT name INTO v_baby_name FROM public.baby_profiles WHERE id = v_inv.baby_profile_id;

  RETURN jsonb_build_object(
    'already_member', false,
    'baby_profile_id', v_inv.baby_profile_id,
    'role', v_inv.invited_role,
    'baby_name', COALESCE(v_baby_name, 'Baby')
  );
EXCEPTION
  WHEN OTHERS THEN
    IF SQLERRM LIKE '%Maximum two owners%' THEN
      RETURN jsonb_build_object('error', 'max_owners');
    END IF;
    RAISE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.accept_invitation(TEXT) TO authenticated;
