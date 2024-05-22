# Analysis of Indian Population Data using SQL

### Project Overview

Utilized SQL queries to extract, analyze, and visualize key demographic trends from a comprehensive dataset of Indian population data. Identified significant insights on population growth, age distribution, and regional disparities, highlighting potential areas of interest for social development initiatives.

### Data Sources

Data: The datasets used for this analysis are the "Dataset1" file and "Dataset2" file containing detailed information about Indian Population.

### Exploratory data analysis

Exploring the data to answer key questions, such as:

- population of India
- avg growth
- avg sex ratio
- avg literacy rate
- top 3 state showing highest growth ratio
- bottom 3 state showing lowest sex ratio
- top and bottom 3 states in literacy state
- states starting with letter a
- total males and females
- total literacy rate
- output top 3 districts from each state with highest literacy rate
- population in previous census
- population vs area
- Find the top 3 states with the highest population density (population divided by area) among states with a literacy rate greater than 80% and 
a sex ratio greater than 900. Then, display the information on state, population, area, population density, literacy rate, and sex ratio.

Include some interesting codes worked with:
```
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
```
### Results
Output the top 3 states with the highest population density (population divided by area) among states with a literacy rate greater than 80% and 
a sex ratio greater than 900. Then, display the information on state, population, area, population density, literacy rate, and sex ratio.




