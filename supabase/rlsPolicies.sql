-- Políticas para extended_user
CREATE POLICY "Users can view all profiles" ON extended_user
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON extended_user
    FOR UPDATE USING (auth.uid() = id);

-- Políticas para competition (ejemplo de lectura pública)
CREATE POLICY "Public can view competitions" ON competition
    FOR SELECT USING (true);

CREATE POLICY "Only admins can manage competitions" ON competition
    FOR ALL USING (
        is_super_admin() OR 
        has_role('competition_admin', 'competition', id)
    );

-- Políticas para game
CREATE POLICY "Public can view games" ON game
    FOR SELECT USING (true);

CREATE POLICY "Game admins can update games" ON game
    FOR UPDATE USING (
        has_cascading_role('game_admin', 'game', id) OR
        has_cascading_role('competition_admin', 'season', season_id)
    );

-- Políticas para game_result
CREATE POLICY "Public can view results" ON game_result
    FOR SELECT USING (true);

CREATE POLICY "Only game admins can manage results" ON game_result
    FOR ALL USING (
        has_cascading_role('game_admin', 'game', game_id)
    );

-- Políticas para rol_assignment (muy restrictivas)
CREATE POLICY "Users can view own assignments" ON rol_assignment
    FOR SELECT USING (extended_user_id = auth.uid());

CREATE POLICY "Only super admins can manage roles" ON rol_assignment
    FOR ALL USING (is_super_admin());