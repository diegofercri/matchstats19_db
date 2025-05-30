-- Insertar los roles definidos en el ENUM
INSERT INTO rol (type) VALUES 
    ('super_admin'),
    ('primary_competition_admin'),
    ('competition_admin'),
    ('primary_team_admin'),
    ('team_admin'),
    ('game_admin')
ON CONFLICT DO NOTHING;