create database if not exists order_process_database;
use order_process_database;

create table if not exists customer(
    custid integer not null,
    cname text not null,
    city text not null);

create table if not exists item(
    itemid integer not null,
    unitprice integer not null);

create table if not exists orderitem(
    orderid integer not null,
    itemid integer not null,
    qty integer not null);

create table if not exists orders(
    orderid integer not null,
    odate date not null,
    custid integer not null,
    orderamt integer not null);

create table if not exists warehouse(
    warehouseid integer not null,
    city text not null);

create table if not exists shipment(
    orderid integer not null,
    warehouseid integer not null,
    ship_date date not null);

alter table customer add constraint primary key(custid);
alter table item add constraint primary key(itemid);
alter table orders add constraint primary key(orderid);
alter table warehouse add constraint primary key(warehouseid);

alter table orderitem add constraint foreign key(orderid) references orders(orderid);
alter table orderitem add constraint foreign key(itemid) references item(itemid);
alter table orders add constraint foreign key(custid) references customer(custid);
alter table shipment add constraint foreign key(warehouseid) references warehouse(warehouseid);
alter table shipment add constraint foreign key(warehouseid) references orders(orderid);

--commit

insert into customer values
    (111,'Ashok', 'Mysuru'),
    (222,'Suresh', 'Bengaluru'),
    (333,'Anand', 'Mumbai'),
    (444,'Pinto', 'Dehli'),
    (555,'Sheetal',"bangalore");

insert into item values
    (1,400),
    (5,200),
    (2,1000),
    (3,100),
    (4,500);

insert into orders values
    (1,"20200114",111,2000),
    (2,"20210413",222,500),
    (3,"20191002",555,2500),
    (4,"20190512",333,1000),
    (5,"20201223",444,1200);

insert into orderitem values
    (1, 1, 5),
    (2, 5, 1),
    (3, 2, 5),
    (4, 3, 1),
    (5, 4, 12);

insert into warehouse values
    (2,'Mysuru'),
    (1,'Bengaluru'),
    (4,'Mumbai'),
    (3,'Dehli'),
    (5,'Chennai');

insert into shipment values
    (1, 2, 20200116),
    (2, 1, 20210414),
    (3, 4, 20191007),
    (4, 3, 20190516),
    (5, 5, 20201223);

--commit
select *from customer;
select *from item;
select *from orderitem;
select *from orders;
select *from warehouse;
select *from shipment;

--List the Order# and Ship_date for all orders shipped from Warehouse# "W2".
SELECT orderid,ship_date FROM shipment WHERE warehouseid = 2;

--List the Warehouse information from which the Customer named "Kumar" was supplied 
--his orders. Produce a listing of Order#, Warehouse#.
SELECT cname, orders.orderid, warehouse.warehouseid, warehouse.city FROM shipment
    INNER JOIN warehouse ON shipment.warehouseid = warehouse.warehouseid
    INNER JOIN orders ON orders.orderid = shipment.orderid
    INNER JOIN customer ON orders.custid = customer.custid
    WHERE cname = 'Ashok';

--Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the 
--total number of orders by the customer and the last column is the average order 
--amount for that customer. (Use aggregate functions)
SELECT cname, COUNT(orders.custid) AS 'number of orders', AVG(orderamt) AS 'average order amount' FROM customer
    INNER JOIN orders ON orders.custid = customer.custid
    GROUP BY orders.custid;

--Delete all orders for customer named "Kumar".
DELETE FROM Customer WHERE cname = 'Kumar';

--Find the item with the maximum unit price
SELECT CONCAT('Item with id-',itemid) AS 'Item with maximum unit price', unitprice FROM item
    WHERE unitprice = (SELECT MAX(unitprice) FROM item);

----Find the item with the maximum unit price
select itemid,unitprice from item 
where unitprice = (select max(unitprice) from item);

--Create a view to display orderID and shipment date of all orders shipped from a 
--warehouse 2.
create view shipped as
    select orderid,ship_date from shipment where warehouseid=2;

-- Trigger that prevents warehouse details from being deleted if any item has to be shipped from that warehouse
 DELIMITER $$
	CREATE TRIGGER PWDS
    BEFORE DELETE ON warehouse
        FOR EACH ROW
        BEGIN
    IF OLD.warehouseid IN (SELECT warehouseid FROM shipment NATURAL JOIN warehouse)
    THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'An item is shipped from this warehouse....!';
    END IF;
    END;
    $$

--A trigger that updates order_amount based on quantity and unit price of order_item .
delimiter $$
	CREATE TRIGGER update_order_amount
    AFTER UPDATE ON orderitem
    FOR EACH ROW
    BEGIN
    UPDATE order1 SET orderamt = orderamt + (NEW.qty * (SELECT untiprice FROM item WHERE itemid = NEW.itemid))
        WHERE orderid = NEW.orderid;
    end;
    $$
