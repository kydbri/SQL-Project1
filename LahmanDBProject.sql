/*This project is an assignment form Berkeley's CS186.
Project 1: SQL, Working with the Lahman Baseball Statistics Database
Databse tables came from a GitHub repository, however, I cannot locate the user who posted it. 
*/

--Basics

--task 1.i: Find players who weigh more than 300 pounds.
SELECT namefirst, namelast, birthyear FROM  People 
WHERE weight > 300;

--task 1.ii: Find players whose first name contain a space.
SELECT namefirst, namelast, birthyear FROM people 
WHERE namefirst LIKE '% %'
ORDER BY namefirst, namelast ASC;

--task 1.iii: Group players with the same birthyear and average height per year.
SELECT birthyear, AVG(height) as averagehieght, COUNT(birthyear) as countperbirthyear
FROM PEOPLE
WHERE BIRTHYEAR IS NOT NULL AND playerID IS NOT NULL
GROUP BY birthyear 
ORDER BY birthyear ASC;

--task 1.iv: Follwing results of part 1.iii, only include groups with average hieght > 70.
SELECT birthyear, AVG(height) as averagehieght, COUNT(birthyear) as countperbirthyear
FROM PEOPLE
WHERE BIRTHYEAR IS NOT NULL AND playerID IS NOT NULL
GROUP BY birthyear 
HAVING AVG(height) > 70
ORDER BY birthyear ASC;


--Hall of Fame Schools

--task 2.i: Find players who were inducted into the Hall of Fame. 
SELECT people.namefirst, people.namelast, people.playerid, allstarfull.yearid FROM people
LEFT JOIN  allstarfull ON people.playerid = allstarfull.playerid
order by allstarfull.yearid desc, people.playerid asc;

--task 2.ii: Find players who were inducted and played in college at a school in California. 
--created a new table 
SELECT master.playerID, master.namefirst, master.namelast, schoolsplayers.schoolID, master.hofid
INTO TempTable
FROM master
LEFT JOIN schoolsplayers ON schoolsplayers.playerID = master.playerID;

SELECT temptable.playerid, temptable.namefirst, temptable.namelast, temptable.schoolid, halloffame.yearid
FROM temptable
LEFT JOIN HallOfFame ON TempTable.hofID = HallOfFame.hofID 
WHERE TempTable.schoolID = 'California'
ORDER BY HallOfFame.yearID DESC, temptable.schoolId ASC, temptable.playerID ASC; 

--task 2.iii: Find players who were inducted into the H.O.F. whether or not they played in college.
SELECT temptable.playerID, temptable.namefirst, temptable.namelast, temptable.schoolID FROM TempTable 
LEFT JOIN  HallOfFame ON tempTable.hofID = halloffame.hofID 
WHERE halloffame.inducted = 'Y'
ORDER BY temptable.playerID desc, temptable.schoolID asc;

--SaberMetrics

select * from batting
where playerID = 'spencsh01';
--task 3.i: Find the players with the 10 best annual slugging percentage recorded over all time. __________not accurate____________
SELECT TOP 10 master.playerID, master.namefirst, master.namelast, batting.yearID,
(
        (Batting.H - batting._2B - batting._3B - batting.HR) + 
        (2.0 * batting._2B) + 
        (3.0 * batting._3B) + 
        (4.0  * batting.HR)
    ) / NULLIF(batting.AB, 0) AS SLG FROM master 
LEFT JOIN Batting ON master.playerID = batting.playerID 
WHERE batting.AB > 50
ORDER BY SLG DESC, master.playerID ASC, batting.yearID ASC;

--task 3.ii: Find the players with the 10 best lifetime slugging percentage recorded over all time.
WITH BattingSums (playerID, totalH, totalAB, total_2B, total_3B, totalHR)
as
(
    SELECT playerID, SUM(H)AS totalH, SUM(AB) As totalAB, SUM(_2B) as total_2B, SUM(_3B) as total_3B, SUM(HR) AS totalHR
    FROM batting
    GROUP BY playerID
)
SELECT TOP 10 master.playerid, master.namefirst, master.namelast, 
(
    (BattingSums.totalH - BattingSums.total_2B - BattingSums.total_3B - BattingSums.totalHR) + 
    (2.0 * BattingSums.total_2B) +
    (3.0 * BattingSums.total_3B) + 
    (4.0 * BattingSums.totalHR) 
    ) / NULLIF(BattingSums.totalAB, 0) as LSLG
FROM master
LEFT JOIN BattingSums ON BattingSums.playerid = master.playerID
WHERE BattingSums.totalAB > 50
ORDER BY LSLG DESC, master.playerid ASC;

--Task 3.iii: Find the lifetime sluggin percentage of batters whose lslg is higher than Willie Mays.
With SPTable 
AS (
SELECT master.namefirst, master.namelast, master.playerID,
(
        SUM(Batting.H - batting._2B - batting._3B - batting.HR) + 
        SUM(2.0 * batting._2B) + 
        SUM(3.0 * batting._3B) + 
        SUM(4.0  * batting.HR)
    ) / NULLIF(SUM(batting.AB), 0) AS LSLG 
FROM master 
LEFT JOIN batting ON batting.playerID = master.playerID
GROUP BY master.playerID, master.namefirst, master.namelast
)
SELECT SPTable.nameFirst, SPTable.nameLast, SPTable.LSLG 
FROM SPTable
WHERE SPTABLE.playerID != 'mayswi01' AND LSLG > (
     SELECT 
        (
            SUM(batting.H - batting._2B - batting._3B - batting.HR) +
            SUM(2 * batting._2B) +
            SUM(3 * batting._3B) +
            SUM(4 * batting.HR)
        ) / NULLIF(SUM(batting.AB), 0)
    FROM batting
    WHERE batting.playerID = 'mayswi01'
)
ORDER BY LSLG DESC;

--Salaries

--task 4.i: Finding the min, max, and average for all player salaries for each year
SELECT yearID, MIN(salary) as minSalary, MAX(salary) as maxSalary, AVG(salary) as avgSalary FROM Salaries
GROUP BY yearid
ORDER BY yearid ASC;

--task 4.ii: Compute a histogram for salaries in 2012
WITH SalaryBins AS (
  SELECT
    FLOOR((salary - MIN(salary) OVER ()) / ((MAX(salary) OVER () - MIN(salary) OVER ()) / 9.0)) AS Bin,
    MIN(salary) OVER () + ((MAX(salary) OVER () - MIN(salary) OVER ()) / 9.0) * 
    FLOOR((salary - MIN(salary) OVER ()) / ((MAX(salary) OVER () - MIN(salary) OVER ()) / 9.0)) AS BinStart,
    MIN(salary) OVER () + ((MAX(salary) OVER () - MIN(salary) OVER ()) / 9.0) * 
    (1 + FLOOR((salary - MIN(salary) OVER ()) / ((MAX(salary) OVER () - MIN(salary) OVER ()) / 9.0))) AS BinEnd
  FROM Salaries
  WHERE Salaries.yearID = 2012
)
SELECT
  Bin,
  CONCAT('$', CAST(BinStart AS DECIMAL(10, 2)), ' - $', CAST(BinEnd AS DECIMAL(10, 2))) AS SalaryRange
FROM SalaryBins
GROUP BY Bin, BinStart, BinEnd
ORDER BY Bin;

--task 4.iii: Compute the year-over-year change in min, max, and average player salary.
With YearStats As 
(
    SELECT yearid, min(salary) as minSalary, max(salary) as maxSalary, avg(salary) as avgSalary
    FROM Salaries
    Group By yearid
)
SELECT YearStats.yearID, 
yearStats.minSalary - LAG(yearStats.minSalary, 1) OVER (ORDER BY yearID) AS mindiff,
yearStats.maxSalary - LAG(yearStats.maxSalary, 1) OVER (ORDER BY yearID) AS maxdiff,
yearStats.avgSalary - LAG(YearStats.avgSalary, 1) OVER (ORDER BY yearID) AS avgdiff
FROM YearStats
ORDER BY yearID asc;

--task 4.iv: Find the players that had the max salary in 2000 and 2001.
SELECT Salaries.playerid, People.namefirst, People.namelast, MAX(Salaries.salary) AS maxsalary, Salaries.yearID 
FROM Salaries
LEFT JOIN People ON Salaries.playerid = People.playerID
WHERE Salaries.salary > 6000000 AND (Salaries.yearID = 2000 OR Salaries.yearID = 2001)
GROUP BY Salaries.playerID, People.namefirst, People.namelast, Salaries.yearID
ORDER BY maxSalary asc, yearID asc;

--task 4.v: For each team in 2012, give the difference for each teams highest and lowest paid all-star player.
SELECT teamID, MAX(salary) - MIN(SALARY) AS diffAvg
FROM Salaries
WHERE yearID = 2012
GROUP BY teamID
ORDER BY teamID asc;