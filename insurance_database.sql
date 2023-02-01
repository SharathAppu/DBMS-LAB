create database if not exists insurance_database;
use insurance_database;

create table if not exists person(
    driverid varchar(20) not null,
	name text not null,
	address text not null);

create table if not exists car(
	regno varchar(20) not null,
    model text not null,
    year integer not null);

create table if not exists accident(
    report_num integer not null,
    acc_date date not null,
    location text not null);

create table if not exists owns(
    driverid varchar(20) not null,
    regno varchar(20) not null);

create table if not exists participated(
    driverid varchar(20) not null,
    regno varchar(20) not null,
    report_num integer not null,
    damage_amt integer not null);

alter table person add constraint primary key(driverid);
alter table car add constraint primary key(regno);
alter table accident add constraint primary key(report_num);

alter table owns add constraint foreign key(driverid) references person(driverid);
alter table participated add constraint foreign key(regno) references car(regno);
alter table participated add constraint foreign key(driverid) references person(driverid);
alter table participated add constraint foreign key(report_num) references accident(report_num);

--commit
SELECT * FROM person;
SELECT * FROM car;
SELECT * FROM accident;
SELECT * FROM owns;
SELECT * FROM participated;

--Find the total number of people who owned cars that were involved in accidents in 2021.
SELECT YEAR(acc_date), COUNT(*) AS 'Number of Accidents' FROM accident
    INNER JOIN participated ON accident.report_num = participated.report_num
    WHERE YEAR(acc_date) = 2021
    GROUP BY YEAR(acc_date);

--Find the number of accidents in which the cars belonging to “Smith” were involved. 
SELECT name, COUNT(*) AS 'Number of Accidents' FROM person
    INNER JOIN participated ON participated.driverid = person.driverid
    WHERE person.name = 'Smith'
    GROUP BY participated.driverid;

--Add a new accident to the database; assume any values for required attributes. 

--Delete the Mazda belonging to “Smith”.
DELETE FROM owns
    WHERE driverid = (SELECT driverid FROM person WHERE name = 'Smith')
    AND regno = (SELECT regno FROM Car WHERE model = 'Mazda');

--Update the damage amount for the car with license number “KA09MA1234” in the accident 
--with report.

--A view that shows models and year of cars that are involved in accident.
CREATE VIEW CMY 
AS
SELECT model, year FROM car
INNER JOIN participated ON car.regno = participated.regno
GROUP BY model, year;

--A trigger that prevents driver with total damage amount >rs.50,000 from owning a car.
DELIMITER $$
	CREATE TRIGGER PDOC
    BEFORE INSERT ON owns
    FOR EACH ROW
    BEGIN
    IF NEW.driverid IN (SELECT did FROM participated WHERE damage_amt > 50000)
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Person cannot own a car....!';
    END IF;
    END;
	$$