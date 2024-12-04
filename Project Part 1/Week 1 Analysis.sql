show tables;

select *
from data_dictionary;

select * 
from location
limit 5;

select * 
from visits
limit 5;

select * 
from water_source
limit 5;

select distinct type_of_water_source 
from water_source;

select *
from visits   
where time_in_queue > 500;

select *
from visits
join water_source
   on visits.source_id = water_source.source_id     
where time_in_queue > 500;

select *
from water_source
where source_id = 'AkRu05234224' or source_id = 'HaZa21742224';

select *
from water_quality
where subjective_quality_score = 10 and visit_count = 2;

select *
from well_pollution
limit 5;

select distinct description
from well_pollution;

select *
from well_pollution
where results = 'clean' and biological > 0.01;

select *
from well_pollution
where description like 'Clean_%';


update well_pollution -- Update well_pollution table 
SET description = 'Bacteria: E. coli'  -- Change description to'Bacteria: E. coli'
WHERE description = 'clean Bacteria: E. coli'  -- Where the description is `Clean Bacteria: E. coli`


update well_pollution -- Update well_pollution table 
SET description = 'Bacteria: E. coli'  -- Change description to'Bacteria: E. coli'
WHERE description = 'clean Bacteria: E. coli'  -- Where the description is `Clean Bacteria: E. coli`