/*                      world
name	       continent	area	   population	 gdp
Afghanistan	 Asia	      652230	 25500100	   20343000000
Albania	     Europe	    28748	   2831741	   12960000000
Algeria	     Africa	    2381741	 37100000	   188681000000
Andorra	     Europe	    468	     78115	     3712000000
Angola	     Africa	    1246700	 20609294	   100990000000
....
*/

/*1.
List each country name where the population is larger than that of 'Russia'.

world(name, continent, area, population, gdp)
*/
select name from world
where population > (select population from world where name = 'Russia');

/*2.
Show the countries in Europe with a per capita GDP greater than 'United Kingdom'.*/
select name from world 
where continent = 'Europe' and gdp/population >
  (select gdp/population from world where name = 'United Kingdom');

/*3.

List the name and continent of countries in 
the continents containing either Argentina or Australia. Order by name of the country.*/
select name, continent from world
where continent in 
  (select continent from world where name in ('Argentina', 'Australia'))
order by name;

/*4.
Which country has a population that is 
more than Canada but less than Poland? Show the name and the population.*/
select name, population from world
where population > 
  (select population from world where name = 'Canada')
and population < 
  (select population from world where name = 'Poland');

/*5.
Germany (population 80 million) has the largest population of the 
countries in Europe. Austria (population 8.5 million) has 11% of the population of Germany.

Show the name and the population of each country in Europe. 
how the population as a percentage of the population of Germany.

The format should be Name, Percentage for example:

name	    percentage
Albania	  3%
Andorra	  0%
Austria	  11%
...	      ...
*/
select name, 
concat(round(population / 
              (select population from world where name = 'Germany') * 100, 0),'%') as percentage
from world
where continent = 'Europe';

/*6.
Which countries have a GDP greater than every country in Europe? 
[Give the name only.] (Some countries may have NULL gdp values)*/
select name from world
where gdp > all(select gdp from world 
                where continent = 'Europe' and gdp is not null);

/*7.
Find the largest country (by area) in each continent, show the continent, the name and the area:*/
select continent, name, area from world as x
where area >= all(select area from world as y where x.continent = y.continent);
--The above example is known as a correlated or synchronized sub-query.

/*8.
List each continent and the name of the country that comes first alphabetically.*/
select continent, 
  (select name from world as y 
   where x.continent = y.continent limit 1) 
from world as x
group by continent

/*9.
Find the continents where all countries have a population <= 25000000. Then find the names of the 
countries associated with these continents. Show name, continent and population.*/
select name, continent, population from world as x
where 25000000 > all(select population from world as y where x.continent = y.continent) 

/*10.
Some countries have populations more than three times that of any of their neighbours 
(in the same continent). Give the countries and continents.*/
select name, continent from world as x
where population >= all(select population * 3 from world as y 
   where x.continent = y.continent and x.name != y.name);