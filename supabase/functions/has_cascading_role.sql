-- Función para obtener permisos en cascada
CREATE OR REPLACE FUNCTION public.has_cascading_role(
    p_role_type rol_enum,
    p_entity_type entity_type_enum,
    p_entity_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_competition_id UUID;
    v_season_id UUID;
    v_phase_id UUID;
BEGIN
    -- Si es super admin, tiene acceso a todo
    IF is_super_admin() THEN
        RETURN TRUE;
    END IF;
    
    -- Verificar rol directo
    IF has_role(p_role_type, p_entity_type, p_entity_id) THEN
        RETURN TRUE;
    END IF;
    
    -- Verificar permisos en cascada según el tipo de entidad
    CASE p_entity_type
        WHEN 'game' THEN
            SELECT season_id, phase_id INTO v_season_id, v_phase_id
            FROM game WHERE id = p_entity_id;
            
            -- Admin de temporada puede gestionar partidos
            IF has_role('competition_admin', 'season', v_season_id) THEN
                RETURN TRUE;
            END IF;
            
        WHEN 'team' THEN
            -- Admin de competición puede gestionar equipos
            SELECT competition_id INTO v_competition_id
            FROM season s
            JOIN team_season ts ON s.id = ts.season_id
            WHERE ts.team_id = p_entity_id
            LIMIT 1;
            
            IF v_competition_id IS NOT NULL AND 
               has_role('competition_admin', 'competition', v_competition_id) THEN
                RETURN TRUE;
            END IF;
    END CASE;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;