/*                      world
  ge(yr, firstName, lastName, constituency, party, votes)
*/

/*1.
Show the lastName, party and votes for the constituency 'S14000024' in 2017.*/
select lastname, party, votes from ge
where constituency = 'S14000024'
and yr = 2017
order by votes desc;

/*2.
You can use the RANK function to see the order of the candidates. 
If you RANK using (ORDER BY votes DESC) then the candidate with the most votes has rank 1.

Show the party and RANK for constituency S14000024 in 2017. List the output by party*/
select party, votes,
       rank() over (order by votes desc) as posn
from ge
where constituency = 'S14000024' 
and yr = 2017
order by party;

/*3.
The 2015 election is a different PARTITION to the 2017 election. 
We only care about the order of votes for each year.

Use PARTITION to show the ranking of each party in S14000021 in each year. 
Include yr, party, votes and ranking (the party with the most votes is 1).*/
select yr,party, votes,
      rank() over (partition by yr order by votes desc) as posn
from ge
where constituency = 'S14000021'
order by party, yr;

/*4.
Edinburgh constituencies are numbered S14000021 to S14000026.

Use PARTITION BY constituency to show the ranking of each party in Edinburgh in 2017. 
Order your results so the winners are shown first, then ordered by constituency.*/
select constituency,party, votes, 
  rank() over (partition by constituency order by votes desc) as ranku
from ge
where constituency between 'S14000021' and 'S14000026'
and yr  = 2017
order by ranku, constituency,votes DESC;

/*5.
You can use SELECT within SELECT to pick out only the winners in Edinburgh.

Show the parties that won for each Edinburgh constituency in 2017.*/
select constituency, party
from
  (select constituency, party, rank() over (partition by constituency order by votes 
  desc) as ranku
  from ge
  where constituency between 'S14000021' and 'S14000026'
  and yr  = 2017
  order by ranku, constituency,votes DESC) as stuff
where ranku = 1;


/*6.
You can use COUNT and GROUP BY to see how each party did in Scotland. 
Scottish constituencies start with 'S'

Show how many seats for each party in Scotland in 2017.*/
select party, count(party)
from
  (select constituency, party, rank() over (partition by constituency order by votes 
  desc) as ranku
  from ge
  where constituency like 'S%'
  and yr  = 2017
  order by ranku, constituency,votes DESC) as stuff
where ranku = 1
group by party;