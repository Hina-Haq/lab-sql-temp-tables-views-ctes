USE sakila;

-- 1. Create a view that summarizes rental information for each customer
DROP VIEW IF EXISTS rental_summary;

CREATE VIEW rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;

-- 2. Create a temporary table that calculates the total amount paid by each customer
DROP TEMPORARY TABLE IF EXISTS customer_payment_summary;

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT
    rs.customer_id,
    rs.customer_name,
    rs.email,
    rs.rental_count,
    SUM(p.amount) AS total_paid
FROM rental_summary rs
JOIN payment p
    ON rs.customer_id = p.customer_id
GROUP BY
    rs.customer_id,
    rs.customer_name,
    rs.email,
    rs.rental_count;

-- 3. Create a CTE and generate the final customer summary report
WITH customer_summary_cte AS (
    SELECT
        rs.customer_name,
        rs.email,
        rs.rental_count,
        cps.total_paid
    FROM rental_summary rs
    JOIN customer_payment_summary cps
        ON rs.customer_id = cps.customer_id
)
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY customer_name;