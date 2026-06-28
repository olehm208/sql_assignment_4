create or replace function auto_create_medcard()
returns trigger
language plpgsql
as $$
begin
	insert into medical_cards(patient_id, created_at)
	values(NEW.id, current_timestamp);
	return new;
end;
$$;

create or replace trigger trg_after_patient_insert
after insert on patients
for each row
execute function auto_create_medcard();