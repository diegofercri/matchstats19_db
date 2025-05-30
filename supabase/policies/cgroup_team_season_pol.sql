-- Políticas para cgroup_team_season
CREATE POLICY "Public can view group team assignments" ON cgroup_team_season
    FOR SELECT USING (true);

CREATE POLICY "Competition admins can manage group teams" ON cgroup_team_season
    FOR INSERT WITH CHECK (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM cgroup g
            JOIN phase p ON g.phase_id = p.id
            JOIN season s ON p.season_id = s.id
            WHERE g.id = cgroup_team_season.cgroup_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        )
    );

CREATE POLICY "Competition admins can update group teams" ON cgroup_team_season
    FOR UPDATE USING (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM cgroup g
            JOIN phase p ON g.phase_id = p.id
            JOIN season s ON p.season_id = s.id
            WHERE g.id = cgroup_team_season.cgroup_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        )
    );

CREATE POLICY "Competition admins can delete group teams" ON cgroup_team_season
    FOR DELETE USING (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM cgroup g
            JOIN phase p ON g.phase_id = p.id
            JOIN season s ON p.season_id = s.id
            WHERE g.id = cgroup_team_season.cgroup_id
            AND has_role('competition_admin', 'competition', s.competition_id)
        )
    );