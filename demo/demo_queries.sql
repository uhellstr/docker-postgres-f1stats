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
    d.season
    ,d.givenname
    ,d.familyname
    ,d.nationality    
    ,d.points
    ,d.wins
    ,d.info
    ,d.constructorname
    ,d.constructorinfo
    ,d.constructornationality
from v_f1_driverstandings d
where d.race = (select max(e.race)
                from v_f1_driverstandings e
                where e.season = d.season)
      and d.driverposition = 1
      and d.season <= (select x.season -- Is current season finished yet?
                       from
                       (
                         select to_date(r.racedate::varchar,'YYYY-MM-DD') as racedate
                                ,case 
                                   when to_date(r.racedate::varchar,'YYYY-MM-DD') < now()::date then date_part('year', now())::smallint
                                   when to_date(r.racedate::varchar,'YYYY-MM-DD') > now()::date then date_part('year', now())::smallint -1
                                   else 1900::smallint
                                 end as season
                         from v_f1_racedates r
                         where r.season = d.season
                           and r.race in (select max(rd.race) 
													                from v_f1_racedates rd
                                          where rd.season  = r.season)
                        ) x )
order by d.season desc;

-- Give us the number of championships a champ has got! E.g who is the ultimate champ!
select y.givenname,
       y.familyname,
       y.nationality,
       y.championships_won
from
(select x.driverid,
       x.givenname,
       x.familyname,
       x.nationality,
       count(x.driverid) as championships_won
from 
(select
    d.season,
    d.race,
    d.driverposition,
    d.positiontext,
    d.points,
    d.wins,
    d.driverid,
    d.info,
    d.givenname,
    d.familyname,
    d.dateofbirth,
    d.nationality,
    d.constructorid,
    d.constructorinfo,
    d.constructorname,
    d.nationality as contructornationality
from
    v_f1_driverstandings d
    where d.race = (select max(e.race)
                    from v_f1_driverstandings e
                    where e.season = d.season)
      and d.driverposition = 1
      and d.season <= (select x.season -- Is current season finished yet?
                       from
                       (
                         select to_date(r.racedate::varchar,'YYYY-MM-DD') as racedate
                                ,case 
                                   when to_date(r.racedate::varchar,'YYYY-MM-DD') < now()::date then date_part('year', now())::smallint
                                   when to_date(r.racedate::varchar,'YYYY-MM-DD') > now()::date then date_part('year', now())::smallint -1
                                   else 1900::smallint
                                 end as season
                         from v_f1_racedates r
                         where r.season = d.season
                           and r.race in (select max(rd.race) 
													                from v_f1_racedates rd
                                          where rd.season  = r.season)
                        ) x )
) x group by driverid,givenname,familyname,nationality
) y order by championships_won desc;

-- Give us the constructor champions over the years
select
  c.season,
  c.points,
  c.wins,
  c.constructorname,
  c.info as constructorinfo,
  c.nationality as contructornationality
from v_f1_constructorstandings c
where c.race = (select max(d.race)
                from v_f1_racedates d
                where d.season = c.season)
  and c.constructorposition = '1'
  and c.season <=  (select x.season -- Is current season finished yet?
                       from
                       (
                         select to_date(r.racedate::varchar,'YYYY-MM-DD') as racedate
                                ,case 
                                   when to_date(r.racedate::varchar,'YYYY-MM-DD') < now()::date then date_part('year', now())::smallint
                                   when to_date(r.racedate::varchar,'YYYY-MM-DD') > now()::date then date_part('year', now())::smallint -1
                                   else 1900::smallint
                                 end as season
                         from v_f1_racedates r
                         where r.season = c.season
                           and r.race in (select max(rd.race) 
													                from v_f1_racedates rd
                                          where rd.season  = r.season)
                        ) x )
order by c.season desc;