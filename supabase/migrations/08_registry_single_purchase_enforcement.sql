-- Migration: Enforce single purchase per registry item
-- Date: 2026-05-05
-- Goal: Prevent multiple users from purchasing the same registry item.

-- 1) Clean up historical duplicates by keeping the earliest purchase per item.
WITH ranked_purchases AS (
  SELECT
    id,
    ROW_NUMBER() OVER (
      PARTITION BY registry_item_id
      ORDER BY purchased_at ASC, id ASC
    ) AS row_num
  FROM public.registry_purchases
)
DELETE FROM public.registry_purchases rp
USING ranked_purchases r
WHERE rp.id = r.id
  AND r.row_num > 1;

-- 2) Enforce one purchase row per registry item at the database layer.
CREATE UNIQUE INDEX IF NOT EXISTS uq_registry_purchases_registry_item_id
  ON public.registry_purchases (registry_item_id);

-- 3) Tighten RLS insert check for clearer intent in policy enforcement.
DROP POLICY IF EXISTS "Members can mark items as purchased" ON public.registry_purchases;

CREATE POLICY "Members can mark items as purchased"
  ON public.registry_purchases FOR INSERT
  WITH CHECK (
    auth.uid() = purchased_by_user_id
    AND is_registry_item_member(auth.uid(), registry_item_id)
    AND NOT EXISTS (
      SELECT 1
      FROM public.registry_purchases existing
      WHERE existing.registry_item_id = registry_purchases.registry_item_id
    )
  );
