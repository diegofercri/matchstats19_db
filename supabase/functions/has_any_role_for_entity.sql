-- Función para verificar si tiene rol primary o normal
CREATE OR REPLACE FUNCTION public.has_any_role_for_entity(
    p_entity_type entity_type_enum,
    p_entity_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM rol_assignment ra
        WHERE ra.user_id = auth.uid()
        AND ra.entity_type = p_entity_type
        AND ra.entity_id = p_entity_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;