-- COMPETITION
CREATE POLICY "Public can view competitions" ON competition
    FOR SELECT USING (true);

CREATE POLICY "Anyone can create competitions" ON competition
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Competition admins can update their competitions" ON competition
    FOR UPDATE USING (
        is_super_admin() OR
        has_role('primary_competition_admin', 'competition', id) OR
        has_role('competition_admin', 'competition', id)
    );

CREATE POLICY "Primary competition admins can delete their competitions" ON competition
    FOR DELETE USING (
        is_super_admin() OR
        has_role('primary_competition_admin', 'competition', id)
    );