-- Habilitar extensión UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear tipos ENUM
CREATE TYPE rol_enum AS ENUM ('super_admin', 'competition_admin', 'team_admin', 'game_admin');
CREATE TYPE entity_type_enum AS ENUM ('competition', 'season', 'phase', 'cgroup', 'team', 'player', 'game', 'game_result', 'standing');
CREATE TYPE state_enum AS ENUM ('scheduled', 'in_progress', 'stopped', 'finished', 'cancelled');
CREATE TYPE registration_state_enum AS ENUM ('pending', 'accepted', 'rejected');
CREATE TYPE phase_type_enum AS ENUM ('league', 'cgroup', 'knockout');
CREATE TYPE standings_tiebreaker_rule_enum AS ENUM ('head_to_head', 'points_difference', 'points_scored', 'points_conceded', 'fair_play', 'playoff', 'penalty_shootout', 'away_points_scored', 'home_points_scored', 'manual_pick');
CREATE TYPE knockout_tiebreaker_rule_enum AS ENUM ('extra_time','penalty_shootout', 'golden_goal', 'replay_match', 'away_points_scored', 'home_points_scored', 'manual_pick');
CREATE TYPE game_state_enum AS ENUM ('scheduled', 'in_progress', 'break', 'stopped', 'finished', 'cancelled');
CREATE TYPE player_position_enum AS ENUM ('goalkeeper', 'defender', 'midfielder', 'forward');
CREATE TYPE knockout_format_enum AS ENUM ('bo1', 'bo2', 'bo3', 'bo5', 'bo7');
CREATE TYPE match_leg_enum AS ENUM ('game_1', 'game_2', 'game_3', 'game_4', 'game_5', 'game_6', 'game_7');

-- 1. Crear la tabla Profile
CREATE TABLE public.profile (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT,
    user_surname TEXT,
    image_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);

-- Trigger para insertar automáticamente un perfil cuando se crea un nuevo usuario en auth.users
-- Esto asegura que cada usuario tenga una entrada de perfil desde el inicio.
CREATE OR REPLACE FUNCTION public.handle_new_user_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public -- Importante para que pueda escribir en public.profile
AS $$
BEGIN
  INSERT INTO public.profile (id, updated_by_user_id)
  VALUES (NEW.id, NEW.id);
  RETURN NEW;
END;
$$;

-- Luego, creamos el trigger en la tabla auth.users
CREATE TRIGGER on_auth_user_created_create_profile
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_profile();


-- 2. Tabla rol
CREATE TABLE rol (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type rol_enum NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);


-- 3. Tabla competition
CREATE TABLE competition (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    organizer VARCHAR(255),
    image_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);


-- 4. Tabla season
CREATE TABLE season (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    state state_enum NOT NULL,
    location VARCHAR(255),
    competition_id UUID NOT NULL REFERENCES competition(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);


-- 5. Tabla team
CREATE TABLE team (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL,
    short_name VARCHAR(50),
    image_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);


-- 6. Tabla team_season
CREATE TABLE team_season (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES team(id),
    season_id UUID NOT NULL REFERENCES season(id),
    registration_notes TEXT,
    registration_state registration_state_enum NOT NULL,
    registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by_user_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id),
    UNIQUE(team_id, season_id)
);


-- 7. Tabla player
CREATE TABLE player (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    image_url VARCHAR(500),
    position player_position_enum,
    born_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);


-- 8. Tabla player_team_season
CREATE TABLE player_team_season (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shirt_number INTEGER,
    player_id UUID NOT NULL REFERENCES player(id),
    team_season_id UUID NOT NULL REFERENCES team_season(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id),
    UNIQUE(player_id, team_season_id)
);


-- 9. Tabla phase
CREATE TABLE phase (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    order_number INTEGER NOT NULL,
    type phase_type_enum NOT NULL,
    state state_enum NOT NULL,teams_to_qualify INTEGER DEFAULT 0,
    min_teams_per_group INTEGER DEFAULT 3,
    max_teams_per_group INTEGER,
    auto_generate_next BOOLEAN DEFAULT false;
    season_id UUID NOT NULL REFERENCES season(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);


-- 10. Tabla group
CREATE TABLE cgroup (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    order_number INTEGER NOT NULL,
    phase_id UUID NOT NULL REFERENCES phase(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);


-- 11. Tabla cgroup_team_season
CREATE TABLE cgroup_team_season (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_season_id UUID NOT NULL REFERENCES team_season(id),
    cgroup_id UUID NOT NULL REFERENCES cgroup(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id),
    UNIQUE(cgroup_id, team_season_id)
);


-- 12. Tabla game
CREATE TABLE game (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    home_team_id UUID REFERENCES team_season(id),
    away_team_id UUID REFERENCES team_season(id),
    location VARCHAR(255),
    date TIMESTAMP,
    state game_state_enum NOT NULL,knockout_series_id UUID REFERENCES knockout_series(id),
    match_leg match_leg_enum DEFAULT 'bo1',
    requires_extra_time BOOLEAN DEFAULT false,
    requires_penalties BOOLEAN DEFAULT false,
    season_id UUID NOT NULL REFERENCES season(id),
    phase_id UUID NOT NULL REFERENCES phase(id),
    cgroup_id UUID REFERENCES cgroup(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);


-- 13. Tabla game_result
CREATE TABLE game_result (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    home_team_points INTEGER NOT NULL,
    away_team_points INTEGER NOT NULL,
    home_team_penalties_scored INTEGER,
    away_team_penalties_scored INTEGER,
    home_extra_time_points INTEGER,
    away_extra_time_points INTEGER,
    penalties_taken BOOLEAN DEFAULT false,
    home_penalties_order INTEGER[], -- Orden de penales: 1=gol, 0=fallo
    away_penalties_order INTEGER[],
    game_id UUID UNIQUE NOT NULL REFERENCES game(id),
    winner_id UUID NOT NULL REFERENCES team_season(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id)
);


-- 14. Tabla standing
CREATE TABLE standing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    season_id UUID NOT NULL REFERENCES season(id),
    phase_id UUID NOT NULL REFERENCES phase(id),
    cgroup_id UUID REFERENCES cgroup
(id),
    team_season_id UUID NOT NULL REFERENCES team_season(id),
    position INTEGER NOT NULL,
    score INTEGER NOT NULL,
    games_played INTEGER NOT NULL,
    games_wins INTEGER NOT NULL,
    games_draws INTEGER NOT NULL,
    games_lost INTEGER NOT NULL,
    points_scored INTEGER NOT NULL,
    points_conceded INTEGER NOT NULL,
    points_difference INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id),
    UNIQUE(season_id, phase_id, cgroup_id, team_season_id)
);


-- 15. Tabla rol_assignment
CREATE TABLE rol_assignment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rol_id UUID NOT NULL REFERENCES rol(id),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    entity_id UUID NOT NULL,
    entity_type entity_type_enum NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id),
    UNIQUE(rol_id, user_id, entity_id)
);


-- 16. Tabla knockout_series
CREATE TABLE knockout_series (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phase_id UUID NOT NULL REFERENCES phase(id) ON DELETE CASCADE,
    round_number INTEGER NOT NULL, -- Ronda (octavos=1, cuartos=2, semi=3, final=4)
    home_team_id UUID REFERENCES team_season(id),
    away_team_id UUID REFERENCES team_season(id),
    format knockout_format_enum NOT NULL,
    state state_enum NOT NULL DEFAULT 'scheduled',
    winner_id UUID REFERENCES team_season(id),
    
    -- Configuración específica de la serie
    away_goals_rule BOOLEAN DEFAULT false, -- Gol de visitante vale doble
    extra_time_enabled BOOLEAN DEFAULT true,
    penalties_enabled BOOLEAN DEFAULT true,
    golden_goal_enabled BOOLEAN DEFAULT false,
    
    -- Resultados agregados de la serie
    home_total_score INTEGER DEFAULT 0,
    away_total_score INTEGER DEFAULT 0,
    home_away_goals INTEGER DEFAULT 0, -- Goles de local como visitante
    away_away_goals INTEGER DEFAULT 0, -- Goles de visitante como visitante
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id),
    
    UNIQUE(phase_id, round_number, home_team_id, away_team_id)
);

-- 17. Tabla para reglas de desempate en fases
CREATE TABLE phase_tiebreaker_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phase_id UUID NOT NULL REFERENCES phase(id) ON DELETE CASCADE,
    rule_type standings_tiebreaker_rule_enum,  -- Para ligas/grupos
    knockout_rule_type knockout_tiebreaker_rule_enum,  -- Para eliminatorias
    priority INTEGER NOT NULL,  -- 1 = primera opción, 2 = segunda, etc.
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES auth.users(id),
    CONSTRAINT unique_phase_priority UNIQUE(phase_id, priority),
    CONSTRAINT check_rule_type CHECK (
        (rule_type IS NOT NULL AND knockout_rule_type IS NULL) OR
        (rule_type IS NULL AND knockout_rule_type IS NOT NULL)
    )
);


-- Crear índices para mejorar el rendimiento
CREATE INDEX idx_season_competition ON season(competition_id);
CREATE INDEX idx_team_season_team ON team_season(team_id);
CREATE INDEX idx_team_season_season ON team_season(season_id);
CREATE INDEX idx_player_team_season_player ON player_team_season(player_id);
CREATE INDEX idx_player_team_season_team ON player_team_season(team_season_id);
CREATE INDEX idx_phase_season ON phase(season_id);
CREATE INDEX idx_cgroup_phase ON cgroup(phase_id);
CREATE INDEX idx_cgroup_team_season_cgroup ON cgroup_team_season(cgroup_id);
CREATE INDEX idx_cgroup_team_season_team ON cgroup_team_season(team_season_id);
CREATE INDEX idx_game_season ON game(season_id);
CREATE INDEX idx_game_phase ON game(phase_id);
CREATE INDEX idx_game_cgroup ON game(cgroup_id);
CREATE INDEX idx_game_home_team ON game(home_team_id);
CREATE INDEX idx_game_away_team ON game(away_team_id);
CREATE INDEX idx_game_result_game ON game_result(game_id);
CREATE INDEX idx_standing_season ON standing(season_id);
CREATE INDEX idx_standing_phase ON standing(phase_id);
CREATE INDEX idx_standing_cgroup ON standing(cgroup_id);
CREATE INDEX idx_standing_team ON standing(team_season_id);
CREATE INDEX idx_rol_assignment_entity ON rol_assignment(entity_id, entity_type);
CREATE INDEX idx_rol_assignment_user ON rol_assignment(user_id);
CREATE INDEX idx_knockout_series_phase ON knockout_series(phase_id);
CREATE INDEX idx_knockout_series_teams ON knockout_series(home_team_id, away_team_id);
CREATE INDEX idx_phase_tiebreaker_rules_phase ON phase_tiebreaker_rules(phase_id);


-- Crear función para actualizar el campo updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';


-- Crear triggers para actualizar updated_at en todas las tablas
CREATE TRIGGER update_profile_updated_at BEFORE UPDATE ON public.profile
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_rol_updated_at BEFORE UPDATE ON rol
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_competition_updated_at BEFORE UPDATE ON competition
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_season_updated_at BEFORE UPDATE ON season
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_team_updated_at BEFORE UPDATE ON team
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_team_season_updated_at BEFORE UPDATE ON team_season
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_updated_at BEFORE UPDATE ON player
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_player_team_season_updated_at BEFORE UPDATE ON player_team_season
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_phase_updated_at BEFORE UPDATE ON phase
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cgroup_updated_at BEFORE UPDATE ON cgroup
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cgroup_team_season_updated_at BEFORE UPDATE ON cgroup_team_season
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_game_updated_at BEFORE UPDATE ON game
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_game_result_updated_at BEFORE UPDATE ON game_result
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_standing_updated_at BEFORE UPDATE ON standing
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rol_assignment_updated_at BEFORE UPDATE ON rol_assignment
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_knockout_series_updated_at BEFORE UPDATE ON knockout_series
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_phase_tiebreaker_rules_updated_at BEFORE UPDATE ON phase_tiebreaker_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- Habilitar RLS en todas las tablas
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE rol ENABLE ROW LEVEL SECURITY;
ALTER TABLE competition ENABLE ROW LEVEL SECURITY;
ALTER TABLE season ENABLE ROW LEVEL SECURITY;
ALTER TABLE team ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_season ENABLE ROW LEVEL SECURITY;
ALTER TABLE player ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_team_season ENABLE ROW LEVEL SECURITY;
ALTER TABLE phase ENABLE ROW LEVEL SECURITY;
ALTER TABLE cgroup ENABLE ROW LEVEL SECURITY;
ALTER TABLE cgroup_team_season ENABLE ROW LEVEL SECURITY;
ALTER TABLE game ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_result ENABLE ROW LEVEL SECURITY;
ALTER TABLE standing ENABLE ROW LEVEL SECURITY;
ALTER TABLE rol_assignment ENABLE ROW LEVEL SECURITY;
ALTER TABLE knockout_series ENABLE ROW LEVEL SECURITY;
ALTER TABLE phase_tiebreaker_rules ENABLE ROW LEVEL SECURITY;