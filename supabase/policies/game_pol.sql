-- GAME
CREATE POLICY "Public can view games" ON game
    FOR SELECT USING (true);

CREATE POLICY "Game admins can update their games" ON game
    FOR UPDATE USING (
        is_super_admin() OR
        has_role('game_admin', 'game', id) OR
        has_cascading_role('competition_admin', 'season', season_id)
    );

CREATE POLICY "Competition admins can manage games" ON game
    FOR INSERT WITH CHECK (
        is_super_admin() OR
        has_cascading_role('competition_admin', 'season', season_id)
    );

CREATE POLICY "Competition admins can delete games" ON game
    FOR DELETE USING (
        is_super_admin() OR
        has_cascading_role('competition_admin', 'season', season_id)
    );