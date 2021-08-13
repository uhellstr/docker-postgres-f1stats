-- Call REST service and insert into table. 
-- Magic happens using python stored function py_pgrest
DELETE FROM f1_data.f1_seasons_json;
INSERT INTO f1_data.f1_seasons_json (fetched_at,f1season)
SELECT now(),f1_data.py_pgrest('http://ergast.com/api/f1/seasons.json?limit=1000')::jsonb;

DELETE FROM f1_data.f1_constructors_json;
INSERT INTO f1_data.f1_constructors_json (fetched_at,constructors)
SELECT now(),f1_data.py_pgrest('http://ergast.com/api/f1/constructors.json?limit=1000')::jsonb;

DELETE FROM f1_data.f1_drivers_json;
INSERT INTO f1_data.f1_drivers_json (fetched_at,drivers)
SELECT now(),f1_data.py_pgrest('http://ergast.com/api/f1/drivers.json?limit=2000')::jsonb;

DELETE FROM f1_data.f1_tracks_json;
INSERT INTO f1_data.f1_tracks_json (fetched_at,tracks)
SELECT now(),f1_data.py_pgrest('http://ergast.com/api/f1/circuits.json?limit=1000')::jsonb;

-- call function to insert constructorstandings
DO $$ BEGIN
    PERFORM f1_data.f_get_f1_constructorstandings();
END $$;

-- call function to insert driverrstandings
DO $$ BEGIN
    PERFORM f1_data.f_get_f1_driverstandings();
END $$;

-- call function to insert race_dates
DO $$ BEGIN
    PERFORM f1_data.f_get_f1_race_dates();
END $$;

DO $$ BEGIN
    PERFORM f1_data.f_get_f1_raceresults();
END $$;


-- call function to insert race qualification times
DO $$ BEGIN
    PERFORM f1_data.f_get_f1_qualification();
END $$;

-- call function to insert laptimes
DO $$ BEGIN
    PERFORM f1_data.f_get_f1_laptimes();
END $$;

-- refresh materialized view
REFRESH MATERIALIZED VIEW f1_data.m_v_f1_laptimes;
-- Collect stats, best to perform as supseruser but better then nothing..
ANALYZE;

