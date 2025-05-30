-- ROL_ASSIGNMENT
CREATE POLICY "Public can view role assignments" ON rol_assignment
    FOR SELECT USING (true);

CREATE POLICY "Admins can assign roles within their scope" ON rol_assignment
    FOR INSERT WITH CHECK (
        is_super_admin() OR
        -- Primary competition admin can assign competition admins
        (EXISTS (
            SELECT 1 FROM rol r 
            WHERE r.id = rol_assignment.rol_id 
            AND r.type = 'competition_admin'
        ) AND has_role('primary_competition_admin', 'competition', entity_id))
        OR
        -- Competition admin can assign game admins
        (EXISTS (
            SELECT 1 FROM rol r 
            WHERE r.id = rol_assignment.rol_id 
            AND r.type = 'game_admin'
        ) AND EXISTS (
            SELECT 1 FROM game g
            JOIN season s ON g.season_id = s.id
            WHERE g.id = entity_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        ))
        OR
        -- Primary team admin can assign team admins
        (EXISTS (
            SELECT 1 FROM rol r 
            WHERE r.id = rol_assignment.rol_id 
            AND r.type = 'team_admin'
        ) AND has_role('primary_team_admin', 'team', entity_id))
    );

CREATE POLICY "Admins can remove roles within their scope" ON rol_assignment
    FOR DELETE USING (
        is_super_admin() OR
        -- Same logic as INSERT
        (EXISTS (
            SELECT 1 FROM rol r 
            WHERE r.id = rol_assignment.rol_id 
            AND r.type = 'competition_admin'
        ) AND has_role('primary_competition_admin', 'competition', entity_id))
        OR
        (EXISTS (
            SELECT 1 FROM rol r 
            WHERE r.id = rol_assignment.rol_id 
            AND r.type = 'game_admin'
        ) AND EXISTS (
            SELECT 1 FROM game g
            JOIN season s ON g.season_id = s.id
            WHERE g.id = entity_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        ))
        OR
        (EXISTS (
            SELECT 1 FROM rol r 
            WHERE r.id = rol_assignment.rol_id 
            AND r.type = 'team_admin'
        ) AND has_role('primary_team_admin', 'team', entity_id))
    );