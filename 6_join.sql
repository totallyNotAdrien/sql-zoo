/*
 game(id, mdate, stadium, team1, team2)
 goal(matchid, teamid, player, gtime)
 eteam(id, teamname, coach)
*/

/*1.
The first example shows the goal scored by a player with the last name 'Bender'.
 The * says to list all the columns in the table - a shorter way of saying matchid, teamid, player, gtime.

Modify it to show the matchid and player name for all goals scored by Germany. 
To identify German players, check for: teamid = 'GER'*/
select matchid, player from goal
where teamid = 'GER';

/*2.
From the previous query you can see that Lars Bender's scored a goal in game 1012. 
Now we want to know what teams were playing in that match.

Notice in the that the column matchid in the goal table corresponds to the id column in the game table. 
We can look up information about game 1012 by finding that row in the game table.

Show id, stadium, team1, team2 for just game 1012*/
select id, stadium, team1, team2 from game
where id = 1012;

/*3.
You can combine the two steps into a single query with a JOIN.

SELECT *
  FROM game JOIN goal ON (id=matchid)
The FROM clause says to merge data from the goal table with that from the game table. 
The ON says how to figure out which rows in game go with which rows in goal - the 
matchid from goal must match id from game. (If we wanted to be more clear/specific we could say
ON (game.id=goal.matchid)

The code below shows the player (from the goal) and stadium name (from the game table) 
for every goal scored.

Modify it to show the player, teamid, stadium and mdate for every German goal.*/
select player, teamid, stadium, mdate from game
join goal
on goal.matchid = game.id and goal.teamid = 'GER';

/*4.
Use the same JOIN as in the previous question.

Show the team1, team2 and player for every goal scored by a 
player called Mario player LIKE 'Mario%'*/
select team1, team2, goal.player from game
join goal
on game.id = goal.matchid and goal.player like 'Mario%';

/*5.
The table eteam gives details of every national team including the coach. 
You can JOIN goal to eteam using the phrase goal JOIN eteam on teamid=id

Show player, teamid, coach, gtime for all goals scored in the first 10 minutes gtime<=10*/
select player, teamid, eteam.coach, gtime from goal
join eteam
on goal.teamid = eteam.id
where gtime <= 10;

/*6.
To JOIN game with eteam you could use either
game JOIN eteam ON (team1=eteam.id) or game JOIN eteam ON (team2=eteam.id)

Notice that because id is a column name in both game and eteam you must specify 
eteam.id instead of just id

List the dates of the matches and the name of the team in which 'Fernando Santos' was the team1 coach.*/
select mdate, eteam.teamname from game
join eteam
on game.team1 = eteam.id
where eteam.coach = 'Fernando Santos';

/*7.
List the player for every goal scored in a game where the stadium was 'National Stadium, Warsaw'*/
select player from goal
join game
on goal.matchid = game.id
where game.stadium = 'National Stadium, Warsaw';

/*8.
The example query shows all goals scored in the Germany-Greece quarterfinal.
Instead show the name of all players who scored a goal against Germany.*/
select distinct player from goal
join game
on goal.matchid = game.id
where goal.teamid != 'GER' and 'GER' in (game.team1, game.team2);

/*9.
Show teamname and the total number of goals scored.*/
select eteam.teamname, count(*) from eteam
join goal
on eteam.id = goal.teamid
group by eteam.teamname;

/*10.
Show the stadium and the number of goals scored in each stadium.*/
select stadium, count(*) from game
join goal
on goal.matchid = game.id
where goal.teamid in (game.team1, game.team2)
group by stadium;

/*11.
For every match involving 'POL', show the matchid, date and the number of goals scored.*/
select id, mdate, count(goal.matchid) from game 
join goal
on goal.matchid = game.id
where 'POL' in (game.team1, game.team2)
group by id, mdate;

/*12.
For every match where 'GER' scored, show matchid, match date and the number of goals scored by 'GER'*/
select matchid, game.mdate, count(matchid) from goal
join game
on goal.matchid = game.id
where goal.teamid = 'GER'
group by matchid, game.mdate;

/*13.
List every match with the goals scored by each team as shown. 
This will use "CASE WHEN" which has not been explained in any previous exercises.
mdate	        team1	 score1	 team2	 score2
1 July 2012	  ESP	   4	     ITA	   0
10 June 2012	ESP	   1	     ITA	   1
10 June 2012	IRL	   1	     CRO	   3
...
Notice in the query given every goal is listed. 
If it was a team1 goal then a 1 appears in score1, otherwise there is a 0. 
You could SUM this column to get a count of the goals scored by team1. 
Sort your result by mdate, matchid, team1 and team2.*/
SELECT mdate,
  team1,
  sum(CASE WHEN goal.teamid = team1 THEN 1 ELSE 0 END) as score1,
  team2,
  sum(CASE WHEN goal.teamid = team2 THEN 1 ELSE 0 END) as score2
FROM game 
JOIN goal 
ON goal.matchid = game.id
group by mdate, team1, team2
order by mdate, goal.matchid, team1, team2;