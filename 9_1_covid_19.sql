/*
  covid(name, whn, confirmed, deaths, recovered)
*/

/*1.
The example uses a WHERE clause to show the cases in 'Italy' in March 2020.

Modify the query to show data from Spain*/
SELECT name, DAY(whn),
 confirmed, deaths, recovered
 FROM covid
WHERE name = 'Spain'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn;

/*Introducing the LAG function
Note for MySQL: If you are using the MariaDB engine you will 
hit the bug https://jira.mariadb.org/browse/MDEV-23866

You can use the Microsoft SQL Server engine instead
You can include this line before each query:
SET @@sql_mode='ANSI';

2.
The LAG function is used to show data from the preceding row or the table. 
When lining up rows the data is partitioned by country name and ordered by the data whn. 
That means that only data from Italy is considered.

Modify the query to show confirmed for the day before.*/
SET @@sql_mode='ANSI';
SELECT name, DAY(whn), confirmed,
   LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn)
 FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn;

/*3.
The number of confirmed case is cumulative - but we can use 
LAG to recover the number of new cases reported for each day.

Show the number of new cases for each day, for Italy, for March.*/
SET @@sql_mode='ANSI';
SELECT name, DAY(whn),
   confirmed - LAG(confirmed, 1) OVER (PARTITION BY name ORDER BY whn) as new
 FROM covid
WHERE name = 'Italy'
AND MONTH(whn) = 3 AND YEAR(whn) = 2020
ORDER BY whn;

/*4.
The data gathered are necessarily estimates and are inaccurate. However 
by taking a longer time span we can mitigate some of the effects.

You can filter the data to view only Monday's figures WHERE WEEKDAY(whn) = 0.

Show the number of new cases in Italy for each week in 2020 - show Monday only.*/
SET @@sql_mode='ANSI';
SELECT name, DATE_FORMAT(whn,'%Y-%m-%d'), confirmed - lag(confirmed, 1) over (partition by name order by whn) as 'new cases'
 FROM covid
WHERE name = 'Italy'
AND WEEKDAY(whn) = 0 AND YEAR(whn) = 2020
ORDER BY whn;

/*5.
You can JOIN a table using DATE arithmetic. This will give different results if data is missing.

Show the number of new cases in Italy for each week - show Monday only.

In the sample query we JOIN this week tw with last week lw using the DATE_ADD function.

*/
SET @@sql_mode='ANSI';
SELECT tw.name, DATE_FORMAT(tw.whn,'%Y-%m-%d'), 
tw.confirmed - lw.confirmed
FROM covid as tw 
LEFT JOIN covid as lw 
ON DATE_ADD(lw.whn, INTERVAL 1 WEEK) = tw.whn
   AND tw.name=lw.name
WHERE tw.name = 'Italy'
and weekday(tw.whn) = 0
ORDER BY tw.whn;

/*6.
The query shown shows the number of confirmed cases together with the world ranking for cases.

United States has the highest number, Spain is number 2...

Notice that while Spain has the second highest confirmed cases, Italy has the second
highest number of deaths due to the virus.

Include the ranking for the number of deaths in the table.*/
SET @@sql_mode='ANSI';
SELECT 
   name,
   confirmed,
   RANK() OVER (ORDER BY confirmed DESC) as rank_confirmed,
   deaths,
   RANK() OVER (ORDER BY deaths DESC) as rank_deaths
  FROM covid
WHERE whn = '2020-04-20'
ORDER BY confirmed DESC;

/*7.
The query shown includes a JOIN t the world table so we can access the total 
population of each country and calculate infection rates (in cases per 100,000).

Show the infect rate ranking for each country. Only include countries with a population 
of at least 10 million.*/
SET @@sql_mode='ANSI';
select world.name,
  ROUND(100000*confirmed/population,0) as inf_rate,
  rank() over (order by confirmed/population )
from covid 
join world 
on covid.name=world.name
where whn = '2020-04-20' 
and population > 10000000
order by population DESC;

/*8.
For each country that has had at last 1000 new cases in a single day, 
show the date of the peak number of new cases.

Note: this solution is apparently incorrect according to the site, but
the data seems correct*/
SET @@sql_mode='ANSI';

select name, date_format(whn, '%Y-%m-%d'), newbs
from(select name, whn, newbs, confirmed, 
     rank() over(partition by name order by newbs desc) as ranku
     from (select name, whn, confirmed,
           confirmed - lag(confirmed,1) over(partition by name order by whn) as newbs
           from covid) as stuff
     where newbs > 1000) as more
where ranku = 1
order by whn;