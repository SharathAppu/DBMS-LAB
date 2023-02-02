create database if not exists sailors_database;
use sailors_database;

create table if not exists sailors(
    sid varchar(20) not null,
    sname text not null,
    rating integer not null,
    age integer not null);

create table if not exists boat(
    bid varchar(20) not null,
    bname text not null,
    color text not null);

create table if not exists rservers(
    sid varchar(20) not null,
    bid varchar(20) not null,
    sdate date not null);

alter table sailors add constraint primary key(sid);
alter table boat add constraint primary key(bid);
alter table rservers add constraint foreign key(sid) references sailors(sid);
alter table rservers add constraint foreign key(bid) references boat(bid);

--commit;

insert into sailors values
    (101,"Albert",4,20),
    (102,"Williams",6,25),
    (103,"John",8,30),
    (104,"Smith",9,45),
    (105,"Andrew",8,41);

insert into boat values
    (101,"Storm boat","Blue"),
    (102,"Willy","White"),
    (103,"Pilly","Black"),
    (104,"Hilly","Yellow"),
    (105,"Titanic","Red");
    (106,"Hurricane","Pink");

insert into rservers values
    (111,101,"2004-04-11"),
    (111,102,"2005-05-15"),
    (112,103,"2006-03-30"),
    (112,104,"2007-07-11"),
    (113,105,"2008-06-05");
    (113,106,"2009-11-17");
    (114,101,"2009-06-06"),
    (114,106,"2006-04-09"),
    (115,103,"2007-11-10"),
    (115,104,"2008-09-09");

--commit
select *from sailors;
select *from boat;
select *from rservers;

--Find the colours of boats reserved by Albert
select sailors.sid,sname,boat.bid,color from rservers
    inner join boat on boat.bid=rservers.bid
    inner join sailors on sailors.sid = rservers.sid
    where sailors.sname="Albert";

--Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103
select sid from sailors
    where rating>=8
or
sid in
    (select sid from rservers where bid=103);

--Find the names of sailors who have not reserved a boat whose name contains the string 
--“storm”. Order the names in ascending order.
SELECT sname FROM sailors 
WHERE sid NOT IN 
(SELECT sid FROM rservers 
INNER JOIN boat ON rservers.bid = boat.bid 
WHERE bname LIKE '%storm%') 
ORDER BY sname ASC;

--Find the names of sailors who have reserved all boats.
SELECT sname FROM sailors 
WHERE NOT EXISTS 
(SELECT * FROM boat WHERE bid NOT IN 
    (SELECT bid FROM rservers WHERE sid = sailors.sid));

--Find the name and age of the oldest sailor.
SELECT sname, age FROM sailors 
WHERE age = (SELECT MAX(age) FROM sailors);

--For each boat which was reserved by at least 5 sailors with age >= 40, find the boat id and 
--the average age of such sailors.
SELECT boat.bid, AVG(age) AS 'Averge age' FROM sailors
    INNER JOIN rservers ON rservers.sid = sailors.sid
    INNER JOIN boat ON rservers.bid = boat.bid
    WHERE age >= 40
    GROUP BY rservers.bid
    having count(*) = 5;

--A view that shows names and ratings of all sailors sorted by rating in descending order.
CREATE VIEW sailors_by_rating AS SELECT sname, rating FROM sailors ORDER BY rating DESC;

--A trigger that prevents boats from being deleted If they have active reservations.
DELIMITER //
CREATE TRIGGER prevent_boat_deletion
    BEFORE DELETE ON boat
    FOR EACH ROW
    BEGIN
    DECLARE num_reservations INT;
    SET num_reservations = (SELECT COUNT(*) FROM rservers WHERE bid = OLD.bid);
    IF num_reservations > 0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete boat with active reservations';
    END IF;
    END; //

    (0R)

DELIMITER //
CREATE TRIGGER prevent_boat_deletion
    BEFORE DELETE ON boat
    FOR EACH ROW
    BEGIN
    IF OLD.bid IN (SELECT bid FROM rservers NATURAL JOIN boat)
    THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'The boat details you want to delete has active reservations....!';
    END IF;
    END; //
