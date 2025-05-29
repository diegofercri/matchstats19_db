CREATE OR REPLACE VIEW my_permissions AS
SELECT 
    r.type as role_type,
    ra.entity_type,
    ra.entity_id,
    CASE ra.entity_type
        WHEN 'competition' THEN (SELECT name FROM competition WHERE id = ra.entity_id)
        WHEN 'season' THEN 'Season ' || (SELECT start_date::text FROM season WHERE id = ra.entity_id)
        WHEN 'team' THEN (SELECT name FROM team WHERE id = ra.entity_id)
        WHEN 'game' THEN 'Game ' || (SELECT date::text FROM game WHERE id = ra.entity_id)
        ELSE ra.entity_type::text
    END as entity_name
FROM rol_assignment ra
JOIN rol r ON ra.rol_id = r.id
WHERE ra.extended_user_id = auth.uid();