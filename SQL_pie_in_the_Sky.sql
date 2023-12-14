use ipl;
show tables;
select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select * from ipl_match;
select * from ipl_match_schedule;
select * from ipl_player;
select * from ipl_stadium;
select * from ipl_team;
select * from ipl_team_players;
select * from ipl_team_standings;
select * from ipl_tournament;
select * from ipl_user;

-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
#Tables Used:
select * from ipl_bidding_details;
select * from ipl_bidder_details;
select * from ipl_bidder_points;


SELECT bdg.bidder_id, bdr.BIDDER_NAME,
COUNT(CASE WHEN BID_STATUS = 'Won' THEN 1 END) / COUNT(bid_status) * 100 AS win_percentage
FROM ipl_bidding_details bdg inner join ipl_bidder_details bdr
on bdg.BIDDER_ID=bdr.BIDDER_ID
group BY bidder_id
order by win_percentage desc;


-- 2.	Display the number of matches conducted at each stadium with the stadium name and city.
#Tables Used:
select * from ipl_match_schedule;
select * from ipl_stadium;

select STADIUM_NAME as `Stadium Name`,CITY,count(*) as `No.of Matches`
from ipl_stadium stad inner join ipl_match_schedule sch
on stad.STADIUM_ID=sch.STADIUM_ID
group by STADIUM_NAME,CITY
order by count(*) desc ;

-- 3.	In a given stadium, what is the percentage of wins by a team which has won the toss?
#Tables Used:
select * from ipl_match;
select * from ipl_stadium;
select * from ipl_match_schedule;

select stad.stadium_id , stad.stadium_name ,
(select count(*) from ipl_match mat inner join ipl_match_schedule schd 
on mat.match_id = schd.match_id
where schd.stadium_id = stad.stadium_id and (toss_winner = match_winner)) /
(select count(*) from ipl_match_schedule schd where schd.stadium_id = stad.stadium_id) * 100 
as 'Toss and Match Wins %'
from ipl_stadium stad;

-- 4.	Show the total bids along with the bid team and team name
#Tables Used:
select * from ipl_bidding_details;
select * from ipl_team;

select bdg.BID_TEAM,tea.TEAM_NAME,count(*) as Total_Bids
from ipl_team tea inner join ipl_bidding_details bdg
on tea.TEAM_ID=bdg.BID_TEAM
group by bdg.BID_TEAM,tea.TEAM_NAME;  

-- 5.	Show the team id who won the match as per the win details.   
#Tables Used:
select * from ipl_match;
select * from ipl_team; 

select team_id,win_details
from ipl_team tea inner join ipl_match mat
on tea.team_id=mat.TEAM_ID1;

-- 6.	Display total matches played, total matches won and total matches lost by the team along with its team name.
#Tables Used:
select * from ipl_match;
select * from ipl_team;

select mat.TEAM_ID1,tea.TEAM_NAME,count(MATCH_ID) as `Matches Played`,
sum(case when tea.TEAM_ID=mat.MATCH_WINNER then 1
else 0 end) as `Matches Won`,
sum(case when tea.TEAM_ID<>mat.MATCH_WINNER then 1
else 0 end) as `Matches Lost`
from ipl_match mat inner join ipl_team tea
on mat.TEAM_ID1=tea.TEAM_ID
group by mat.TEAM_ID1;

-- 7.	Display the bowlers for the Mumbai Indians team.
#Tables Used:
select * from ipl_team_players;
select * from ipl_team;
select * from ipl_player;

select play.PLAYER_ID,player.PLAYER_NAME,play.PLAYER_ROLE,tea.TEAM_NAME
from ipl_team_players play inner join ipl_team tea
on play.TEAM_ID=tea.TEAM_ID
inner join ipl_player player on
play.PLAYER_ID=player.PLAYER_ID
where PLAYER_ROLE like '%Bowler%' and tea.REMARKS like '%MI%';

-- 8.	How many all-rounders are there in each team, Display the teams with more than 4  all-rounders in descending order.
#Tables Used:

select * from ipl_team_players;
select * from ipl_team;

select play.TEAM_id,TEAM_NAME,
count(*) as `No.of All-Rounders` 
from ipl_team_players play join ipl_team tea 
on play.TEAM_ID=tea.team_id
where PLAYER_ROLE='All-Rounder'
group by play.TEAM_id
having `No.of All-Rounders`>4
order by `No.of All-Rounders` desc;

/**9.Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. 
Chinnaswamy Stadium bidding year-wise.Note the total bidders’ points in descending order and the year is bidding year.
Display columns: bidding status, bid date as year, total bidder’s points**/

#Tables Used:
select * from ipl_bidder_points;
select * from ipl_bidding_details;
select * from ipl_match_schedule;
select * from ipl_match;
select * from ipl_team;
select * from ipl_stadium;

select bdg.BID_STATUS,year(bdg.BID_DATE) as Year,pts.TOTAL_POINTS
from ipl_bidding_details bdg inner join ipl_bidder_points pts
on bdg.BIDDER_ID=pts.BIDDER_ID
inner join ipl_match_schedule schd
on bdg.SCHEDULE_ID=schd.SCHEDULE_ID
inner join ipl_match mat
on schd.MATCH_ID=mat.MATCH_ID
inner join ipl_team tea
on mat.MATCH_WINNER=tea.TEAM_ID
inner join ipl_stadium stad
on schd.STADIUM_ID=stad.STADIUM_ID
where tea.REMARKS='CSK' and mat.TEAM_ID1=mat.MATCH_WINNER and stad.STADIUM_NAME like '%Chinnaswamy %';

/**10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
Note 
1. use the performance_dtls column from ipl_player to get the total number of wickets
 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
3.	Do not use joins in any cases.
4.	Display the following columns teamn_name, player_name, and player_role.**/
#Tables Used:
select * from ipl_player;
select * from ipl_team_players;
select * from ipl_team;

SELECT Team_name,Player_name,Player_role FROM 
(SELECT 
ipl_player.PLAYER_ID,
PLAYER_NAME, 
DENSE_RANK() OVER(ORDER BY CAST(TRIM(BOTH ' ' FROM substring_index(SUBSTRING_INDEX(PERFORMANCE_DTLS,'Dot',1),'Wkt-',-1))
AS SIGNED INT) DESC ) AS WICKET_RANK,
PLAYER_ROLE,
Team_name
FROM
	ipl_player,ipl_team_players,ipl_team
where 
	ipl_player.PLAYER_ID=ipl_team_players.PLAYER_ID  and ipl_team.TEAM_ID=ipl_team_players.TEAM_ID
and 
	PLAYER_ROLE in ('Bowler','All-Rounder'))T
where WICKET_RANK<=5; 


-- 11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage
#Tables Used:
select * from ipl_match;
select * from ipl_bidder_details;
select * from ipl_match_schedule;
select * from ipl_bidding_details;  
select * from ipl_bidder_points;

select bdr.BIDDER_ID, bdr.BIDDER_NAME,
count(if((mat.TEAM_ID1=bdg.BID_TEAM and mat.TOSS_WINNER=1) or
(mat.TEAM_ID2=bdg.BID_TEAM and mat.TOSS_WINNER=2),1,null))/count(*)*100 as Toss_Win_Percentage
from ipl_match mat inner join ipl_match_schedule schd
on mat.MATCH_ID=schd.MATCH_ID
inner join ipl_bidding_details bdg
on schd.SCHEDULE_ID =bdg.SCHEDULE_ID
inner join ipl_bidder_details bdr
on bdg.BIDDER_ID=bdr.BIDDER_ID
inner join ipl_bidder_points pts
on bdr.BIDDER_ID=pts.BIDDER_ID
group by bdr.BIDDER_ID,bdr.BIDDER_NAME
order by Toss_Win_Percentage desc;



/**12.	find the IPL season which has min duration and max duration.
Output columns should be like the below:
 Tournment_ID, Tourment_name, Duration column, Duration**/
 #Tables Used:
select * from ipl_tournament;

with ipl as (SELECT Tournmt_ID, Tournmt_name,
DATEDIFF(TO_DATE, FROM_DATE) AS Duration,
CASE
WHEN DATEDIFF(TO_DATE, FROM_DATE) = (SELECT MAX(DATEDIFF(TO_DATE, FROM_DATE) ) FROM IPL_Tournament) THEN 'Max_duration'
WHEN DATEDIFF(TO_DATE, FROM_DATE) = (SELECT MIN(DATEDIFF(TO_DATE, FROM_DATE) ) FROM IPL_Tournament) THEN 'Min_duration'
END AS Duration_Column
FROM IPL_Tournament)
SELECT * FROM ipl
WHERE
Duration_Column IS NOT NULL;

/**13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total 
points in descending order and month-wise in ascending order.
Note: Display the following columns:
1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
Only use joins for the above query queries.**/

select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_bidding_details;
desc ipl_bidding_details;

select distinct bdr.BIDDER_ID,bdr.BIDDER_NAME,year(bdg.BID_DATE) as Year,month(bdg.BID_DATE) as Month,pts.TOTAL_POINTS as Total_Points
from ipl_bidder_details bdr inner join ipl_bidder_points pts
on bdr.BIDDER_ID=pts.BIDDER_ID 
inner join ipl_bidding_details bdg
on pts.BIDDER_ID=bdg.BIDDER_ID
where year(bdg.BID_DATE)=2017
order by Total_Points desc,Month asc ;

-- *************************************************************************************************
/**14.	Write a query to display to calculate the total points month-wise for the 2017 bid year. sort the results based on total 
points in descending order and month-wise in ascending order.
Note: Display the following columns:
1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
Don't use joins for the above query queries.**/
select * from ipl_bidder_details;
select * from ipl_bidder_points;
select * from ipl_bidding_details;
desc ipl_bidding_details;

select bidder_id, (select bidder_name from ipl_bidder_details where ipl_bidder_details.bidder_id=ipl_bidding_details.bidder_id) as bidder_name,
year(bid_date) as `year`, monthname(bid_date) as `month`, 
(select total_points from ipl_bidder_points where ipl_bidder_points.bidder_id=ipl_bidding_details.bidder_id) as total_points from ipl_bidding_details
where year(bid_date)=2017
group by bidder_id,bidder_name,year,month,total_points
order by total_points desc;






-- **************************************************************************************************************

/*15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
Output columns should be:
like:
Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  -->
 columns contains name of bidder;**/

select * from ipl_bidder_points; 
select * from ipl_bidder_details;

select * from
(select pts.BIDDER_ID,pts.TOTAL_POINTS,
dense_rank() over(order by pts.TOTAL_POINTS desc) as Ranks,bdr.BIDDER_NAME,'Highest_3_Bidders' as 'Highest/Lowest_3_Bidders'
from  ipl_bidder_points pts inner join ipl_bidder_details bdr
on pts.BIDDER_ID=bdr.BIDDER_ID)temp
where Ranks<4
union all
(select * from
(select pts.BIDDER_ID,pts.TOTAL_POINTS,
rank() over(order by pts.TOTAL_POINTS ) as Ranks2,bdr.BIDDER_NAME,'Lowest_3_Bidders'
from  ipl_bidder_points pts inner join ipl_bidder_details bdr
on pts.BIDDER_ID=bdr.BIDDER_ID)temp2
where Ranks2<4);

/*16.	Create two tables called Student_details and Student_details_backup.

Table 1: Attributes 		Table 2: Attributes
Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

Feel free to add more columns the above one is just an example schema.
Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and modifying the details of the students in the Student details table. 
Every time the students changed their details like mobile number, You need to update their details in the student details table.  
Here is one thing you should ensure whenever the new students' details come , you should also store them in the Student backup table so that if you modify the details 
in the student details table, you will be having the old details safely.You need not insert the records separately into both tables rather 
Create a trigger in such a way that It should insert the details into the Student back table when you inserted the student details into the student table automatically.*/

create database trigger1;
use trigger1;
create table student_details (student_id int,
student_name varchar(30),
mail_id varchar(50),
mobile_no int);

create table student_details_backup (student_id int,
student_name varchar(30),
mail_id varchar(50),
mobile_no int);

delimiter //
create trigger insert_backup 
after insert on student_details 
for each row
begin 
insert into student_details_backup values (new.student_id,new.student_name,new.mail_id,new.mobile_no);
end//
delimiter ;

insert into student_details values (1,'Mahi',null,null);
insert into student_details values (2,'Virat','Virat@goat.com',7500);

set sql_safe_updates=0;
update student_details set mail_id='mahi@goat.com' where student_id =1;
select * from student_details;
select * from student_details_backup;