CREATE OR REPLACE FUNCTION public.check_permission(
    p_action TEXT,
    p_entity_type entity_type_enum,
    p_entity_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    v_result = jsonb_build_object(
        'has_permission', false,
        'is_super_admin', is_super_admin(),
        'roles', array[]::text[]
    );
    
    -- Mapear acciones a roles
    CASE p_action
        WHEN 'edit_game' THEN
            v_result = jsonb_set(v_result, '{has_permission}', 
                to_jsonb(has_cascading_role('game_admin', p_entity_type, p_entity_id)));
        WHEN 'edit_team' THEN
            v_result = jsonb_set(v_result, '{has_permission}', 
                to_jsonb(has_cascading_role('team_admin', p_entity_type, p_entity_id)));
        WHEN 'manage_competition' THEN
            v_result = jsonb_set(v_result, '{has_permission}', 
                to_jsonb(has_cascading_role('competition_admin', p_entity_type, p_entity_id)));
    END CASE;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;