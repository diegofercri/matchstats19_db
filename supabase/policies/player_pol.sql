-- PLAYER
CREATE POLICY "Public can view players" ON player
    FOR SELECT USING (true);

CREATE POLICY "Team admins can manage players" ON player
    FOR ALL USING (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM player_team_season pts
            JOIN team_season ts ON pts.team_season_id = ts.id
            WHERE pts.player_id = player.id
            AND (has_role('primary_team_admin', 'team', ts.team_id) OR
                 has_role('team_admin', 'team', ts.team_id))
        )
    );