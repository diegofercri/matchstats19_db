-- Función para verificar si es super admin
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM rol_assignment ra
        JOIN rol r ON ra.rol_id = r.id
        WHERE ra.user_id = auth.uid()
        AND r.type = 'super_admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;