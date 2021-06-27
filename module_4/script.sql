WITH flights AS (
SELECT *
FROM dst_project.flights
WHERE departure_airport = 'AAQ'
  AND (date_trunc('MONTH', scheduled_departure) IN ('2017-01-01',
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
        ticket_total * 1.0 / seats_count AS fullness,
        EXTRACT(HOUR
               FROM scheduled_arrival - scheduled_departure) +
        EXTRACT(MINUTE
               FROM scheduled_arrival - scheduled_departure) / 60 AS flight_time_hours,
        51300 AS fuel_price_per_ton
FROM final_data