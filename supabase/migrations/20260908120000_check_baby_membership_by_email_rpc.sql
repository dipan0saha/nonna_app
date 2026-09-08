-- Phase 1e follow-up (#29): membership dedupe by email for batch invite

CREATE OR REPLACE FUNCTION public.check_baby_membership_by_email(
  p_baby_profile_id UUID,
  p_email TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller UUID := auth.uid();
  v_normalized_email TEXT := lower(trim(p_email));
BEGIN
  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING ERRCODE = '28000';
  END IF;

  IF v_normalized_email IS NULL OR v_normalized_email = '' THEN
    RETURN FALSE;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.baby_memberships bm
    WHERE bm.baby_profile_id = p_baby_profile_id
      AND bm.user_id = v_caller
      AND bm.role = 'owner'
      AND bm.removed_at IS NULL
  ) THEN
    RAISE EXCEPTION 'not_authorized' USING ERRCODE = '42501';
  END IF;

  RETURN EXISTS (
    SELECT 1
    FROM auth.users u
    INNER JOIN public.baby_memberships bm ON bm.user_id = u.id
    WHERE bm.baby_profile_id = p_baby_profile_id
      AND bm.removed_at IS NULL
      AND lower(u.email) = v_normalized_email
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.check_baby_membership_by_email(UUID, TEXT) TO authenticated;
