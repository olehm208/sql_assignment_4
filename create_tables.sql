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
drop table if exists specialization cascade;
drop table if exists doctors_specializations cascade;
drop table if exists doctors_services cascade;

create table rooms(
	id serial primary key,
	--корпус
	building varchar(200) not null,
	floor int not null,
	--номер кабінету
	number int not null,
	display_name varchar(200) not null,
	--тип (операційна і тд)
	room_type varchar(200) not null
);
create table services(
	id serial primary key,
	--назва послуги (консультація, тд)
	service_name varchar(200) not null,
	description text not null,
	price numeric(10,2) not null,
	-- кількість часу, в хвилинах
	duration int not null
);
--проміжки/слоти на запис
create table work_shift_schedule(
	id serial primary key,
	start_time time not null,
	end_time time not null
);
create table specialization (
	id serial primary key,
	name varchar(150) not null unique
);
create table doctors(
	id serial primary key,
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	email varchar(70) not null,
	phone varchar(20) not null,
	active bool not null default true
);

create table patients(
	id serial primary key,
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	birth_day date not null,
	email varchar(70) not null,
	phone varchar(20) not null,
	active bool not null default true
);
create table doctors_specializations (
	doctor_id int references doctors(id) on delete cascade,
	specialization_id int references specialization(id) on delete cascade,
	-- най дублюється скільки хоче, але комбінація НЕ МОЖЕ дублюватись.
	primary key (doctor_id, specialization_id)
);
create table doctors_services (
	doctor_id int references doctors(id) on delete cascade,
	service_id int references services(id) on delete cascade,
	-- най дублюється скільки хоче, але комбінація НЕ МОЖЕ дублюватись.
	primary key (doctor_id, service_id)
);
create table medical_cards (
	id serial primary key,
	patient_id int unique not null references patients(id) on delete cascade,
	created_at timestamp not null default current_timestamp
);
create table appointments(
	id serial primary key,
	patient_id int not null references patients(id),
	doctor_id int not null references doctors(id),
	service_id int not null references services(id),
	room_id int not null references rooms(id),
	shift_schedule_id int not null references work_shift_schedule(id),
	appointment_date date not null,
	status varchar(50) not null default 'Scheduled'
);