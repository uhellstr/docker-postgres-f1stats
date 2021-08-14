create or replace procedure f1_data.p_get_f1_raceresults()
language plpgsql
as $$
declare

	v_race_rec RECORD;
	v_url constant text := 'http://ergast.com/api/f1/{YEAR}/{ROUND}/results.json?limit=1000';
	v_stmt text;
	v_count int := 0;

begin

	FOR v_race_rec IN 
		SELECT season,
				   race 
		FROM f1_data.v_f1_racedates 
		order by season,race
	LOOP
			  
		-- Check that data is not already loaded
		SELECT count(season) INTO v_count
		FROM f1_data.f1_raceresults_json
		WHERE season = v_race_rec.season
			AND race = v_race_rec.race;
				
		-- if data is not loaded then get data from ergast
		IF v_count < 1 THEN
			v_stmt := replace(v_url,'{YEAR}',v_race_rec.season::text);
			v_stmt := replace(v_stmt,'{ROUND}',v_race_rec.race::text);
			-- debug statemt
			raise notice 'stmt: %', v_stmt;
			INSERT INTO f1_data.f1_raceresults_json (fetched_at,season,race,results)
			SELECT now(),v_race_rec.season,v_race_rec.race,f1_data.py_pgrest(v_stmt)::jsonb;
			COMMIT;
		END IF;
				
	END LOOP;

end; $$