# Politicas de Seguridad

## Políticas para competition

- Una competition es visible para todos
- Todos los usuarios pueden crear competitions
- Solo los competition admin pueden borrar, crear o actualizar competitions de sus competiciones correspondientes

## Políticas para season

- Una season es visible para todos
- Solo los competition admin pueden borrar, crear o actualizar season de sus competiciones correspondientes

## Políticas para team

- Un team es visible para todos y todos pueden crear equipos
- Solo los team admin pueden actualizar y borrar sus equipos correspondientes

## Políticas para player

- Un player es visible para todos
- Solo los team admin pueden borrar, crear o actualizar players de sus equipos correspondientes

## Políticas para game

- Un game es visible para todos
- Los game admin pueden actualizar sus game correspondientes
- Solo los competition admin pueden borrar, crear o actualizar game en sus competiciones correspondientes

## Políticas para game_result

- Un game_result es visible para todos
- Solo los game admin y competition admin pueden borrar, crear o actualizar resultados en sus game correspondientes

## Políticas para standing

- Un standing es visible para todos
- Debe actualizarse de manera automática cuando se actualiza el game_result correspondiente
- Debe borrarse cuando se elimina su season correspondiente

## Políticas para rol_assignment

- Un rol assignment es visible para todos
- Un competition admin puede asignar game admin a los game correspondientes a su competición
- Un primary competition admin puede asignar o eliminar a competition admin a sus competiciones
- Un primary team admin puede asignar o eliminar team admin a sus equipos

## Políticas para rol

- Nadie puede borrar, crear o actualizar roles, solo se puede desde supabase

## Políticas para team_season

- Un team season es visible para todos
- Solo los team admin pueden borrar (antes de ser aceptados) o crear team season de sus equipos correspondientes
- Solo los competition admin pueden borrar o actualizar team season en sus season correspondientes a su competicion
  Nota: un team admin solicita inscribrise en una season de una competition y solo los competition admin pueden aceptar o rechazar su solicitud

## Políticas para player_team_season

- Un player team season es visible para todos
- Solo los team admin pueden borrar, crear o actualizar player team season en sus equipos correspondientes

## Políticas para phase

- Un phase es visible para todos
- Solo los competition admin pueden borrar, crear o actualizar phase de sus competiciones correspondientes

## Políticas para cgroup

- Un cgroup es visible para todos
- Solo los competition admin pueden borrar, crear o actualizar cgroup de sus competiciones correspondientes

## Políticas para cgroup_team_season

- Un cgroup team season es visible para todos
- Solo los competition admin pueden borrar, crear o actualizar cgroup team season en sus cgroup correspondientes

## Políticas para profile

- Un profile es visible para todos
- Solo los usuarios pueden actualizar o borrar su propio profile

## Políticas para super_admin

- Un super admin es visible para nadie
- Los super admins pueden crear, actualizar o borrar cualquier entidad (no estoy seguro de si necesito algo asi de inseguro)

Para las fases hay que incluir una logica un tanto especial, hay 3 tipos de fases (liga, grupos y eliminatorias) que el usuario puede añadir a su temporada en el orden que el quiera y cuantas veces quiera, debe especificarnos cuantos equipos clasifican a la siguiente fase y en base a esto construir la siguiente fase, dependiendo de si es una liga, grupos o eliminatorias tendremos una logica diferente ya que para grupos debemos dar a elegir al usuario la opcion de elegir cuantos equipos quiere tener en cada grupo siempre manteniendo un minimo de 3 equipos en cada grupo, si no se puede cumplir esto se debe dar un error y no se puede crear la fase, es decir, si el numero es menor a 6 no se puede crear la fase de grupos xq al menos deben existir 2 grupos. Para las ligas podemos reciclar el codigo de grupos y tratar la liga como un unico grupo o los grupos como varias ligas, es decir, ambos seria un objeto "clasificacion" la unica diferencia en la fase es que la liga solo necesitaria 3 equipos. Y para las eliminatorias solo necesitamos 2 equipos, sin son mas de 2 debemos dividir los equipos entre 2 para crear 2 subfases de la eliminatoria, si el numero de equipos es impar debemos colocar a los equipos con mejor puntacion en un enfrentamiento especial (avance directo) en el que no se enfrentan a nadie sino que avanza a la siguiente subfase de la eliminatoria. Todo esto debe funcionar de manera automatica sin intervencion del usuario. El solo debe aceptar o crear los equipos que van a jugar, las fases que quiere y su tipo, los equipos que clasifican en cada fase a la siguiente y la forma de decidir quien clasifica o que pasa en caso de empate para lo que debemos tener distintas reglas que el usuario puede priorizar, por ejemplo, en las clasificaciones las reglas basicas son por enfrentamiento directo o diferencia de puntos anotados, pero en las eliminatorias esas reglas no existen si no que se puede decidir jugar un tiempo extra o prorroga, un partido extra, una tanda de penaltis, gol de oro, etc.

Me he dado cuenta que un administrador de competicion debe poder crear equipos dentro de su competicion, para poder abarcar la posibilidad de que los equipos que juegan su competicion no quieran registrarse en la app. Aunque este puede trasferir luego el primary team admin a otro usuario para que gestione ese equipo y de esta forma aunque los equipos se creen para una competicion no son exclusivos de esa competicion, seguramente haya que cambiar las politicas de team_season para reflefarlo correctamente.

Quiero que me ayudes a plasmar todo esto usando Supabase
