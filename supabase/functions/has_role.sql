-- Función para verificar si usuario tiene rol específico
CREATE OR REPLACE FUNCTION public.has_role(
    p_role_type rol_enum,
    p_entity_type entity_type_enum,
    p_entity_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM rol_assignment ra
        JOIN rol r ON ra.rol_id = r.id
        WHERE ra.extended_user_id = auth.uid()
        AND r.type = p_role_type
        AND ra.entity_type = p_entity_type
        AND ra.entity_id = p_entity_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;