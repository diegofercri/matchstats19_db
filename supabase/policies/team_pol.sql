-- TEAM
CREATE POLICY "Public can view teams" ON team
    FOR SELECT USING (true);

CREATE POLICY "Anyone can create teams" ON team
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Team admins can update their teams" ON team
    FOR UPDATE USING (
        is_super_admin() OR
        has_role('primary_team_admin', 'team', id) OR
        has_role('team_admin', 'team', id) OR
        -- Competition admins can update teams they created
        EXISTS (
            SELECT 1 FROM rol_assignment ra
            JOIN rol r ON ra.rol_id = r.id
            WHERE ra.user_id = auth.uid()
            AND r.type IN ('primary_competition_admin', 'competition_admin')
            AND team.created_by = auth.uid()
        )
    );

CREATE POLICY "Primary team admins can delete their teams" ON team
    FOR DELETE USING (
        is_super_admin() OR
        has_role('primary_team_admin', 'team', id)
    );