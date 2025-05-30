-- Políticas para phase
CREATE POLICY "Public can view phases" ON phase
    FOR SELECT USING (true);

CREATE POLICY "Competition admins can manage phases" ON phase
    FOR INSERT WITH CHECK (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM season s
            WHERE s.id = phase.season_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        )
    );

CREATE POLICY "Competition admins can update phases" ON phase
    FOR UPDATE USING (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM season s
            WHERE s.id = phase.season_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        )
    );

CREATE POLICY "Competition admins can delete phases" ON phase
    FOR DELETE USING (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM season s
            WHERE s.id = phase.season_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        )
    );