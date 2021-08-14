create or replace procedure f1_data.p_get_f1_laptimes()
language plpgsql
as $$
declare
	-- variable declaration
	v_race_rec RECORD;
	v_url constant text := 'http://ergast.com/api/f1/{YEAR}/{ROUND}/laps/{LAP}.json?limit=1000';
	v_stmt text;
	v_count smallint := 0;
	v_laps  smallint := 0;
	
begin

	FOR v_race_rec IN 
		SELECT 	frd.season,
						frd.race, 
						f1r.laps
		FROM f1_data.v_f1_racedates frd
		INNER JOIN f1_data.v_f1_raceresults f1r
		ON frd.season = f1r.season
			AND frd.race = f1r.race
			WHERE frd.season > 1995 -- No data before 1996  
				AND f1r.driverposition = 1
			ORDER BY frd.season, frd.race ASC		
	LOOP
	
		v_laps := v_race_rec.laps;
		raise notice 'no laps: %', v_laps;
				
		FOR lapcount in 1..v_laps
		LOOP
					
			-- Check that data is not already loaded
			SELECT count(season) INTO v_count
			FROM f1_data.f1_laptimes_json
			WHERE season = v_race_rec.season
				AND race = v_race_rec.race
				AND lap = lapcount;
				
			-- if data is not loaded then get data from ergast
			IF v_count < 1 THEN
				v_stmt := replace(v_url,'{YEAR}',v_race_rec.season::text);
				v_stmt := replace(v_stmt,'{ROUND}',v_race_rec.race::text);
				v_stmt := replace(v_stmt,'{LAP}',lapcount::text);
				-- debug statemt
				raise notice 'stmt: %', v_stmt;						
				INSERT INTO f1_data.f1_laptimes_json (fetched_at,season,race,lap,laptime)
				SELECT now(),v_race_rec.season,v_race_rec.race,lapcount::smallint,f1_data.py_pgrest(v_stmt)::jsonb;	
				COMMIT;
			END IF; -- v_count
					
		END LOOP; -- lapcount
	END LOOP; -- season,race

end; $$