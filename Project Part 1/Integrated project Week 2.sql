show tables;
select *
from employee;
select
replace (employee_name, ' ' , '.') -- replace the space with a full stop
from employee;

select
lower(replace(employee_name, ' ', '.')) -- Make it all lower case
from employee;

select
concat(
lower(replace(employee_name, ' ', '.')), 'ndogowater.gov') AS new_email -- add it all together
from employee;

UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),
'@ndogowater.gov');

select *
from employee;

select 
length(phone_number)
from employee;

select
trim(phone_number)
from employee;

update employee
set phone_number = trim(phone_number);

select town_name, count(employee_name) -- group data by the town name and number of employees per town
from employee
group by town_name;

select assigned_employee_id, count(visit_count) -- Top 3 employees who visited the most sites
from visits
group by assigned_employee_id order by count(visit_count) desc
limit 3;

select employee_name, email, phone_number
from employee
where assigned_employee_id = 1 or assigned_employee_id = 30 or assigned_employee_id = 34;

select town_name, count(town_name) -- number of water supply per town
from location
group by town_name
order by town_name;

select province_name, count(province_name) -- number of water supply per town
from location
group by province_name;

select province_name, town_name, count(town_name)-- water supply per province and town, sorted by province name and number of records
from location
group by province_name, town_name
order by province_name, count(town_name) desc;



select location_type, province_name, town_name, count(town_name)-- water supply per location type, province and town
from location
group by location_type, province_name, town_name
order by location_type;

select location_type, count(location_type)
from location
group by location_type;

SELECT 23740 / (15910 + 23740) * 100;
select 15910 / (15910 + 23740) * 100;


-- Diving into the solution
select *
from water_source
order by source_id;


select type_of_water_source, count(number_of_people_served)
from water_source
group by type_of_water_source;

select sum(number_of_people_served)
from water_source;

select type_of_water_source, count(type_of_water_source), sum(number_of_people_served), round(avg(number_of_people_served))
from water_source
group by type_of_water_source
order by sum(number_of_people_served);

select type_of_water_source, sum(number_of_people_served)
from water_source
group by type_of_water_source
order by sum(number_of_people_served) desc;

select sum(number_of_people_served) -- Population sampled/surveyed
from water_source;

select type_of_water_source, round((sum(number_of_people_served) /  27628140)*100)-- Percentage share of each source of water
from water_source
group by type_of_water_source
order by sum(number_of_people_served) desc;

select type_of_water_source, sum(number_of_people_served) as people_served,
rank() over(order by sum(number_of_people_served)) as rank_by_population
from water_source
group by type_of_water_source;


select source_id, type_of_water_source, number_of_people_served as people_served, sum(number_of_people_served)
over(partition by type_of_water_source order by source_id) as rolling_total -- rolling sum
from water_source;

select source_id, type_of_water_source, sum(number_of_people_served)
over(partition by type_of_water_source order by source_id) as ranking
from water_source;

select type_of_water_source, sum(number_of_people_served) as people_served, 
round((sum(number_of_people_served) /  27628140)*100) as percentage_ranking, -- window function for ranking water sources
rank() over(order by sum(number_of_people_served) desc) as ranking
from water_source
group by type_of_water_source;


select source_id, type_of_water_source, number_of_people_served,
rank() over(partition by type_of_water_source order by number_of_people_served desc) as priority_rank,
dense_rank() over(partition by type_of_water_source order by number_of_people_served desc) as dense_priority_rank,
row_number() over(partition by type_of_water_source order by number_of_people_served desc) as row_priority_rank
from water_source
where type_of_water_source = 'river' or type_of_water_source = 'shared_tap'; 

select min(number_of_people_served)  -- checking for min number of people served by the river
from water_source
where type_of_water_source = 'river';

 -- Analysing queues
 
 select *
 from visits;
 
 select visits.location_id, location.province_name, location.town_name, visits.source_id, 
 sources.type_of_water_source, visits.time_in_queue,   -- linking the visits data to their respective location and
 visits.assigned_employee_id, visit_count              -- water source.
 from visits
 join water_source as sources
      on visits.source_id = sources.source_id
join location
     on visits.location_id = location.location_id;
     
     
     
 select visits.location_id, location.province_name, location.town_name, visits.source_id, 
 sources.type_of_water_source, visits.time_in_queue,   -- linking the visits data to their respective location and
 visits.assigned_employee_id, visit_count, avg(time_in_queue)
 over()
 from visits
 join water_source as sources
      on visits.source_id = sources.source_id
join location
     on visits.location_id = location.location_id;
     
     
 select visits.source_id, sources.type_of_water_source,  
 visits.assigned_employee_id, visit_count, visits.time_in_queue, avg(time_in_queue) as avg_time_in_queue,
 rank() over(order by avg(time_in_queue)) as rank_of_time_queue
 from visits
 join water_source as sources
      on visits.source_id = sources.source_id
join location
     on visits.location_id = location.location_id
     group by sources.type_of_water_source, visits.assigned_employee_id, visit_count, visits.time_in_queue, visits.source_id;
     
select sources.type_of_water_source, avg(time_in_queue) as avg_time_in_queue, avg(visit_count) as avg_number_of_visits
 from visits
 join water_source as sources
      on visits.source_id = sources.source_id
      group by sources.type_of_water_source
      having avg(time_in_queue) != 0
      order by avg(time_in_queue);
      
      select assigned_employee_id, avg(visit_count), avg(time_in_queue) --  avg visit count and time in queue per employee
      from visits
      group by assigned_employee_id
      order by avg(time_in_queue) desc;
      
      select min(time_of_record) as youngest_date, max(time_of_record) as date_of_oldest_record, avg(time_in_queue)
      from visits;
      
      select max(time_of_record) - min(time_of_record)
      from visits;
      
      
      select -- datetime functions unique to MySQL
      current_date() as currenttime,
      now() as timestamp_now,
      current_timestamp() as time_now;
      
      
      select location_id, visit_count, time_in_queue, time_of_record, avg(time_in_queue)
      over(partition by location_id order by time_in_queue) as avg_time_queue,
      datediff(month, time_of_record, 2024-10-02)
      from visits
      where visit_count >= 2;
      
      select source_id, time_in_queue, time_of_record,
      datediff(now(), time_of_record) as time_diff
      from visits
      limit 5;
      
      select min(time_of_record) as min_record, max(time_of_record) as max_record,
      datediff(now(), min(time_of_record)) as now_min,
      datediff(now(), max(time_of_Record)) as now_max,
      datediff(max(time_of_record), min(time_of_Record)) as survey_length
      from visits;
      
      
      select time_of_record,  -- date time addition function
      date_add(time_of_record, interval 7 day),
      date_add(time_of_record, interval 7 month),
      date_add(time_of_record, interval 7 year)
      from visits
      limit 5;
      
      select max(time_of_Record),
      DATEDIFF(day, now(), max(time_of_record))  -- wrong way to do it
      from visits;
      
      select max(time_of_record), min(time_of_record),
      datediff(max(time_of_record), min(time_of_record)) as length_of_survey
      from visits;
      
      select avg(time_in_queue)
      from visits;
      
      select avg(time_in_queue) -- avg queue time excluding the no queue sources
      from visits
      where nullif(time_in_queue, 0) != 'null';
      
      select convert(avg(time_in_queue), decimal(6,2)) -- converting the avg value to a decimal value with 2dp
      from visits
      where nullif(time_in_queue, 0) != 'null';
	
    
    select dayname(time_of_record) as day_of_week, round(avg(time_in_queue)) as avg_time_in_queue -- aggregate avg time in queus by the week days
    from visits
    where nullif(time_in_queue, 0) != 'null'
    group by dayname(time_of_record);
    
    select time_of_record from visits;
    
    select hour(time_of_record), round(avg(time_in_queue)) as avg_time_in_queue
    from visits
    where dayname(time_in_queue) = 'Saturday' and nullif(time_in_queue, 0) != 'null'
    group by hour(time_of_record) order by hour(time_of_record);
    
    select dayname(time_of_record), hour(time_of_record) as hour_of_the_day, round(avg(time_in_queue)) as avg_time_queue
    from visits
    where dayname(time_of_record) = 'saturday' and time_in_queue > 0
    group by hour(time_of_record), dayname(time_of_record) order by hour(time_of_record);
    
    -- my avg time does not matc that from the text
    select dayname(time_of_record), hour(time_of_record), time_in_queue, visit_count
    from visits
    where dayname(time_of_record) = 'saturday' order by hour(time_of_record);
    
    -- continuation
    
	select dayname(time_of_record), time_format(time(time_of_record), '%H:00') as hour_of_the_day, round(avg(time_in_queue)) as avg_time_queue
    from visits
    where dayname(time_of_record) = 'saturday' and time_in_queue > 0
    group by time_format(time(time_of_record), '%H:00'), dayname(time_of_record) order by time_format(time(time_of_record), '%H:00');
    
    SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
round((time_in_queue / 3), 3) as try, -- testing the round function

CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
visits
WHERE
time_in_queue != 0; -- this exludes other sources with 0 queue times


select time_format(time(time_of_record), '%H:00') AS HOUR_OF_DAY,
-- Sunday's records
ROUND( -- Separates column into column where dayname is sunday. everything else is null
avg(
case when dayname(time_of_record) = 'Sunday' then time_in_queue
else null 
end
)
,0) as Sunday,

ROUND( -- Separates column into column where dayname is sunday. everything else is null
avg(
case when dayname(time_of_record) = 'Monday' then time_in_queue
else null 
end
)
,0) as Monday,


ROUND( -- Separates column into column where dayname is sunday. everything else is null
avg(
case when dayname(time_of_record) = 'Tuesday' then time_in_queue
else null 
end
)
,0) as Tuesday,

ROUND( -- Separates column into column where dayname is Wednesday. everything else is null
avg(
case when dayname(time_of_record) = 'Wednesday' then time_in_queue
else null 
end
)
,0) as Wednesday,

ROUND( -- Separates column into column where dayname is sunday. everything else is null
avg(
case when dayname(time_of_record) = 'thursday' then time_in_queue
else null 
end
)
,0) as Thursday,

ROUND( -- Separates column into column where dayname is sunday. everything else is null
avg(
case when dayname(time_of_record) = 'Friday' then time_in_queue
else null 
end
)
,0) as Friday,

ROUND( -- Separates column into column where dayname is sunday. everything else is null
avg(
case when dayname(time_of_record) = 'Saturday' then time_in_queue
else null 
end
)
,0) as Saturday
from visits
group by HOUR_OF_DAY order by hour_of_day;


SELECT sum(number_of_people_served) FROM water_source
WHERE type_of_water_source = 'tap_in_home_broken';


-- Querying data test 2
SELECT
name, wat_bas_r, year,
LAG(wat_bas_r) OVER (PARTITION BY name ORDER BY year),
wat_bas_r - LAG(wat_bas_r) OVER (PARTITION BY name ORDER BY year)
FROM 
global_water_access
ORDER BY
name;

select assigned_employee_id,
sum(visit_count) over(partition by assigned_employee_id)
from visits
group by assigned_employee_id;

select * from employee where town_name = 'kilmani' or town_name = 'harare';

select round(avg(number_of_people_served), 0) from water_source where type_of_water_source = 'well';

SELECT
SUM(number_of_people_served) AS population_served
FROM
water_source WHERE type_of_water_source LIKE "tap%"
ORDER BY
population_served;


select * from water_source where type_of_water_source like '%tap';

