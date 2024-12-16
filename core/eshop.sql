-- TABLES

create table if not exists catalog (
    id int primary key auto_increment,
    title text not null,
    author text not null,
    price int not null,
    pubyear int not null
);

create table if not exists orders (
    id int primary key auto_increment,
    order_id varchar(20) unique not null,
    customer text not null,
    email text not null,
    phone text not null,
    address text not null,
    created timestamp default current_timestamp
);

create table if not exists admins (
    id int primary key auto_increment,
    login varchar(36) unique not null,
    password text not null,
    email text not null,
    created timestamp default current_timestamp
);

create table if not exists ordered_items (
    id int primary key auto_increment,
    quantity int not null,
    order_id varchar(20) not null references orders (order_id),
    item_id int not null references catalog (id)
);

-- PROCEDURES

create procedure if not exists spAddItemToCatalog(
    title text,
    author text,
    price int,
    pubyear int
)
begin
    insert into catalog(title, author, price, pubyear) values (title, author, price, pubyear);
end;

create procedure if not exists spGetCatalog()
begin
    select id, title, author, price, pubyear from catalog;
end;

create procedure if not exists spGetItemsForBasket(ids text)
begin
    select id, title, author, price, pubyear from catalog
    where find_in_set(id, ids);
end;

create procedure if not exists spSaveOrder(
    order_id varchar(20),
    customer text,
    email text,
    phone text,
    address text
)
begin
    insert into orders (order_id, customer, email, phone, address) values (order_id, customer, email, phone, address);
end;

create procedure if not exists spSaveOrderedItems(
    order_id varchar(20),
    item_id int,
    quantity int
)
begin
    insert into ordered_items (order_id, item_id, quantity) values (order_id, item_id, quantity);
end;

create procedure if not exists spGetOrders()
begin
    select id, order_id, customer, email, phone, address, unix_timestamp(created) as created from orders;
end;

create procedure if not exists spGetOrderedItems(order_ids text)
begin
    select order_id, quantity, title, author, price, pubyear from ordered_items
    inner join catalog on ordered_items.item_id = catalog.id
    where find_in_set(ordered_items.order_id, order_ids);
end;

create procedure if not exists spSaveAdmin(login varchar(36), password text, email text)
begin
    insert into admins (login, password, email) values (login, password, email);
end;

create procedure if not exists spGetAdmin(login varchar(36))
begin
    select id, login, password, email, unix_timestamp(created) as created from admins where admins.login = login;
end;

-- SETUP

call spSaveAdmin('root', '$2y$12$ln8.AI63S0abD0.hNHS8mOP38kJigjY6eCURIvRwBwzcQLtqn3YJi', 'root@gmail.com');

call spAddItemToCatalog('C for newbies', 'admeanie', 2999, 2010);
call spAddItemToCatalog('Success flex guide', 'kate', 3599, 2020);
call spAddItemToCatalog('Mafia among us', 'elvladovskiy', 2399, 2019);
call spAddItemToCatalog('Next.js: Vercels success with stat', 'ssrmaster', 1999, 2023);
call spAddItemToCatalog('Math 9th Grade', 'thatnerdguy', 1599, 2006);
call spAddItemToCatalog('How to: ultimate book', 'supportivedad', 2599, 2000);

call spSaveOrder('setupid1', 'Peter', 'peter@gmail.com', '+81234567890', 'far far away');
call spSaveOrderedItems('setupid1', 1, 1);
call spSaveOrderedItems('setupid1', 4, 1);

call spSaveOrder('setupid2', 'Daria', 'daria@gmail.com', '+80987654321', 'behind you');
call spSaveOrderedItems('setupid2', 2, 1);
call spSaveOrderedItems('setupid2', 3, 1);
call spSaveOrderedItems('setupid2', 5, 1);
call spSaveOrderedItems('setupid2', 6, 1);

-- #####################################################################
-- DROP
-- #####################################################################

drop procedure if exists spAddItemToCatalog;
drop procedure if exists spGetCatalog;
drop procedure if exists spGetItemsForBasket;
drop procedure if exists spSaveOrder;
drop procedure if exists spSaveOrderedItems;
drop procedure if exists spGetOrders;
drop procedure if exists spGetOrderedItems;
drop procedure if exists spSaveAdmin;
drop procedure if exists spGetAdmin;

drop table if exists ordered_items;
drop table if exists admins;
drop table if exists orders;
drop table if exists catalog;