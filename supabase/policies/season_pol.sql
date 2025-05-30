-- SEASON
CREATE POLICY "Public can view seasons" ON season
    FOR SELECT USING (true);

CREATE POLICY "Competition admins can manage seasons" ON season
    FOR ALL USING (
        is_super_admin() OR
        has_role('primary_competition_admin', 'competition', competition_id) OR
        has_role('competition_admin', 'competition', competition_id)
    );
