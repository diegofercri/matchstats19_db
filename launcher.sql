-- Habilitar extensión UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crear tipos ENUM
CREATE TYPE rol_enum AS ENUM ('super_admin', 'competition_admin', 'team_admin', 'game_admin');
CREATE TYPE entity_type_enum AS ENUM ('competition', 'season', 'phase', 'cgroup', 'team', 'player', 'game', 'game_result', 'standing');
CREATE TYPE season_state_enum AS ENUM ('scheduled', 'in_progress', 'stopped', 'finished', 'cancelled');
CREATE TYPE phase_type_enum AS ENUM ('league', 'cgroup', 'knockout');
CREATE TYPE phase_state_enum AS ENUM ('scheduled', 'in_progress', 'stopped', 'finished', 'cancelled');
CREATE TYPE game_state_enum AS ENUM ('scheduled', 'in_progress', 'break', 'stopped', 'finished', 'cancelled');
CREATE TYPE player_position_enum AS ENUM ('goalkeeper', 'defender', 'midfielder', 'forward');

-- 1. Tabla extended_user
CREATE TABLE extended_user (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id)
);

-- 2. Tabla rol
CREATE TABLE rol (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type rol_enum NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id)
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
    updated_by_user_id UUID REFERENCES extended_user(id)
);

-- 4. Tabla season
CREATE TABLE season (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    state season_state_enum NOT NULL,
    location VARCHAR(255),
    competition_id UUID NOT NULL REFERENCES competition(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id)
);

-- 5. Tabla team
CREATE TABLE team (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) UNIQUE NOT NULL,
    short_name VARCHAR(50),
    image_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id)
);

-- 6. Tabla team_season
CREATE TABLE team_season (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id UUID NOT NULL REFERENCES team(id),
    season_id UUID NOT NULL REFERENCES season(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id),
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
    updated_by_user_id UUID REFERENCES extended_user(id)
);

-- 8. Tabla player_team_season
CREATE TABLE player_team_season (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shirt_number INTEGER,
    player_id UUID NOT NULL REFERENCES player(id),
    team_season_id UUID NOT NULL REFERENCES team_season(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id),
    UNIQUE(player_id, team_season_id)
);

-- 9. Tabla phase
CREATE TABLE phase (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    order_number INTEGER NOT NULL,
    type phase_type_enum NOT NULL,
    state phase_state_enum NOT NULL,
    season_id UUID NOT NULL REFERENCES season(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id)
);

-- 10. Tabla group
CREATE TABLE cgroup (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    order_number INTEGER NOT NULL,
    phase_id UUID NOT NULL REFERENCES phase(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id)
);

-- 11. Tabla cgroup_team_season
CREATE TABLE cgroup_team_season (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_season_id UUID NOT NULL REFERENCES team_season(id),
    cgroup_id UUID NOT NULL REFERENCES cgroup
(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id),
    UNIQUE(cgroup_id, team_season_id)
);

-- 12. Tabla game
CREATE TABLE game (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    home_team_id UUID REFERENCES team_season(id),
    away_team_id UUID REFERENCES team_season(id),
    location VARCHAR(255),
    date TIMESTAMP,
    state game_state_enum NOT NULL,
    season_id UUID NOT NULL REFERENCES season(id),
    phase_id UUID NOT NULL REFERENCES phase(id),
    cgroup_id UUID REFERENCES cgroup
(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id)
);

-- 13. Tabla game_result
CREATE TABLE game_result (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    home_team_points INTEGER NOT NULL,
    away_team_points INTEGER NOT NULL,
    home_team_penalties_scored INTEGER,
    away_team_penalties_scored INTEGER,
    game_id UUID UNIQUE NOT NULL REFERENCES game(id),
    winner_id UUID NOT NULL REFERENCES team_season(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id)
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
    updated_by_user_id UUID REFERENCES extended_user(id),
    UNIQUE(season_id, phase_id, cgroup_id, team_season_id)
);

-- 15. Tabla rol_assignment
CREATE TABLE rol_assignment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rol_id UUID NOT NULL REFERENCES rol(id),
    extended_user_id UUID NOT NULL REFERENCES extended_user(id),
    entity_id UUID NOT NULL,
    entity_type entity_type_enum NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by_user_id UUID REFERENCES extended_user(id),
    UNIQUE(rol_id, extended_user_id, entity_id)
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
CREATE INDEX idx_rol_assignment_user ON rol_assignment(extended_user_id);

-- Crear función para actualizar el campo updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Crear triggers para actualizar updated_at en todas las tablas
CREATE TRIGGER update_extended_user_updated_at BEFORE UPDATE ON extended_user
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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