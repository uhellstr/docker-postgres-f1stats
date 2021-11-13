-- Give us the race winner and drivers with score for the last race
select
  vfr.season,
  vfr.race,
  vfr.raceinfo,
  vfr.circuitid,
  vfr.circuitname,
  vfr.locality,
  vfr.country,
  vfr.racedate,
  vfr.drivernumber,
  vfr.driverposition,
  vfr.points,
  vfr.driverid,
  vfr.givenname,
  vfr.familyname,
  vfr.dateofbirth,
  vfr.nationality,
  vfr.constructorid,
  vfr.constructorname,
  vfr.constructornationality,
  vfr.grid,
  vfr.laps,
  vfr.status,
  vfr.racetime
from v_f1_raceresults vfr
where vfr.season = date_part('year', now())::smallint
  and vfr.driverposition is not null
  and vfr.race = (with last_race as -- we need to check if any upcoming races or if the last race for the season is done.
                              (
                                select coalesce(min(race)-1,-1) as race -- check if any upcoming races this seaseon -1 and season is done
                                from v_f1_upcoming_races
                                where season = date_part('year', now())::smallint
                                  --and to_date(race_date,'RRRR-MM-DD') <= trunc(sysdate)
                              )
                              select case when race = -1 then (select max(race)
                                                               from  v_f1_racedates
                                                               where season = date_part('year', now())::smallint)
                                      else race
                                      end race
                                      from last_race
                            )
order by vfr.driverposition asc
fetch first 10 rows only;

-- Get us the top number pole positions for the current season
-- NOT YET TRANSLATED COMPLETLY TO POSTGRESQL
with polesitters as (select familyname
      ,count(familyname) as pole_positions
from v_f1_qualificationtimes
where season = date_part('year', now())::smallint
  and driverposition = 1
group by familyname)
select familyname
       ,pole_positions
 from polesitters
 order by pole_positions desc;
 
-- Give us all world champions in Formula 1!!
select
    d.season,
    d.givenname,
    d.familyname,
    d.nationality,    
    d.points,
    d.wins,
    d.info,
    d.constructorname,
    d.constructorinfo,
    d.constructornationality
from v_f1_driverstandings d
where d.race = (select max(e.race)
                from v_f1_driverstandings e
                 where e.season = d.season)
      and d.driverposition = 1
      and d.season <= (select season -- Is current season finished yet?
                       from
                       (
                         select to_date(r.race_date,'RRRR-MM-DD') as race_date
                                ,case 
                                   when r.race_date < trunc(sysdate) then to_char(trunc(sysdate),'RRRR')
                                   when r.race_date > trunc(sysdate) then to_char(to_number(to_char(trunc(sysdate),'RRRR'))-1)
                                   else '1900'
                                 end as season
                         from f1_access.v_f1_seasons_race_dates r
                         where r.season = d.season
                           and to_number(r.round) in (select max(to_number(rd.round)) from f1_access.v_f1_seasons_race_dates rd
                                                      where rd.season  = r.season)
                        ))
order by d.season desc;