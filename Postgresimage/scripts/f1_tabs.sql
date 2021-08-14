CREATE TABLE F1_DATA.F1_SEASONS_JSON (
	id serial NOT NULL PRIMARY KEY,
	fetched_at TIMESTAMP,
	f1season jsonb NOT NULL
);

CREATE TABLE F1_DATA.F1_CONSTRUCTORS_JSON (	
  ID serial NOT NULL PRIMARY KEY, 
  FETCHED_AT TIMESTAMP, 
  CONSTRUCTORS jsonb NOT NULL
);

CREATE TABLE F1_DATA.F1_CONSTRUCTORSTANDINGS_JSON (
  ID serial NOT NULL PRIMARY KEY, 
  FETCHED_AT TIMESTAMP, 
  SEASON SMALLINT, 
  CONSTRUCTORSTANDINGS jsonb NOT NULL
);
	
CREATE TABLE F1_DATA.F1_DRIVERS_JSON ( 
  ID serial NOT NULL PRIMARY KEY, 
  FETCHED_AT TIMESTAMP, 
  DRIVERS jsonb NOT NULL 
);

CREATE TABLE F1_DATA.F1_DRIVERSTANDINGS_JSON ( 
  ID serial NOT NULL PRIMARY KEY , 
  FETCHED_AT TIMESTAMP, 
  SEASON SMALLINT, 
  DRIVERSTANDINGS jsonb NOT NULL
);

CREATE TABLE F1_DATA.F1_TRACKS_JSON ( 
  ID serial NOT NULL PRIMARY KEY, 
  FETCHED_AT TIMESTAMP, 
  TRACKS jsonb NOT NULL
);

CREATE TABLE F1_DATA.F1_RACEDATES_JSON (
  ID serial NOT NULL PRIMARY KEY, 
  FETCHED_AT TIMESTAMP, 
  SEASON SMALLINT, 
  RACEDATE jsonb NOT NULL
);

CREATE TABLE F1_DATA.F1_RACERESULTS_JSON ( 
  ID serial NOT NULL PRIMARY KEY, 
  FETCHED_AT TIMESTAMP, 
  SEASON SMALLINT, 
  RACE SMALLINT, 
  RESULTS jsonb NOT NULL
);

CREATE TABLE F1_DATA.F1_QUALIFICATION_JSON (
  ID serial NOT NULL PRIMARY KEY, 
  FETCHED_AT TIMESTAMP, 
  SEASON SMALLINT, 
  RACE SMALLINT, 
  QUALIFICATION jsonb NOT NULL
 );
 
CREATE TABLE F1_DATA.F1_LAPTIMES_JSON (
  ID serial NOT NULL PRIMARY KEY, 
  FETCHED_AT TIMESTAMP, 
  SEASON SMALLINT, 
  RACE SMALLINT,
  LAP SMALLINT,	
  LAPTIME jsonb NOT NULL
 );

CREATE INDEX CONCURRENTLY IDX_LAPTIMES ON F1_DATA.f1_laptimes_json (season,race,lap);	
 
-- SEASONS FROM JSON TO RELATIONAL
CREATE OR REPLACE VIEW F1_DATA.V_F1_SEASON AS
SELECT 	id,
        fetched_at,
        (seasontable ->> 'season')::INTEGER as season, 
        seasontable ->> 'url' as info
FROM F1_DATA.f1_seasons_json f1s
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1s.f1season -> 'MRData' -> 'SeasonTable' -> 'Seasons' ) as seasontable
ORDER BY season ASC;

-- CONSTRUCTORS from JSON to relational
CREATE OR REPLACE VIEW F1_DATA.V_F1_CONSTRUCTORS AS
SELECT 	id,
        fetched_at,
        constructortable ->> 'name' as constructorname,
        constructortable ->> 'nationality' as nationality,
        constructortable ->> 'constructorId' as constructorid,
        constructortable ->> 'url' as info
FROM F1_DATA.f1_constructors_json f1c
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1c.constructors -> 'MRData' -> 'ConstructorTable' -> 'Constructors') as constructortable
ORDER BY constructorid;

--- CONSTRUCTORSTANDINGS from JSON to relational
CREATE OR REPLACE VIEW F1_DATA.V_F1_CONSTRUCTORSTANDINGS AS
SELECT 	id,
        fetched_at,
        season,
        (constructortable ->> 'round')::SMALLINT as race,
        standings -> 'Constructor' ->> 'constructorId' as conctructorid,
        standings ->> 'positionText' as constructorposition,
        standings ->> 'wins' as wins,
        (standings ->> 'points')::REAL as points,
        standings -> 'Constructor' ->> 'url' as info,
        standings -> 'Constructor' ->> 'name' as constructorname,
        standings -> 'Constructor' ->> 'nationality' as nationality
FROM F1_DATA.f1_constructorstandings_json f1c
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1c.constructorstandings -> 'MRData' -> 'StandingsTable' -> 'StandingsLists') as constructortable
CROSS JOIN JSONB_ARRAY_ELEMENTS(constructortable -> 'ConstructorStandings') as standings
ORDER BY season ASC, points DESC;

--- DRIVERSTANDINGS from JSON to relational
CREATE OR REPLACE VIEW F1_DATA.V_F1_DRIVERSTANDINGS AS 
SELECT  id,
		    fetched_at,
		    season,
		    (drivertable ->> 'round')::SMALLINT as race,
		    (standings ->> 'wins')::SMALLINT as wins,
		    standings ->> 'positionText' as positiontext,
		    (standings ->> 'points')::REAL as points,
		    (standings ->> 'position')::SMALLINT as driverposition,
		    standings -> 'Driver' ->> 'url' as info,
		    standings -> 'Driver' ->> 'driverId' as driverid,
		    standings -> 'Driver' ->> 'givenName' as givenname,
		    standings -> 'Driver' ->> 'familyName' as familyname,
		    (standings -> 'Driver' ->> 'dateOfBirth')::DATE as dateofbirth,
		    standings -> 'Driver' ->> 'nationality' as nationality,
		    constructors ->> 'url' as constructorinfo,
		    constructors ->> 'name' as constructorname,
		    constructors ->> 'nationality' as constructornationality,
		    constructors ->> 'constructorId' as constructorid			
FROM F1_DATA.f1_driverstandings_json f1d
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1d.driverstandings -> 'MRData' -> 'StandingsTable' -> 'StandingsLists') as drivertable
CROSS JOIN JSONB_ARRAY_ELEMENTS(drivertable -> 'DriverStandings') as standings
CROSS JOIN JSONB_ARRAY_ELEMENTS(standings -> 'Constructors') as constructors
ORDER BY season ASC, driverposition ASC;

-- DRIVERS from JSON to relational
CREATE OR REPLACE VIEW F1_DATA.V_F1_DRIVERS AS
SELECT 	id,
		    fetched_at,
       	drivertable ->> 'driverId' as driverid,
       	drivertable ->> 'givenName' as givenname,
		    drivertable ->> 'familyName' as familyname,
		    drivertable ->> 'dateOfBirth' as dateofbirth,
		    drivertable ->> 'nationality' as nationality,
		    drivertable ->> 'url' as info
FROM F1_DATA.f1_drivers_json f1d
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1d.drivers -> 'MRData' -> 'DriverTable' -> 'Drivers') as drivertable
ORDER BY driverid;

-- TRACKS from JSON to relational
CREATE OR REPLACE VIEW F1_DATA.v_f1_tracks AS
SELECT 	id,
		    fetched_at,
		    circuittable ->> 'circuitId' as circuitid,
		    circuittable ->> 'circuitName' as circuitname,
		    circuittable ->> 'url' as info,
		    circuittable -> 'Location' ->> 'lat' as lat,
		    circuittable -> 'Location' ->> 'long' as long,
		    circuittable -> 'Location' ->> 'country' as country,
		    circuittable -> 'Location' ->> 'locality' as locality
FROM F1_DATA.f1_tracks_json f1t
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1t.tracks -> 'MRData' -> 'CircuitTable' -> 'Circuits') as circuittable
ORDER BY circuitid asc;

-- RACEDATES from JSON to relational
CREATE OR REPLACE VIEW F1_DATA.V_F1_RACEDATES AS
SELECT  f1r.id,
        f1r.fetched_at,
		    f1r.season,
        racetable ->> 'url' as info,
        (racetable ->> 'date')::DATE as racedate,
		    (racetable ->> 'round')::INTEGER  as race,
		    --(racetable ->> 'season')::INTEGER  as season,
		    racetable ->> 'raceName' as racename,
		    racetable -> 'Circuit' ->> 'url' as raceinfo,
		    racetable -> 'Circuit' ->> 'circuitId' as circuitid,
		    racetable -> 'Circuit' ->> 'circuitName' as circuitname,
		    racetable -> 'Circuit' -> 'Location' ->> 'lat' as lat,
		    racetable -> 'Circuit' -> 'Location' ->> 'long' as long,
		    racetable -> 'Circuit' -> 'Location' ->> 'locality' as locality				 
FROM F1_DATA.f1_racedates_json f1r
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1r.racedate -> 'MRData' ->'RaceTable' -> 'Races') as racetable
ORDER BY season,race ASC;

-- RACERESULTS from JSON to relational
CREATE OR REPLACE VIEW F1_DATA.V_F1_RACERESULTS AS
SELECT 	id,
		    fetched_at,
		    season,
		    race,
		    racetable ->> 'url' as raceinfo,
		    racetable ->> 'date' as racedate,
		    racetable -> 'Circuit' ->> 'url' as trackinfo,
		    racetable -> 'Circuit' ->> 'circuitId' as circuitid,
		    racetable -> 'Circuit' ->> 'circuitName' as circuitname,
		    racetable -> 'Circuit' -> 'Location' ->> 'lat' as lat,
		    racetable -> 'Circuit' -> 'Location' ->> 'long' as long,
		    racetable -> 'Circuit' -> 'Location' ->> 'country' as country,
		    racetable -> 'Circuit' -> 'Location' ->> 'locality' as locality,
		    resulttable -> 'Time' ->> 'time' as racetime,
		    resulttable -> 'Time' ->> 'millis' as millis,
		    (resulttable ->> 'grid')::SMALLINT as grid,
		    (resulttable ->> 'laps')::SMALLINT as laps,
		    resulttable -> 'Driver' ->> 'url' as driverinfo,
		    resulttable -> 'Driver' ->> 'driverId' as driverid,
		    resulttable -> 'Driver' ->> 'givenName' as givenname,
		    resulttable -> 'Driver' ->> 'familyName' as familyname,
		    (resulttable -> 'Driver' ->> 'dateOfBirth')::DATE as dateofbirth,
		    resulttable -> 'Driver' ->> 'nationality' as nationality,
		    resulttable ->> 'number' as drivernumber,
		    (resulttable ->> 'points')::REAL as points,
		    resulttable ->> 'status' as status,
		    (resulttable ->> 'position')::SMALLINT as driverposition,
		    resulttable ->> 'positionText' as positiontext,
		    resulttable -> 'Constructor' ->> 'url' as constructorinfo,
		    resulttable -> 'Constructor' ->> 'name' as constructorname,
		    resulttable -> 'Constructor' ->> 'nationality' as constructornationality,
		    resulttable -> 'Constructor' ->> 'constructorId' as constructorid
FROM F1_DATA.f1_raceresults_json f1r
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1r.results -> 'MRData' -> 'RaceTable' -> 'Races') as racetable
CROSS JOIN JSONB_ARRAY_ELEMENTS(racetable -> 'Results') as resulttable
ORDER BY season,race,driverposition ASC;

-- QUALIFICATIONRESULTS from JSON to relational
CREATE OR REPLACE VIEW F1_DATA.V_F1_QUALIFICATIONTIMES AS
SELECT  f1q.id,
		    f1q.fetched_at,
		    f1q.season,
		    f1q.race,
		    racetable ->> 'url' as raceinfo,
		    (racetable ->> 'date')::DATE as racedate,
		    racetable ->> 'time' as racestart,
		    racetable ->> 'raceName' as racename,
		    racetable -> 'Circuit' ->> 'url' as circuitinfo,
		    racetable -> 'Circuit' ->> 'circuitId' as circuitid,
		    racetable -> 'Circuit' ->> 'circuitName' as circuitname,
		    racetable -> 'Circuit' -> 'Location' ->> 'lat' as lat,
		    racetable -> 'Circuit' -> 'Location' ->> 'long' as long,
		    racetable -> 'Circuit' -> 'Location' ->> 'country' as country,
		    racetable -> 'Circuit' -> 'Location' ->> 'locality' as locality,
		    resulttable ->> 'Q1' as q1,
		    resulttable ->> 'Q2' as q2,
		    resulttable ->> 'Q3' as q3,
		    resulttable ->> 'number' as drivernumber,
		    (resulttable ->> 'position')::SMALLINT as driverposition,
		    resulttable -> 'Driver' ->> 'url' as driverinfo,
		    resulttable -> 'Driver' ->> 'code' as drivercode,
		    resulttable -> 'Driver' ->> 'driverId' as driverid,
		    resulttable -> 'Driver' ->> 'givenName' as givenname,
		    resulttable -> 'Driver' ->> 'familyName' as familyname,
		    (resulttable -> 'Driver' ->> 'dateOfBirth')::DATE	as dateofbirth,
		    resulttable -> 'Driver' ->> 'nationality' as nationality,
		    (resulttable -> 'Driver' ->> 'permanentNumber')::SMALLINT as permanentnumber,
		    resulttable -> 'Constructor' ->> 'url' as constructorinfo,
		    resulttable -> 'Constructor' ->> 'name' as constructorname,
		    resulttable -> 'Constructor' ->> 'nationality' as constructornationality,
		    resulttable -> 'Constructor' ->> 'constructorId' as constructorid
FROM F1_DATA.f1_qualification_json f1q
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1q.qualification -> 'MRData' -> 'RaceTable' -> 'Races') as racetable
CROSS JOIN JSONB_ARRAY_ELEMENTS(racetable -> 'QualifyingResults') as resulttable
ORDER BY f1q.season,f1q.race,driverposition ASC;

CREATE OR REPLACE VIEW F1_DATA.V_F1_LAPTIMES AS
SELECT	f1j.id,
		    f1j.fetched_at,
		    f1j.season,
		    f1j.race,
		    f1j.lap,
		    (laptable ->> 'date')::DATE as racedate,
		    laptable ->> 'time' as racetime,
		    laptable ->> 'raceName' as racename,
		    laptable -> 'Circuit' ->> 'url' as circuitinfo,
		    laptable -> 'Circuit' ->> 'circuitId' as circuitid,
		    laptable -> 'Circuit' ->> 'circuitName' as circuitname,
		    laptable -> 'Circuit' -> 'Location' ->> 'lat' as lat,
		    laptable -> 'Circuit' -> 'Location' ->> 'long' as long,
		    laptable -> 'Circuit' -> 'Location' ->> 'country' as country,
		    laptable -> 'Circuit' -> 'Location' ->> 'locality' as locality,
		    laptimetable ->> 'time' as laptime,
		    laptimetable ->> 'driverId' as driverid,
		    (laptimetable ->> 'position')::SMALLINT as driverposition
FROM F1_DATA.f1_laptimes_json f1j
CROSS JOIN JSONB_ARRAY_ELEMENTS(f1j.laptime -> 'MRData' -> 'RaceTable' -> 'Races') as laptable
CROSS JOIN JSONB_ARRAY_ELEMENTS(laptable -> 'Laps') as timingtable
CROSS JOIN JSONB_ARRAY_ELEMENTS(timingtable -> 'Timings') as laptimetable
ORDER BY f1j.season,f1j.race,f1j.lap ASC;

CREATE MATERIALIZED VIEW F1_DATA.M_V_F1_LAPTIMES AS
SELECT * FROM F1_DATA.v_f1_laptimes;

CREATE INDEX CONCURRENTLY IDX_LAPTIMES_M ON F1_DATA.m_v_f1_laptimes (season,race,lap);
 
-- Upcoming races finds out races in a a season
CREATE OR REPLACE VIEW F1_DATA.V_F1_UPCOMING_RACES AS
select a.season,
       a.race,
       a.racedate
FROM F1_DATA.v_f1_racedates a
WHERE a.race NOT IN ( SELECT b.race
                      FROM F1_DATA.v_f1_raceresults b
                      WHERE a.season = b.season
                        AND a.race = b.race)
  AND a.season = TO_CHAR(now()::date, 'yyyy')::smallint;
	
--================================================================================
