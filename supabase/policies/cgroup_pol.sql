-- Políticas para cgroup
CREATE POLICY "Public can view groups" ON cgroup
    FOR SELECT USING (true);

CREATE POLICY "Competition admins can manage groups" ON cgroup
    FOR INSERT WITH CHECK (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM phase p
            JOIN season s ON p.season_id = s.id
            WHERE p.id = cgroup.phase_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        )
    );

CREATE POLICY "Competition admins can update groups" ON cgroup
    FOR UPDATE USING (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM phase p
            JOIN season s ON p.season_id = s.id
            WHERE p.id = cgroup.phase_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        )
    );

CREATE POLICY "Competition admins can delete groups" ON cgroup
    FOR DELETE USING (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM phase p
            JOIN season s ON p.season_id = s.id
            WHERE p.id = cgroup.phase_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        )
    );