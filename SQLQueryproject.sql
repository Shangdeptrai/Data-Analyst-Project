
select *
from data1

select * from data2


-- number of rows into our dataset

select count(*) from data1
select count(*) from data2

-- dataset for jharkhand and bihar

select * from data1 where state in ('Jharkhand' ,'Bihar')

-- population of India

select sum(population) as Population from data2

-- avg growth 

select state,avg(growth)*100 avg_growth from data1 group by state;

-- avg sex ratio

select state,round(avg(sex_ratio),0) avg_sex_ratio from data1 group by state order by avg_sex_ratio desc;

-- avg literacy rate
 
select state,round(avg(literacy),0) avg_literacy_ratio from data1 
group by state having round(avg(literacy),0)>90 order by avg_literacy_ratio desc ;

-- top 3 state showing highest growth ratio
select top 3 State,avg(growth)*100 avg_growth
from data1 
group by [State]
order by avg(growth)*100 desc

--bottom 3 state showing lowest sex ratio

select top 3 state,round(avg(sex_ratio),0) avg_sex_ratio from data1 group by state order by avg_sex_ratio asc;


-- top and bottom 3 states in literacy state
drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio from data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstate desc;

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--union opertor

select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;

-- states starting with letter a

select distinct state from data1 where lower(state) like 'a%' or lower(state) like 'b%'

select distinct state from data1 where lower(state) like 'a%' and lower(state) like '%m'


--total males and females
select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from data1 a inner join data2 b on a.district=b.district ) c) d
group by d.state;


-- total literacy rate
select sum(temp2.illiteracy)
from
(select temp.state,temp.district,(1-(temp.Literacy/100))*temp.population as 'illiteracy' 
from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,a.Literacy,b.population from data1 a inner join data2 b on a.district=b.district) temp) temp2

-------method2
select sum(sang.total_lliterate_pop)
from
(select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from data1 a 
inner join data2 b on a.district=b.district) d) c
group by c.state) sang


--output top 3 districts from each state with highest literacy rate
select top 3 *
from
(select *
from
(select [State],[District],[Literacy],RANK() over (partition by [State] order by [Literacy] desc) as 'rnk'
from data1) temp
where rnk=1) temp2
order by temp2.Literacy desc



select *
from
(select [State],[District],[Literacy],RANK() over (partition by [State] order by [Literacy] desc) as 'rnk'
from data1) sang
where sang.rnk in (1,2,3)

-- population in previous census

select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from data1 a inner join data2 b on a.district=b.district) d) e
group by e.state)m


-- population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from data1 a inner join data2 b on a.district=b.district) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from data2)z) r on q.keyy=r.keyy)g


--Find the top 3 states with the highest population density (population divided by area) among states with a literacy rate greater than 80% and 
--a sex ratio greater than 900. 
--Then, display the information on state, population, area, population density, literacy rate, and sex ratio.
select top 3 *
from
(
select *
from
	(select *, RANK() over (partition by sang2.State order by sang2.density Desc) as 'rnk'
from	(
select *, sang.Population/sang.Area_km2 as 'density'
from
(select a.State, a.Literacy,a.Sex_Ratio,b.Area_km2,b.Population
from data1 a inner join data2 b on a.District=b.District) sang
where sang.Literacy>80 and sang.Sex_Ratio>900   ) sang2 ) sang3
where sang3.rnk=1
) sang4
order by sang4.density desc

--method2

WITH RankedStates AS (
    SELECT 
        d.State, 
        d.Population,
        d.Area_km2,
        d.Population / d.Area_km2 AS PopulationDensity,
        d.Literacy,
        d.Sex_Ratio,
        RANK() OVER (ORDER BY d.Population / d.Area_km2 DESC) AS Rank
    FROM (
        SELECT 
            a.State, 
            b.Population,
            b.Area_km2,
            a.Literacy,
            a.Sex_Ratio
        FROM data1 a
        INNER JOIN data2 b ON a.District = b.District
        WHERE a.Literacy > 80 AND a.Sex_Ratio > 900
    ) d
)
SELECT 
    State, 
    Population, 
    Area_km2, 
    PopulationDensity, 
    Literacy, 
    Sex_Ratio
FROM RankedStates
WHERE Rank <= 3
ORDER BY PopulationDensity DESC;








