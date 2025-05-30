-- TEAM_SEASON
CREATE POLICY "Public can view approved team seasons" ON team_season
    FOR SELECT USING (
        registration_status = 'approved' OR
        is_super_admin() OR
        -- Competition admins ven todas las inscripciones
        EXISTS (
            SELECT 1 FROM season s
            WHERE s.id = team_season.season_id
            AND (has_role('primary_competition_admin', 'competition', s.competition_id) OR
                 has_role('competition_admin', 'competition', s.competition_id))
        ) OR
        -- Team admins ven sus propias inscripciones
        has_role('team_admin', 'team', team_id) OR
        has_role('primary_team_admin', 'team', team_id)
    );

CREATE POLICY "Team admins can request registration" ON team_season
    FOR INSERT WITH CHECK (
        is_super_admin() OR
        has_role('primary_team_admin', 'team', team_id) OR
        has_role('team_admin', 'team', team_id) OR
        -- Competition admins can register teams they created
        EXISTS (
            SELECT 1 FROM team t
            JOIN season s ON s.id = season_id
            WHERE t.id = team_id
            AND t.created_by = auth.uid()
            AND (has_role('primary_competition_admin', 'competition', s.competition_id) OR
                 has_role('competition_admin', 'competition', s.competition_id))
        )
    );

CREATE POLICY "Team admins can delete pending registrations" ON team_season
    FOR DELETE USING (
        registration_status = 'pending' AND
        (is_super_admin() OR
         has_role('primary_team_admin', 'team', team_id) OR
         has_role('team_admin', 'team', team_id))
    );

CREATE POLICY "Competition admins can manage team seasons" ON team_season
    FOR UPDATE USING (
        is_super_admin() OR
        EXISTS (
            SELECT 1 FROM season s
            WHERE s.id = team_season.season_id
            AND (has_role('primary_competition_admin', 'competition', s.competition_id) OR
                 has_role('competition_admin', 'competition', s.competition_id))
        )
    );