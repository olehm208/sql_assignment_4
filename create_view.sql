DROP VIEW IF EXISTS upcoming_appointments;
CREATE OR REPLACE VIEW upcoming_appointments AS
select
	apps.id as appointment_id,
	apps.appointment_date,
	workshift.start_time,
	workshift.end_time,
	concat(pats.first_name, ' ', pats.last_name) as patient_name,
	pats.phone as patient_phone,
	concat(docs.first_name, ' ', docs.last_name) as doctor_name,
	serv.service_name,
	serv.price as service_cost,
	room.display_name as room_location,
	apps.status
from appointments apps
join patients pats on apps.patient_id = pats.id
join doctors docs on apps.doctor_id = docs.id
join services serv on apps.service_id = serv.id
join rooms room on apps.room_id = room.id
join work_shift_schedule workshift on apps.shift_schedule_id = workshift.id
where apps.appointment_date >= current_date
order by apps.appointment_date asc, workshift.start_time asc;

-- To check performance, run separately, not inside CREATE VIEW:
EXPLAIN ANALYZE SELECT * FROM upcoming_appointments;
