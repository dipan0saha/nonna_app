-- Allow owners to delete any registry purchase for their baby profile
CREATE POLICY "Owners can delete any registry purchase"
  ON public.registry_purchases FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM public.registry_items ri
      INNER JOIN public.baby_memberships bm ON bm.baby_profile_id = ri.baby_profile_id
      WHERE ri.id = registry_purchases.registry_item_id
        AND bm.user_id = auth.uid()
        AND bm.role = 'owner'
        AND bm.removed_at IS NULL
    )
  );
