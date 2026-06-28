-- PostgreSQL version. Run as a superuser or database owner.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'hospital_admin') THEN
        CREATE ROLE hospital_admin LOGIN PASSWORD 'password1';
    END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'hospital_receptionist') THEN
	        CREATE ROLE hospital_receptionist LOGIN PASSWORD 'password2';
    END IF;
	IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'hospital_doctor') THEN
	        CREATE ROLE hospital_doctor LOGIN PASSWORD 'password3';
    END IF;
END
$$;
-- адмін має доступ до всього
grant all privileges on database hospital to hospital_admin; 
grant all privileges on all tables in schema public to hospital_admin; 
-- рецепшн може редагувати пацієентів, кімнати і аппойнтменти
grant select, insert, update, delete on patients, appointments to hospital_receptionist;
grant select on doctors, services, rooms, work_shift_schedule to hospital_receptionist;
-- доктори маю read-only до апойнтментів, але повний доступ до мед карти.
grant select on appointments, doctors, services, rooms, work_shift_schedule, patients to hospital_doctor;
grant select, insert, update on medical_cards to hospital_doctor;
-- Check grants:
-- \dp schedules
