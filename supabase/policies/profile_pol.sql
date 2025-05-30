-- Políticas para profile
CREATE POLICY "Users can view all profiles" ON public.profile
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can create their own profile" ON public.profile
    FOR INSERT USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profile
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
