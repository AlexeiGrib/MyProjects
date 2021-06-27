/*
Задание 4.1.

Условие:
База данных содержит список аэропортов практически всех крупных городов России.
В большинстве городов есть только один аэропорт.
Исключение составляет...

Ответ: Moscow, Ulyanovsk.

Запрос:
*/
SELECT city,
       COUNT(DISTINCT airport_name) AS airport_count
FROM dst_project.airports
GROUP BY 1
ORDER BY 2 DESC;

/*
Задание 4.2.

Вопрос 1.

Условие:
Таблица рейсов содержит всю информацию о прошлых, текущих и запланированных рейсах.
Сколько всего статусов для рейсов определено в таблице?

Ответ: 6.

Запрос:
*/
SELECT COUNT(DISTINCT status) AS status_count
FROM dst_project.flights

/*
Вопрос 2.

Условие:
Какое количество самолетов находятся в воздухе на момент среза в базе
(статус рейса «самолёт уже вылетел и находится в воздухе»).

Ответ: 58.

Запрос:
*/
SELECT COUNT(status) AS flight_count
FROM dst_project.flights
WHERE status = 'Departed';

/*
Вопрос 3.

Условие:
Места определяют схему салона каждой модели. Сколько мест имеет самолет модели 773 (Boeing 777-300)?

Ответ: 402.

Запрос:
*/
SELECT COUNT(seat_no) AS seat_count
FROM dst_project.seats
WHERE aircraft_code = '773';

/*
Вопрос 4.

Условие:
Сколько состоявшихся (фактических) рейсов было совершено между 1 апреля 2017 года и 1 сентября 2017 года?

Ответ: 74227.

Запрос:
*/
SELECT COUNT(DISTINCT flight_id) flight_count
FROM dst_project.flights
WHERE scheduled_arrival::DATE BETWEEN '2017-04-01' AND '2017-09-01'
  AND status = 'Arrived'
  AND status != 'Cancelled';

/*
Задание 4.3.

Вопрос 1.

Условие:
Сколько всего рейсов было отменено по данным базы?

Ответ: 437.

Запрос:
*/
SELECT COUNT(DISTINCT flight_id) AS flight_count
FROM dst_project.flights
WHERE status = 'Cancelled';

/*
Вопрос 2.

Условие:
Сколько самолетов моделей типа Boeing, Sukhoi Superjet, Airbus находится в базе авиаперевозок?

Ответ:
Boeing = 3.
Sukhoi Superjet = 1.
Airbus = 3.

Запрос:
*/
SELECT COUNT(DISTINCT aircraft_code) AS aircraft_count
FROM dst_project.aircrafts
WHERE model LIKE 'Airbus%'

SELECT COUNT(DISTINCT aircraft_code) AS aircraft_count
FROM dst_project.aircrafts
WHERE model LIKE 'Boeing%'

SELECT COUNT(DISTINCT aircraft_code) AS aircraft_count
FROM dst_project.aircrafts
WHERE model LIKE 'Sukhoi Superjet%'

/*
Вопрос 3.

Условие:
В какой части (частях) света находится больше аэропортов?

Ответ: Europe, Asia.

Запрос:
*/
SELECT SPLIT_PART(timezone, '/', 1) AS world_part,
       COUNT(DISTINCT airport_name) AS airports_count
FROM dst_project.airports
GROUP BY 1

/*
Вопрос 4.

Условие:
У какого рейса была самая большая задержка прибытия за все время сбора данных? Введите id рейса (flight_id).

Ответ: 157571.

Запрос:
*/
SELECT flight_id
FROM dst_project.flights
WHERE actual_arrival IS NOT NULL
ORDER BY actual_arrival - scheduled_arrival DESC
LIMIT 1

/*
Задание 4.4.

Вопрос 1.

Условие:
Когда был запланирован самый первый вылет, сохраненный в базе данных?

Ответ: 14.08.2016.

Запрос:
*/
SELECT MIN(scheduled_departure) AS min_date
FROM dst_project.flights

/*
Вопрос 2.

Условие:
Сколько минут составляет запланированное время полета в самом длительном рейсе?

Ответ: 530.

Запрос:
*/
SELECT MAX(EXTRACT(MINUTE
                   FROM scheduled_arrival - scheduled_departure) + EXTRACT(HOUR
                                                                           FROM scheduled_arrival - scheduled_departure) * 60) AS diff
FROM dst_project.flights

/*
Вопрос 3.

Условие:
Между какими аэропортами пролегает самый длительный по времени запланированный рейс?

Ответ: DME - UUS.

Запрос:
*/
SELECT departure_airport,
       arrival_airport,
       EXTRACT(MINUTE
               FROM scheduled_arrival - scheduled_departure) + EXTRACT(HOUR
                                                                       FROM scheduled_arrival - scheduled_departure) * 60 AS diff
FROM dst_project.flights
ORDER BY 3 DESC
LIMIT 1

/*
Вопрос 4.

Условие:
Сколько составляет средняя дальность полета среди всех самолетов в минутах?
Секунды округляются в меньшую сторону (отбрасываются до минут).

Ответ: 128.

Запрос:
*/
SELECT EXTRACT(MINUTE
               FROM AVG(scheduled_arrival - scheduled_departure)) + EXTRACT(HOUR
                                                                            FROM AVG(scheduled_arrival - scheduled_departure)) * 60 AS avg_flight_time
FROM dst_project.flights
LIMIT 1

/*
Задание 4.5.

Вопрос 1.

Условие:
Мест какого класса у SU9 больше всего?

Ответ: Economy.

Запрос:
*/
SELECT DISTINCT fare_conditions,
                COUNT(seat_no) OVER (PARTITION BY fare_conditions) AS seats_count
FROM dst_project.seats
WHERE aircraft_code = 'SU9'

/*
Вопрос 2.

Условие:
Какую самую минимальную стоимость составило бронирование за всю историю?

Ответ: 3400.

Запрос:
*/
SELECT MIN(total_amount) AS min_amount
FROM dst_project.bookings

/*
Вопрос 3.

Условие:
Какой номер места был у пассажира с id = 4313 788533?

Ответ: 2A.

Запрос:
*/
SELECT bp.seat_no
FROM dst_project.tickets ts
LEFT JOIN dst_project.boarding_passes bp ON ts.ticket_no = bp.ticket_no
WHERE ts.passenger_id = '4313 788533'

/*
Задание 5.1.

Вопрос 1.

Условие:
Анапа — курортный город на юге России. Сколько рейсов прибыло в Анапу за 2017 год?

Ответ: 486.

Запрос:
*/
SELECT COUNT(flight_id) AS flight_count
FROM dst_project.flights
WHERE arrival_airport = 'AAQ'
  AND EXTRACT(YEAR
              FROM COALESCE(actual_arrival, scheduled_arrival)) = 2017
  AND status = 'Arrived'

/*
Вопрос 2.

Условие:
Сколько рейсов из Анапы вылетело зимой 2017 года?

Ответ: 127.

Запрос:
*/
SELECT COUNT(DISTINCT flight_id) AS flight_count
FROM dst_project.flights
WHERE departure_airport = 'AAQ'
  AND EXTRACT(YEAR
              FROM scheduled_departure) = 2017
  AND EXTRACT(MONTH
              FROM scheduled_departure) in (12,
                                            1,
                                            2)

/*
Вопрос 3.

Условие:
Посчитайте количество отмененных рейсов из Анапы за все время.

Ответ: 1.

Запрос:
*/
SELECT COUNT(DISTINCT flight_id)
FROM dst_project.flights
WHERE departure_airport = 'AAQ'
  AND status = 'Cancelled'

/*
Вопрос 4.

Условие:
Сколько рейсов из Анапы не летают в Москву?

Ответ: 453.

Запрос:
*/
SELECT COUNT(flight_no)
FROM dst_project.flights
WHERE arrival_airport NOT IN
    (SELECT DISTINCT airport_code
     FROM dst_project.airports
     WHERE city = 'Moscow')
  AND departure_airport = 'AAQ'

/*
Вопрос 5.

Условие:
Какая модель самолета летящего на рейсах из Анапы имеет больше всего мест?

Ответ: Boeing 737-300.

Запрос:
*/
SELECT DISTINCT s.aircraft_code,
                arc.model,
                COUNT(s.seat_no) OVER (PARTITION BY s.aircraft_code) AS seats_count
FROM dst_project.seats s
LEFT JOIN dst_project.aircrafts arc ON arc.aircraft_code = s.aircraft_code
WHERE s.aircraft_code IN
    (SELECT DISTINCT aircraft_code
     FROM dst_project.flights
     WHERE departure_airport = 'AAQ')


-- project 04
WITH flights AS (
SELECT *
FROM dst_project.flights
WHERE departure_airport = 'AAQ'
  AND (DATE_TRUNC('MONTH', scheduled_departure) IN ('2017-01-01',
                                                    '2017-02-01',
                                                    '2017-12-01'))
  AND status NOT IN ('Cancelled')
),

seats AS (
SELECT DISTINCT s.aircraft_code,
                COUNT(DISTINCT s.seat_no) AS seats_count,
                COUNT(CASE
                          WHEN s.fare_conditions = 'Business' THEN s.fare_conditions
                      END) AS business_count,
                COUNT(CASE
                          WHEN s.fare_conditions = 'Economy' THEN s.fare_conditions
                      END) AS economy_count
FROM dst_project.seats AS s
GROUP BY 1
),

tickets_and_amount AS (
SELECT DISTINCT tf.flight_id,
                COUNT(tf.fare_conditions) FILTER (WHERE tf.fare_conditions = 'Economy') OVER (PARTITION BY tf.flight_id) AS ticket_economy,
                COUNT(tf.fare_conditions) FILTER (WHERE tf.fare_conditions = 'Comfort') OVER (PARTITION BY tf.flight_id) AS ticket_comfort,
                COUNT(tf.fare_conditions) FILTER (WHERE tf.fare_conditions = 'Business') OVER (PARTITION BY tf.flight_id) AS ticket_bisiness,
                COUNT(tf.fare_conditions) OVER (PARTITION BY tf.flight_id) AS ticket_total,
                SUM(tf.amount) FILTER (WHERE tf.fare_conditions = 'Economy') OVER (PARTITION BY flight_id) AS economy_amount,
                SUM(tf.amount) FILTER (WHERE tf.fare_conditions = 'Comfort') OVER (PARTITION BY flight_id) AS comfort_amount,
                SUM(tf.amount) FILTER (WHERE tf.fare_conditions = 'Business') OVER (PARTITION BY flight_id) AS business_amount,
                SUM(tf.amount) OVER (PARTITION BY flight_id) AS total_amount
FROM dst_project.ticket_flights AS tf
WHERE tf.flight_id IN (SELECT DISTINCT flight_id FROM flights)
),

fuel_consumption AS (
SELECT 'SU9' AS aircraft_code,
       1.8 AS fuel_consumption_per_hour
UNION
SELECT '733' AS aircraft_code,
       2.6 AS fuel_consumption_per_hour
),


final_data AS
  (SELECT *
   FROM flights
   LEFT JOIN seats USING (aircraft_code)
   LEFT JOIN tickets_and_amount USING (flight_id)
   LEFT JOIN fuel_consumption USING (aircraft_code)
)

SELECT *,
       EXTRACT(HOUR
               FROM scheduled_arrival - scheduled_departure) +
       EXTRACT(MINUTE
               FROM scheduled_arrival - scheduled_departure) / 60 AS flight_time_hours,
       51300 AS fuel_price_per_ton
FROM final_data