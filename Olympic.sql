DROP TABLE IF EXISTS OLYMPICS_HISTORY;
create table IF NOT EXISTS OLYMPICS_HISTORY(
id int,
name varchar,
sex varchar,
age varchar,
height varchar,
weight varchar,
team varchar,
noc varchar,
games varchar,
year int,
season varchar,
city varchar,
sport varchar,
event varchar,
medal varchar
);


create table OLYMPICS_HISTORY_NOC_REGIONS
(
noc varchar,
region varchar,
notes varchar
);

select * from OLYMPICS_HISTORY_NOC_REGIONS;
select * from OLYMPICS_HISTORY
----1.Write a SQL query to find the total no of Olympic Games held as per the dataset.
select count( distinct games) as total  
from OLYMPICS_HISTORY

----2.Write a SQL query to list down all the Olympic Games held so far.
select distinct year , season, city 
from OLYMPICS_HISTORY
order by year;

----3.Mention the total no of nations who participated in each olympics game?
select games, count(distinct noc) as total_countries
from OLYMPICS_HISTORY 
group by games

----4.Which year saw the highest and lowest no of countries participating in olympics

with tot_countries as 
(select games, count(distinct noc) as total_countries
from OLYMPICS_HISTORY 
group by games),
all_countries as
(
select games, n.region 
from OLYMPICS_HISTORY  as oh
join OLYMPICS_HISTORY_NOC_REGIONS as n
on oh.noc = n.noc
group by games, n.region
)

select distinct 
concat(first_value(games) over(order by total_countries) ,
'-',
first_value(total_countries) over(order by total_countries )) as lowest_countries, 

concat(first_value(games) over(order by total_countries desc) ,
'-',
first_value(total_countries) over(order by total_countries desc)) as highest_countries
from tot_countries 
order by 1;

---5. Which nation has participated in all of the olympic games
with cte1 as
(select count( distinct games) as total  
from OLYMPICS_HISTORY),
cte2 as (
select games, n.region as country
from OLYMPICS_HISTORY  as oh
join OLYMPICS_HISTORY_NOC_REGIONS as n
on oh.noc = n.noc
group by games, n.region 
),
cte3 as (
select country,count(1) as total_parctipated_countries
from cte2
group by country)

select c.*
from cte3 as c
join cte1 as c1
on c1.total = c.total_parctipated_countries
order by 1;

  
----6.Identify the sport which was played in all summer olympics.

with t1 as 
(select count(distinct games) as total
from OLYMPICS_HISTORY
where games like '%Summer%'),
t2 as (
select distinct sport, games
from OLYMPICS_HISTORY 
where games like '%Summer%'
order by games
),
t3 as (
select sport, count(games) as total_games
from t2
group by sport)

select * from t3 as t
join t1 as d
on t.total_games = d.total



------7.Which Sports were just played only once in the olympics.
select sport, count(games) as  no_of_games, games
from OLYMPICS_HISTORY
group by sport,games
having count(games) <= 1

-----8.Fetch the total no of sports played in each olympic games.

select games, count(distinct sport) as no_of_sports
from OLYMPICS_HISTORY
group by games
order by count(distinct sport) desc

-----9.SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.

select * from 
OLYMPICS_HISTORY
where medal = 'Gold'
order by year
limit 2

----10.Find the Ratio of male and female athletes participated in all olympic games.



------11.SQL query to fetch the top 5 athletes who have won the most gold medals.

with cte1 as (select name, count(medal) as no_of_gold from
OLYMPICS_HISTORY
where medal = 'Gold'
group by name
order by count(medal) desc),
cte2 as (
select * , dense_rank() over(order by no_of_gold desc) as rnk
from cte1)
select * from cte2
where rnk <= 5;

-----12.SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).


with cte1 as
(select name, team, count(1) as total_medal from
OLYMPICS_HISTORY
where medal in ('Gold', 'Silver', 'Bronze')
group by name,team
order by count(1) desc),
cte2 as (
select * , dense_rank() over (order by total_medal desc) as rnk from 
cte1
)
select * from cte2
where rnk <= 5

-----13.Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).


with cte1 as(
select n.region, count(1) as total_medals
from OLYMPICS_HISTORY as o
join OLYMPICS_HISTORY_NOC_REGIONS as n
on n.noc = o.noc
where medal <> 'NA'
group by n.region
order by count(1) desc),
cte2 as (
select *, dense_rank() over(order by total_medals desc) as rnk
from cte1
)
select * from cte2
where rnk <= 5 

----14. Write a SQL query to list down the  total gold, silver and bronze medals won by each country.

select n.region, count(1) as gold
from OLYMPICS_HISTORY as o
join OLYMPICS_HISTORY_NOC_REGIONS as n
on n.noc = o.noc
where medal = 'Gold'
group by n.region
order by count(1) desc),

-----15.Write SQL Query to return the sport which has won India the highest no of medals. 

with t1 as (select distinct sport, count(medal) as total_medal 
from OLYMPICS_HISTORY 
where medal <> 'NA' and team = 'India'
group by sport
order by count(medal) desc),
t2 as (
select * , rank() over (order by total_medal desc) as rnk
from t1
)
select * from t2
where rnk <= 1;
----16.Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 

select team , sport, games , count(medal) as total_medals
from  OLYMPICS_HISTORY
where medal <> 'NA' and team = 'India'
group by team, sport, games
order by count(medal) desc;



