-- Peak order hours.
SELECT HOUR(placed_at) AS hr, COUNT(*) AS orders
FROM orders
GROUP BY hr
ORDER BY orders DESC
LIMIT 4;

-- Orders by cuisine.
SELECT c.cuisine_name, COUNT(*) AS orders
FROM orders AS o
JOIN restaurants AS r ON r.restaurant_id = o.restaurant_id
JOIN cuisines AS c ON c.cuisine_id = r.cuisine_id
GROUP BY c.cuisine_id, c.cuisine_name
ORDER BY orders DESC;

-- Average delivery time, in minutes.
SELECT AVG(TIMESTAMPDIFF(MINUTE, placed_at, delivered_at)) AS avg_delivery_min
FROM orders
WHERE status = 'DELIVERED' AND delivered_at IS NOT NULL;

-- Average delivery time by hour of placement.
SELECT
    HOUR(placed_at) AS hr,
    AVG(TIMESTAMPDIFF(MINUTE, placed_at, delivered_at)) AS avg_delivery_min
FROM orders
WHERE status = 'DELIVERED' AND delivered_at IS NOT NULL
GROUP BY hr
ORDER BY hr;

-- Restaurant revenue, as defined by the view.
SELECT restaurant_name, cuisine_name, revenue
FROM v_restaurant_revenue
ORDER BY revenue DESC;

-- Cancellation rate.
SELECT
    100.0 * SUM(status = 'CANCELLED') / NULLIF(COUNT(*), 0) AS cancellation_pct
FROM orders;
