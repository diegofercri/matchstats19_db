-- GAME_RESULT
CREATE POLICY "Public can view results" ON game_result
    FOR SELECT USING (true);

CREATE POLICY "Game and competition admins can manage results" ON game_result
    FOR ALL USING (
        is_super_admin() OR
        has_role('game_admin', 'game', game_id) OR
        EXISTS (
            SELECT 1 FROM game g
            JOIN season s ON g.season_id = s.id
            WHERE g.id = game_result.game_id
            AND (has_role('primary_competition_admin', 'competition', s.competition_id) OR
                 has_role('competition_admin', 'competition', s.competition_id))
        )
    );