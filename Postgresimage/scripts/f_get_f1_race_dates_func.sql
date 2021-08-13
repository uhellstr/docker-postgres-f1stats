CREATE OR REPLACE FUNCTION f1_data.f_get_f1_race_dates() RETURNS VOID AS $$
	DECLARE

			v_race_rec RECORD;
			v_url constant text := 'http://ergast.com/api/f1/{YEAR}.json?limit=1000';
			v_stmt text;
			v_count int := 0;
		
	BEGIN

			FOR v_race_rec IN 
				SELECT season 
				FROM f1_data.v_f1_season 
				order by season
			LOOP
			  
				-- Check that data is not already loaded
				SELECT count(season) INTO v_count
				FROM f1_data.f1_racedates_json
				WHERE season = v_race_rec.season;
				
				-- if data is not loaded then get data from ergast
				IF v_count < 1 THEN
					v_stmt := replace(v_url,'{YEAR}',v_race_rec.season::text);
					-- debug statemt
					raise notice 'stmt: %', v_stmt;
					INSERT INTO f1_data.f1_racedates_json (fetched_at,season,racedate)
					SELECT now(),v_race_rec.season,f1_data.py_pgrest(v_stmt)::jsonb;
				END IF;
				
			END LOOP;
			RETURN;
		
	END;
$$ LANGUAGE plpgsql
;
