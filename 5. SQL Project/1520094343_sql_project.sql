/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name
FROM `Facilities`
WHERE membercost > 0



/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(name)
FROM `Facilities`
WHERE membercost = 0



/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM `Facilities`
WHERE membercost > 0
      AND membercost < (monthlymaintenance * 0.2)



/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM `Facilities`
WHERE facid IN (1, 5)



/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

--I felt the question was ambiguous as to whether return all facilities
--and label them as cheap or expensive, or just return the expensive ones.
--Below are two queries, the first returns all the facilities, the second only
--the expensive ones.

--Query 1
SELECT name,
       monthlymaintenance,
       CASE WHEN monthlymaintenance > 100 THEN 'expensive'
       ELSE 'cheap' END AS cheap_or_expensive
FROM `Facilities`

--Query 2
SELECT name,
       monthlymaintenance,
       CASE WHEN monthlymaintenance > 100 THEN 'expensive'
       ELSE 'cheap' END AS cheap_or_expensive
FROM `Facilities`
WHERE monthlymaintenance > 100



/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT *
FROM `Members`
WHERE joindate = (SELECT MAX(joindate) FROM `Members`)



/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

-- To make sure there weren't duplicate entries, I joined the two tables on facid,
-- whose entries are all unique, letting me know that no bookings are duplicates.
-- member_name that appears as GUEST GUEST (memid = 0) is a guest, as explained in question 8.

SELECT facilities.name AS court_name,
       CONCAT(members.firstname, " ", members.surname) AS member_name
FROM `Bookings` AS bookings
JOIN `Facilities` AS facilities
ON bookings.facid = facilities.facid
JOIN `Members`AS members
ON bookings.memid = members.memid
WHERE bookings.facid IN (0,1)
ORDER BY member_name




/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT facilities.name AS facility_name,
       CONCAT(members.firstname, " ", members.surname) AS member_name,
       CASE WHEN bookings.memid = '0' THEN facilities.guestcost*bookings.slots
            ELSE facilities.membercost*bookings.slots END AS total_booking_cost
FROM `Bookings` AS bookings
JOIN `Facilities` AS facilities
ON bookings.facid = facilities.facid
JOIN `Members` AS members
ON bookings.memid = members.memid
WHERE bookings.starttime LIKE '2012-09-14%'
AND (CASE WHEN bookings.memid = '0' THEN facilities.guestcost*bookings.slots
         ELSE facilities.membercost*bookings.slots END) > 30
ORDER BY (CASE WHEN bookings.memid = '0' THEN facilities.guestcost*bookings.slots
         ELSE facilities.membercost*bookings.slots END) DESC



/* Q9: This time, produce the same result as in Q8, but using a subquery. */
-- Subquery on line 159. This was much slower than the code in question 8

SELECT facilities.name AS facility_name,
       CONCAT(members.firstname, " ", members.surname) AS member_name,
       CASE WHEN bookings.memid = '0' THEN facilities.guestcost*bookings.slots
            ELSE facilities.membercost*bookings.slots END AS total_booking_cost
FROM `Bookings` AS bookings
JOIN `Facilities` AS facilities
ON bookings.facid = facilities.facid
JOIN `Members` AS members
ON bookings.memid = members.memid
WHERE bookings.starttime IN ( SELECT starttime FROM `Bookings` WHERE starttime LIKE '2012-09-14%')
AND (CASE WHEN bookings.memid = '0' THEN facilities.guestcost*bookings.slots
         ELSE facilities.membercost*bookings.slots END) > 30
ORDER BY (CASE WHEN bookings.memid = '0' THEN facilities.guestcost*bookings.slots
         ELSE facilities.membercost*bookings.slots END) DESC




/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT facilities.name AS facility_name,
       SUM(CASE WHEN bookings.memid = '0' THEN facilities.guestcost*bookings.slots
            ELSE facilities.membercost*bookings.slots END) AS total_booking_revenue
FROM `Bookings` AS bookings
JOIN `Facilities` AS facilities
ON bookings.facid = facilities.facid
GROUP BY facilities.name
HAVING SUM(CASE WHEN bookings.memid = '0' THEN facilities.guestcost*bookings.slots
            ELSE facilities.membercost*bookings.slots END) < 1000
ORDER BY SUM(CASE WHEN bookings.memid = '0' THEN facilities.guestcost*bookings.slots
            ELSE facilities.membercost*bookings.slots END)