-- Small synthetic fixture for demonstrating the schema; not the source dataset.
INSERT INTO cuisines (cuisine_id, cuisine_name) VALUES
    (1, 'Biryani'),
    (2, 'Desserts');

INSERT INTO customers (customer_id, name, phone, area) VALUES
    (1, 'Asha Rao', '9000000001', 'Jayanagar'),
    (2, 'Ravi Kumar', '9000000002', 'Indiranagar');

INSERT INTO restaurants (restaurant_id, cuisine_id, name, area) VALUES
    (4, 1, 'Biryani House', 'Jayanagar'),
    (5, 2, 'Cake Walk', 'Indiranagar');

INSERT INTO menu_items (item_id, restaurant_id, name, price, is_veg) VALUES
    (1, 4, 'Chicken Biryani', 280.00, FALSE),
    (2, 4, 'Veg Biryani', 220.00, TRUE),
    (3, 5, 'Brownie', 180.00, TRUE);

INSERT INTO delivery_partners (partner_id, name, vehicle, rating) VALUES
    (1, 'Partner One', 'Motorcycle', 4.7);

INSERT INTO orders (
    order_id, customer_id, restaurant_id, partner_id, status,
    placed_at, picked_at, delivered_at
) VALUES
    (1, 1, 4, 1, 'DELIVERED', '2026-01-10 20:00:00',
     '2026-01-10 20:18:00', '2026-01-10 20:45:00'),
    (2, 2, 5, 1, 'PLACED', '2026-01-10 18:30:00', NULL, NULL);

INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES
    (1, 1, 1, 280.00),
    (1, 2, 1, 220.00),
    (2, 3, 2, 180.00);

INSERT INTO payments (payment_id, order_id, method, amount) VALUES
    (1, 1, 'UPI', 500.00);
