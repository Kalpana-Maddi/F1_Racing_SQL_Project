create database f1_race;
use f1_race;
select * from f1_racing;

-- Basic Questions

-- Q1. Tell all Driver_names?

select distinct Driver_Name from f1_racing;

-- Result1:

| Driver_Name       |
|-------------------|
| "Max Verstappen"  |
| "Charles Leclerc" |
| "Lewis Hamilton"  |
| "Lando Norris"    |
| "Sergio Perez"    |


-- Q2.How many races did each driver complete without any penalties?

select  Driver_Name, count(*) as races_without_penalties 
from f1_racing where penalties = 0
group by Driver_Name;

-- Result2:


| Driver_Name,races_without_penalties |
|-------------------------------------|
| "Lando Norris",4                    |
| "Lewis Hamilton",3                  |
| "Max Verstappen",3                  |
| "Charles Leclerc",4                 |
| "Sergio Perez",2                    |


-- Q3. Which weather is associated with the most wins?

select Weather_Conditions, count(*) as wins
from f1_racing
where Position = 1 
group by Weather_Conditions
order by wins desc ;

-- Result3:

| Weather_Conditions,wins |
|-------------------------|
| Cloudy,3                |
| Overcast,2              |
| Sunny,1                 |

 
 -- Q4. what is the correlation between grid start position and final race position?
 
 select Grid_Start_Position, avg(Position) as Avg_final_position 
 from f1_racing
 group by Grid_Start_Position
 order by avg_final_position;
 
 -- Result4:

| Grid_Start_Position,Avg_final_position |
|----------------------------------------|
| 15,8.0000                              |
| 7,8.7143                               |
| 5,9.0000                               |
| 3,10.0000                              |
| 1,10.0000                              |
| 6,10.1250                              |
| 17,10.1250                             |
| 14,10.6364                             |
| 19,10.8000                             |
| 9,11.1429                              |
| 13,11.2500                             |
| 2,11.2500                              |
| 10,11.6667                             |
| 18,12.1429                             |
| 4,12.1667                              |
| 12,13.5000                             |
| 8,14.5714                              |
| 16,14.6667                             |
| 20,19.0000                             |


 -- Q5. Which driver has the lowest average lap time under rainy weather conditions?
 
 select Driver_Name, avg(Lap_Time_Avg) as avg_lap_time
 from f1_racing
 where weather_conditions = 'Rainy'
 group by Driver_Name
 order by avg_lap_time limit 1 ;
 
 
| Driver_Name,avg_lap_time           |
|------------------------------------|
| "Lewis Hamilton",95.16600000000001 |

 -- Advanced Queries
 
-- Q1A. Find the driver with the highest finishing position across all races where they finished in the top10.
-- The  drivers should have finished in top10 positions a minimum of 5 times.

select Driver_Name, avg(position) as avg_top10_position
 from f1_racing
 where position <= 10
 group by Driver_Name
 having count(*)  >=5
 order by avg_top10_position;
 
 -- Result1:
 
| Driver_Name,avg_top10_position |
|--------------------------------|
| "Lando Norris",3.5714          |
| "Charles Leclerc",4.5556       |
| "Max Verstappen",4.8333        |
| "Lewis Hamilton",6.3636        |

 
-- Q2A. Which drivers have finished in the top5 positions in more than 25% of the races they participated in?

With Driver_race_count as (
select driver_name, count(*) as total_races
 from f1_racing
 group by driver_name
 ),
 top5_finishes as (
 select driver_name, count(*) as top5_count
 from f1_racing
 where position<=5
 group by driver_name
 )
 select d.driver_name from driver_race_count d
 join top5_finishes t on 
 d.driver_name = t.driver_name
 where t.top5_count/ d.total_races >= 0.25;
 
 -- Result2A:
 
 | driver_name       |
|-------------------|
| "Max Verstappen"  |
| "Charles Leclerc" |
| "Lando Norris"    |


-- Q3A.Caluculate the driver's ranking per season based on their average position, 
-- and show only the top3 ranked drivers for each season.

with driver_average_position as (
select driver_name, season, avg(position) as avg_position
from f1_racing
group by driver_Name, Season
),
ranked_drivers as (
select driver_name, season, avg_position,
rank() over(partition by season order by avg_position) as `rank`
 from driver_average_position
 )
 select driver_name, season, avg_position,`rank`
 from ranked_drivers
 where 'rank' <= 3
 order by season, `rank`;
 
 -- Result3A:

| driver_name,season,avg_position,rank |
|--------------------------------------|
| "Sergio Perez",2020,6.5000,1         |
| "Lewis Hamilton",2020,8.4000,2       |
| "Max Verstappen",2020,8.8889,3       |
| "Charles Leclerc",2020,10.5000,4     |
| "Lando Norris",2020,14.3333,5        |
| "Charles Leclerc",2021,9.0000,1      |
| "Max Verstappen",2021,11.2500,2      |
| "Lewis Hamilton",2021,11.5000,3      |
| "Lando Norris",2021,16.2500,4        |
| "Sergio Perez",2021,17.5000,5        |
| "Lando Norris",2022,9.4444,1         |
| "Lewis Hamilton",2022,10.1111,2      |
| "Charles Leclerc",2022,12.2857,3     |
| "Max Verstappen",2022,12.5000,4      |
| "Sergio Perez",2022,15.0000,5        |
| "Max Verstappen",2023,9.7143,1       |
| "Charles Leclerc",2023,10.6667,2     |
| "Lando Norris",2023,11.0000,3        |
| "Lewis Hamilton",2023,13.5000,4      |
| "Sergio Perez",2023,13.6667,5        |

 
 -- Q4A.For each season, caluculate the average position per driver and rank them
 -- then show drivers who improved their rank compared to the previous season.
 
 with driver_season_average as (
select driver_name, season, avg(position) as avg_position
from f1_racing
group by driver_Name, Season
),
 
driver_ranked as (
select driver_name, season, avg_position,
rank() over(partition by season order by avg_position) as season_rank
 from driver_season_average
 ) 
 
 select current_season.driver_name, current_season.season, current_season.season_rank,
		prev_season.season_rank as previous_season_rank
 from driver_ranked current_season
 join driver_ranked prev_season
 on current_season.driver_name = prev_season.driver_name
 and current_season.season = prev_season.season+1
 where current_season.season_rank < prev_season.season_rank
 order by current_season.season;
 
--  Result4A:
 
| driver_name,season,season_rank,previous_season_rank |
|-----------------------------------------------------|
| "Max Verstappen",2021,2,3                           |
| "Charles Leclerc",2021,1,4                          |
| "Lando Norris",2021,4,5                             |
| "Lewis Hamilton",2022,2,3                           |
| "Lando Norris",2022,1,4                             |
| "Charles Leclerc",2023,2,3                          |
| "Max Verstappen",2023,1,4                           |

 
-- Q5A.Calculate the average points per driver per team and display only
-- drivers who have driven for more than one team

with driver_team_points as (
     select Driver_Name, Team, avg(Points) as avg_points
     from f1_racing
     group by Driver_Name, Team
     ),
     driver_team_count as (
     select driver_name, count(distinct team) as team_count
     from f1_racing
     group by Driver_Name
     )
     select d.driver_name, d.team,d.avg_points
     from driver_team_points d
     join driver_team_count t 
	 on d.driver_name = t.driver_name
     where t.team_count>1
     order by d.driver_name, d.team;
     
     -- Result5A:
     
     | driver_name | team | avg_points |
	 |-------------|------|------------|

     
     


 