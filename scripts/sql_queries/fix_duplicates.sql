DELETE FROM tile_configs 
WHERE ctid NOT IN (
    SELECT MIN(ctid) 
    FROM tile_configs 
    GROUP BY screen_id, tile_definition_id, role
);
