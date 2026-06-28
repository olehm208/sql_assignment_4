-- PostgreSQL version
drop database if exists hospital;
create database hospital;

drop table if exists rooms cascade;
drop table if exists services cascade;
drop table if exists work_shift_schedule cascade;
drop table if exists doctors cascade;
drop table if exists patients cascade;
drop table if exists medical_cards cascade;
drop table if exists appointments cascade;

create table rooms(
	id serial primary key,
	--корпус
	building varchar(200),
	floor int,
	--номер кабінету
	number int,
	display_name varchar(200),
	--тип (операційна і тд)
	room_type varchar(200)
);
