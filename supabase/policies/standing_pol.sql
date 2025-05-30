-- STANDING (solo lectura, se actualiza automáticamente)
CREATE POLICY "Public can view standings" ON standing
    FOR SELECT USING (true);