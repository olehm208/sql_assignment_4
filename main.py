import psycopg2
from psycopg2 import Error
from psycopg2.extras import execute_values  # Швидка пакетна вставка
from datetime import date, time, timedelta

HOST = 'localhost' 
USER = 'postgres' 
PASSWORD = 'itstartswithone' 
DATABASE = 'hospital' 
PORT = '5432' 


def create_connection():
    """Create a PostgreSQL database connection."""
    try:
        connection = psycopg2.connect(
            host=HOST,
            port=PORT,
            user=USER,
            password=PASSWORD,
            dbname=DATABASE,
        )
        print("Connection to PostgreSQL DB successful")
        return connection
    except Error as e:
        print(f"The error '{e}' occurred")
        return None


def insert_data():
    connection = create_connection()
    if connection is None:
        return

    cursor = connection.cursor()

    try:
        print("Заповнення базових довідників...")
        
        # 1. Rooms
        rooms_query = "INSERT INTO rooms (building, floor, number, display_name, room_type) VALUES %s"
        rooms_data = [
            ("Головний корпус", 1, 101, "Кабінет 101", "Консультаційний"),
            ("Хірургічний корпус", 2, 202, "Операційна 2", "Операційна"),
        ]
        execute_values(cursor, rooms_query, rooms_data)

        # 2. Services
        services_query = "INSERT INTO services (service_name, description, price, duration) VALUES %s"
        services_data = [
            ("Первинна充онсультація терапевта", "Огляд пацієнта, збір анамнезу", 150.00, 20),
            ("УЗД черевної порожнини", "Ультразвукове дослідження внутрішніх органів", 450.00, 30),
        ]
        execute_values(cursor, services_query, services_data)

        # 3. Work Shift Schedule
        schedule_query = "INSERT INTO work_shift_schedule (start_time, end_time) VALUES %s"
        schedule_data = [
            (time(8, 0), time(8, 30)),
            (time(8, 30), time(9, 0)),
        ]
        execute_values(cursor, schedule_query, schedule_data)

        # 4. Specialization
        spec_query = "INSERT INTO specialization (name) VALUES %s ON CONFLICT (name) DO NOTHING"
        spec_data = [("Терапевт",), ("Діагност",)]
        execute_values(cursor, spec_query, spec_data)

        # 5. Doctors
        doctors_query = "INSERT INTO doctors (first_name, last_name, email, phone, active) VALUES %s"
        doctors_data = [
            ("Іван", "Іванов", "ivanov@hospital.com", "+380501112233", True),
            ("Марія", "Петренко", "petrenko@hospital.com", "+380674445566", True),
        ]
        execute_values(cursor, doctors_query, doctors_data)

        # Зв'язки лікарів
        execute_values(cursor, "INSERT INTO doctors_specializations (doctor_id, specialization_id) VALUES %s ON CONFLICT DO NOTHING", [(1, 1), (2, 2)])
        execute_values(cursor, "INSERT INTO doctors_services (doctor_id, service_id) VALUES %s ON CONFLICT DO NOTHING", [(1, 1), (2, 2)])

        # 6. ГЕНЕРАЦІЯ ВЕЛИКИХ ДАНИХ (100 000 Пацієнтів)
        print("Генерація 100 000 пацієнтів...")
        patients_data = [
            (f"Пацієнт_{i}", f"Прізвище_{i}", date(1980, 1, 1) + timedelta(days=i % 10000), f"patient_{i}@example.com", f"+38093111{i:04d}", True)
            for i in range(1, 100001)
        ]
        patients_query = "INSERT INTO patients (first_name, last_name, birthday, email, phone, active) VALUES %s ON CONFLICT DO NOTHING"
        
        # Вставляємо пацієнтів порціями по 20 000 для економії пам'яті
        for j in range(0, len(patients_data), 20000):
            execute_values(cursor, patients_query, patients_data[j:j+20000])

        # Автоматично створюємо медичні картки для всіх згенерованих пацієнтів
        print("Створення медичних карток...")
        cursor.execute("INSERT INTO medical_cards (patient_id) SELECT id FROM patients ON CONFLICT DO NOTHING")

        # 7. ГЕНЕРАЦІЯ ВЕЛИКИХ ДАНИХ (500 000 Прийомів)
        print("Генерація 500 000 записів на прийом (це займе близько 10-15 секунд)...")
        
        appointments_data = []
        start_date = date(2026, 1, 1)
        
        # Щоб не порушити твої UNIQUE індекси (doctor_id, appointment_date, shift_schedule_id)
        # ми будемо зсувати дату або зміну для кожного нового запису
        for i in range(1, 500001):
            patient_id = (i % 100000) + 1  # Зациклюємо по створених 100к пацієнтах
            doctor_id = (i % 2) + 1        # Чергуємо лікаря 1 та 2
            room_id = (i % 2) + 1          # Чергуємо кімнату 1 та 2
            shift_id = (i % 2) + 1         # Чергуємо зміну 1 та 2
            
            # Зсуваємо день вперед кожні 2 записи, щоб у лікаря/кімнати не було двох записів на один слот в один день
            date_offset = i // 2 
            app_date = start_date + timedelta(days=date_offset)
            
            appointments_data.append((patient_id, doctor_id, 1, room_id, shift_id, app_date, 'Scheduled'))

        appointments_query = "INSERT INTO appointments (patient_id, doctor_id, service_id, room_id, shift_schedule_id, appointment_date, status) VALUES %s"
        
        for j in range(0, len(appointments_data), 20000):
            execute_values(cursor, appointments_query, appointments_data[j:j+20000])

        connection.commit()
        print("Всі дані успішно завантажено!")

    except Error as e:
        connection.rollback()
        print(f"Помилка під час генерації: {e}")
    finally:
        cursor.close()
        connection.close()
        print("Підключення до БД закрито.")


if __name__ == "__main__":
    insert_data()
