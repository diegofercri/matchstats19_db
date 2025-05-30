## Enums
* rol_enum (super_admin, competition_admin, team_admin, game_admin)
* entity_type_enum (competition, season, phase, group, team, player, game, game_result, standing)
* season_state_enum (scheduled, in_progress, stopped, finished, cancelled)
* phase_type_enum (league, group, knockout)
* phase_state_enum (scheduled, in_progress, stopped, finished, cancelled)
* game_state_enum (scheduled, in_progress, break, stopped, finished, cancelled)
* player_position_enum (goalkeeper, defender, midfielder, forward)

---

## Entidades y Atributos

---

### 1. 'profile'
* 'id' (uuid, PK)
* 'name' (string, not null)
* 'surname' (string, not null)
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 2. 'rol'
* 'id' (updated_by_user_id, PK)
* 'type' (rol_enum, not null)
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 15. 'rol_assignment'
* 'id' (uuid, PK)
* 'rol_id' (string, not null, FK → 'rol.id')
* 'user_id' (string, not null, FK → 'user.id')
* 'entity_id' (string, not null)
* 'entity_type' (entity_type_enum, not null)
*  unique ('rol_id', 'user_id', 'entity_id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 3. 'competition'
* 'id' (uuid, PK)
* 'name' (string unique, not null)
* 'description' (string)
* 'organizer' (string)
* 'image_url' (string)
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 4. 'season'
* 'id' (uuid, PK)
* 'start_date' (date, not null)
* 'end_date' (date, not null)
* 'state' (season_state_enum, not null)
* 'location' (string)
* 'competition_id' (string, not null, FK → 'competition.id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 9. 'phase'
* 'id' (uuid, PK)
* 'name' (string)
* 'order_number' (integer, not null)
* 'type' (phase_type_enum, not null)
* 'state' (phase_state_enum, not null)
* 'season_id' (string, not null, FK → 'season.id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 10. 'group'
* 'id' (uuid, PK)
* 'name' (string)
* 'order_number' (integer, not null)
* 'phase_id' (string, not null, FK → 'phase.id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 5. 'team'
* 'id' (uuid, PK)
* 'name' (string, unique, not null)
* 'short_name' (string)
* 'image_url' (string)
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 7. 'player'
* 'id' (uuid, PK)
* 'name' (string, not null)
* 'surname' (string, not null)
* 'image_url' (string)
* 'position' (player_position_enum)
* 'born_date' (date, not null)
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 12. 'game'
* 'id' (uuid, PK)
* 'home_team_id' (string, FK → 'team_season.id')
* 'away_team_id' (string, FK → 'team_season.id')
* 'location' (string)
* 'date' (timestamp)
* 'state' (game_state_enum, not null)
* 'season_id' (string, not null, FK → 'season.id')
* 'phase_id' (string, not null, FK → 'phase.id')
* 'group_id' (string, FK → 'group.id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 13. 'game_result'
* 'id' (uuid, PK)
* 'home_team_points' (integer, not null)
* 'away_team_points' (integer, not null)
* 'home_team_penalties_scored' (integer)
* 'away_team_penalties_scored' (integer)
* 'game_id' (string, unique, not null, FK → 'game.id')
* 'winner_id' (string, not null, FK → 'team_season.id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 14. 'standing'
* 'id' (uuid, PK)
* 'season_id' (string, not null, FK → 'season.id')
* 'phase_id' (string, not null, FK → 'phase.id')
* 'group_id' (string, FK → 'group.id')
* 'team_season_id' (string, not null, FK → 'team_season.id')
* 'position' (integer, not null)
* 'score' (integer, not null)
* 'games_played' (integer, not null)
* 'games_wins' (integer, not null)
* 'games_draws' (integer, not null)
* 'games_lost' (integer, not null)
* 'points_scored' (integer, not null)
* 'points_conceded' (integer, not null)
* 'points_difference' (integer, not null)
*  unique ('season_id', 'phase_id', 'group_id', 'team_season_id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 6. 'team_season'
* 'id' (uuid, PK)
* 'team_id' (string, not null, FK → 'team.id')
* 'season_id' (string, not null, FK → 'season.id')
*  unique ('team_id', 'season_id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 8. 'player_team_season'
* 'id' (uuid, PK)
* 'shirt_number' (integer)
* 'player_id' (string, not null, FK → 'player.id')
* 'team_season_id' (string, not null, FK → 'team_season.id')
*  unique ('player_id', 'team_season_id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---

### 11. 'group_team_season'
* 'id' (uuid, PK)
* 'team_season_id' (string, not null, FK → 'team_season.id')
* 'group_id' (string, not null, FK → 'group.id')
*  unique ('group_id', 'team_season_id')
* 'created_at' (timestamp, not null)
* 'updated_at' (timestamp, not null)
* 'updated_by_user_id' (string, FK → 'user.id')

---






## Relaciones

---

1.  **'user.updated_by_user_id' → 'user.id'**
    * Tipo: 1:N (Autorreferencia para auditoría)
2.  **'[tabla].updated_by_user_id' → 'user.id'** (Común a la mayoría de las tablas)
    * Tipo: 1:N (Auditoría: un user actualiza muchos registros)
3.  **'season.competition_id' → 'competition.id'**
    * Tipo: 1:N (Una competición tiene N seasons)
4.  **'team_season' (Tabla de Cruce para 'team' y 'season')*
    * 'team_season.team_id' → 'team.id'
    * 'team_season.season_id' → 'season.id'
    * Tipo: M:N entre 'team' y 'season'
5.  **'player_team_season' (Tabla de Cruce para 'player' y 'team_season')*
    * 'player_team_season.player_id' → 'player.id'
    * 'player_team_season.team_season_id' → 'team_season.id'
    * Tipo: M:N entre 'player' y 'team_season'
6.  **'phase.season_id' → 'season.id'**
    * Tipo: 1:N (Una season tiene N phases)
7.  **'group.phase_id' → 'phase.id'**
    * Tipo: 1:N (Una phase tiene N groups)
8.  **'group_team_season' (Tabla de Cruce para 'group' y 'team_season')*
    * 'group_team_season.group_id' → 'group.id'
    * 'group_team_season.team_season_id' → 'team_season.id'
    * Tipo: M:N entre 'group' y 'team_season'
9.  **'game.season_id' → 'season.id'**
    * Tipo: 1:N (Una season tiene N games)
10. **'game.phase_id' → 'phase.id'**
    * Tipo: 1:N (Opcional: una phase tiene N games)
11. **'game.group_id' → 'group.id'**
    * Tipo: 1:N (Opcional: un group tiene N games)
12. **'game.home_team_id' → 'team_season.id'**
    * Tipo: 1:N (Opcional: un team_season es local en N games)
13. **'game.away_team_id' → 'team_season.id'**
    * Tipo: 1:N (Opcional: un team_season es visitante en N games)
14. **'game_result.game_id' → 'game.id'**
    * Tipo: 1:1  unique: un game tiene 1 game_result)
15. **'game_result.ganador_id' → 'team_season.id'**
    * Tipo: 1:N (Opcional: un team_season gana N game_results/games)
16. **'standing.season_id' → 'season.id'**
    * Tipo: 1:N (Una season tiene N entradas de clasificación)
17. **'standing.phase_id' → 'phase.id'**
    * Tipo: 1:N (Opcional: una phase tiene N entradas de clasificación)
18. **'standing.group_id' → 'group.id'**
    * Tipo: 1:N (Opcional: un group tiene N entradas de clasificación)
19. **'standing.team_season_id' → 'team_season.id'**
    * Tipo: 1:N (Un team_season tiene N entradas de clasificación)
20. **'asignacionRolUsuario' (Tabla de Cruce para 'user' y 'rol' contextualizada por entidad)*
    * 'asignacionRolUsuario.user_id' → 'user.id'
    * 'asignacionRolUsuario.rol_id' → 'rol.id'
    * Tipo: M:N entre 'user' y 'rol' (para una 'entity_type' y 'entity_id' específicas)