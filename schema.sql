CREATE TABLE cuisines (
    cuisine_id INT AUTO_INCREMENT PRIMARY KEY,
    cuisine_name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    area VARCHAR(100) NOT NULL
);

CREATE TABLE restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    cuisine_id INT NOT NULL,
    name VARCHAR(120) NOT NULL,
    area VARCHAR(100) NOT NULL,
    CONSTRAINT fk_restaurants_cuisine
        FOREIGN KEY (cuisine_id) REFERENCES cuisines(cuisine_id)
);

CREATE TABLE menu_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    name VARCHAR(120) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    is_veg BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_menu_items_price CHECK (price >= 0),
    CONSTRAINT fk_menu_items_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE delivery_partners (
    partner_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    vehicle VARCHAR(40) NOT NULL,
    rating DECIMAL(2, 1),
    CONSTRAINT chk_delivery_partner_rating CHECK (rating BETWEEN 0 AND 5)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    restaurant_id INT NOT NULL,
    partner_id INT,
    status ENUM('PLACED', 'PICKED_UP', 'DELIVERED', 'CANCELLED')
        NOT NULL DEFAULT 'PLACED',
    placed_at DATETIME NOT NULL,
    picked_at DATETIME,
    delivered_at DATETIME,
    CONSTRAINT chk_orders_timestamps CHECK (
        (picked_at IS NULL OR picked_at >= placed_at)
        AND (delivered_at IS NULL OR delivered_at >= placed_at)
    ),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    CONSTRAINT fk_orders_partner
        FOREIGN KEY (partner_id) REFERENCES delivery_partners(partner_id)
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, item_id),
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_price CHECK (unit_price >= 0),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_menu_item
        FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    method ENUM('CASH', 'CARD', 'UPI', 'WALLET') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_payments_amount CHECK (amount >= 0),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

DELIMITER //

CREATE TRIGGER trg_status_timestamps
BEFORE UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'PICKED_UP' AND OLD.status <> 'PICKED_UP' THEN
        SET NEW.picked_at = COALESCE(NEW.picked_at, CURRENT_TIMESTAMP);
    END IF;

    IF NEW.status = 'DELIVERED' AND OLD.status <> 'DELIVERED' THEN
        SET NEW.picked_at = COALESCE(NEW.picked_at, CURRENT_TIMESTAMP);
        SET NEW.delivered_at = COALESCE(NEW.delivered_at, CURRENT_TIMESTAMP);
    END IF;
END//

DELIMITER ;

CREATE VIEW v_restaurant_revenue AS
SELECT
    r.restaurant_id,
    r.name AS restaurant_name,
    c.cuisine_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM restaurants AS r
JOIN cuisines AS c ON c.cuisine_id = r.cuisine_id
JOIN orders AS o ON o.restaurant_id = r.restaurant_id
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status = 'DELIVERED'
GROUP BY r.restaurant_id, r.name, c.cuisine_name;
