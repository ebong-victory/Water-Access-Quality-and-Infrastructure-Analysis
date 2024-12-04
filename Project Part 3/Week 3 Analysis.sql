-- Week 3 Test Analysis

DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

select * from auditor_report;
select location_id, true_water_source_score
from auditor_report;

SELECT
auditor_report.location_id AS audit_location,
auditor_report.true_water_source_score,
visits.location_id AS visit_location,
visits.record_id
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id;

select * from water_quality;

SELECT -- Gives us the water sources with good scores
auditor_report.location_id AS location_id,
visits.record_id,
auditor_report.true_water_source_score as auditor_score,
 subjective_quality_score as surveyors_score
FROM
auditor_report
JOIN visits
ON auditor_report.location_id = visits.location_id
join water_quality
on visits.record_id = water_quality.record_id
where true_water_source_score = subjective_quality_score and visits.visit_count = 1;

SELECT -- Gives us the water sources with faulty scores
auditor_report.location_id AS location_id,
visits.record_id,
auditor_report.true_water_source_score as auditor_score,
 subjective_quality_score as surveyors_score
FROM
auditor_report
JOIN visits
ON auditor_report.location_id = visits.location_id
join water_quality
on visits.record_id = water_quality.record_id
where true_water_source_score != subjective_quality_score and visits.visit_count = 1;

select audit.location_id, audit.type_of_water_source as auditor_source,
water.type_of_water_source as surveyor_source,
visits.record_id, true_water_source_score as auditors_score,
 subjective_quality_score as surveyors_score
 from auditor_report as audit
 join visits
 on audit.location_id = visits.location_id
 join water_quality as water_q
 on visits.record_id = water_q.record_id
 join water_source as water
 on water.source_id = visits.source_id
 where true_water_source_score != subjective_quality_score and visits.visit_count = 1;
 
 with Incorrect_records as 
 (
 select audit.location_id, audit.type_of_water_source as auditor_source,
employee_name,
visits.record_id, true_water_source_score as auditors_score,
 subjective_quality_score as surveyors_score
 from auditor_report as audit
 join visits
 on audit.location_id = visits.location_id
 join water_quality as water_q
 on visits.record_id = water_q.record_id
 join employee
 on employee.assigned_employee_id = visits.assigned_employee_id
 where true_water_source_score != subjective_quality_score and visits.visit_count = 1
 ),
 
 error_count as (
 select distinct employee_name, count(employee_name) as number_of_mistakes
 from incorrect_records
 group by employee_name order by count(employee_name)
 ),
 
 avg_error_count_per_empl as 
 (
 select avg(number_of_mistakes)
 from error_count
 )
 
 SELECT
employee_name,
number_of_mistakes
FROM
error_count
 ;
 
create view Incorrect_records as 
 (
 select audit.location_id, audit.type_of_water_source as auditor_source,
employee_name,
visits.record_id, true_water_source_score as auditors_score,
 subjective_quality_score as surveyors_score
 from auditor_report as audit
 join visits
 on audit.location_id = visits.location_id
 join water_quality as water_q
 on visits.record_id = water_q.record_id
 join employee
 on employee.assigned_employee_id = visits.assigned_employee_id
 where true_water_source_score != subjective_quality_score and visits.visit_count = 1
 );
 
 select * from Incorrect_records;
 
 
 CREATE VIEW Incorrect_records AS 
SELECT
auditor_report.location_id,
visits.record_id,
employee.employee_name,
auditor_report.true_water_source_score AS auditor_score,
wq.subjective_quality_score AS surveyor_score,
auditor_report.statements AS statements
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN
water_quality AS wq
ON visits.record_id = wq.record_id
JOIN
employee
ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE
visits.visit_count =1
AND auditor_report.true_water_source_score != wq.subjective_quality_score;

 select * from Incorrect_records;
 
 WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
Incorrect_records
/*
Incorrect_records is a view that joins the audit report to the database
for records where the auditor and
employees scores are different*/

GROUP BY employee_name)
-- Query
with suspect_list AS (
SELECT employee_name, number_of_mistakes
FROM error_count
WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count));

select location_id, statements  from auditor_report
where statements like  'Suspicio%';

select assigned_employee_id from visits
where location_id = 'SoMa34137';

select employee_name
from employee
where assigned_employee_id = 5;

-- Fourth week test


select province_name, town_name,visit_count,
ln.location_id,type_of_water_source,number_of_people_served
from visits as vs
join location as ln
on vs.location_id = ln.location_id
join water_source as ws
on vs.source_id = ws.source_id
 WHERE vs.visit_count = 1; -- To avoid records which are additional info for thesame source.
 
select province_name, town_name,type_of_water_source,
location_type,number_of_people_served,time_in_queue,
results
from visits as vs
join location as ln
on vs.location_id = ln.location_id
join water_source as ws
on vs.source_id = ws.source_id
left join well_pollution as wp -- We use this so records which are not in well pollution will get a null value and not be excluded
on vs.source_id = wp.source_id
 WHERE vs.visit_count = 1; -- To avoid records which are additional info for thesame source.


CREATE VIEW combined_analysis_table AS
-- This view assembles data from different tables into one to simplify analysis
SELECT
water_source.type_of_water_source AS source_type,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served AS people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;





WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)

/*
SELECT -- Gives us the total number of people served per province
*
FROM
province_totals;

*/

SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,

ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,

ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,

ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,

ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well

FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;



WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,

ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,

ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,

ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,


ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN town_totals tt -- Since the town names are not unique, we have to join on a composite key
 ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.province_name, river desc;



CREATE TEMPORARY TABLE town_aggregated_water_access -- create a temporal table
WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,

ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,

ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,


ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well

FROM
combined_analysis_table ct
JOIN town_totals tt -- Since the town names are not unique, we have to join on a composite key
 ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;


WITH town_totals AS ( -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,

ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,

ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,

ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,


ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN town_totals tt -- Since the town names are not unique, we have to join on a composite key
 ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.province_name, river desc;

SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *
100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access
order by Pct_broken_taps desc;






CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same

source more than once in the future.

*/
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist,

and should refer to the source table. This ensures data integrity.

*/
Address VARCHAR(50), -- Street address
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50), -- What the engineers should do at that place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/
Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded.
Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);

CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Comments TEXT
);


select * from project_progress;

SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
);


/*
update project_progress as pp
set  pp.source_id = well_pollution.source_id,
Improvement = 'Install UV filter'
from well_pollution as wp
where wp.results = 'Contaminated: Biological';
select * from well_pollution;

update project_progress as pp
join well_pollution as wp
on pp.

UPDATE target_table AS t
JOIN source_table AS s
ON t.common_column = s.common_column
SET t.column1 = s.column1, 
    t.column2 = s.column2;


UPDATE target_table
SET target_table.column1 = source_table.column1,
    target_table.column2 = source_table.column2
FROM source_table
WHERE target_table.common_column = source_table.common_column;
*/

UPDATE target_table
SET column1 = CASE 
    WHEN condition1 THEN value1
    WHEN condition2 THEN value2
    ELSE default_value
END
WHERE condition_for_update;

ALTER TABLE well_pollution
ADD COLUMN improvement varchar(50);

select * from well_pollution;

update well_pollution
set improvement = 'Install UV filter'
where results = 'Contaminated: Biological';

update well_pollution
set improvement = 'Install RO filter'
where results = 'Contaminated: Chemical';


insert into project_progress (source_id, address, town, province, source_type)
SELECT
visits.source_id,
location.address,
location.town_name,
location.province_name,
water_source.type_of_water_source
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
);











SELECT
project_progress.Project_id, 
project_progress.Town, 
project_progress.Province, 
project_progress.Source_type, 
project_progress.Improvement,
Water_source.number_of_people_served,
RANK() OVER(PARTITION BY Province ORDER BY number_of_people_served)
FROM  project_progress 
JOIN water_source 
ON water_source.source_id = project_progress.source_id
WHERE Improvement = "Drill Well"
ORDER BY Province DESC, number_of_people_served;

select * from project_progress;
    
update project_progress as pp
join well_pollution as wp
on pp.source_id = wp.source_id
set pp.improvement = 'Install UV filter'
where results = 'Contaminated: Biological' and results = 'Contaminated
: Biological';


update project_progress as pp
join well_pollution as wp
on pp.source_id = wp.source_id
set pp.improvement = 'Install RO filter'
where results = 'Contaminated: Chemical';

update project_progress as pp
set pp.improvement = 'Drill well'
where source_type = 'river';


/*CASE
...
WHEN type_of_water_source = ... AND ... THEN CONCAT("Install ", FLOOR(...), " taps nearby")
ELSE NULL
end;  */

select source_id
from visits
where time_in_queue >= 30;

select * from project_progress;


UPDATE project_progress AS pp
JOIN visits AS vs ON pp.source_id = vs.source_id
SET pp.improvement = 
    CASE 
        WHEN pp.source_type = 'shared_tap' AND vs.time_in_queue >= 30 THEN 
            CONCAT('Install ', FLOOR(vs.time_in_queue / 30), ' taps nearby')
        ELSE NULL
    END;

update project_progress as pp
set pp.improvement = 'Diagnose local infrastructure'
where source_type = 'tap_in_home_broken';

select * from project_progress
where Improvement = null;

select * from project_progress
where Improvement = NULL;

select *
from well_pollution
where source_id = 'AkRu08936224';