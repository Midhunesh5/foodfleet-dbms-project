import os
from pathlib import Path

import matplotlib.pyplot as plt
import mysql.connector
import pandas as pd


HOUR_SQL = """
SELECT HOUR(placed_at) AS hr, COUNT(*) AS orders
FROM orders
GROUP BY hr
ORDER BY hr
"""

RESTAURANT_REVENUE_SQL = """
SELECT restaurant_name, revenue
FROM v_restaurant_revenue
ORDER BY revenue DESC
LIMIT 10
"""

CUISINE_SQL = """
SELECT c.cuisine_name, COUNT(*) AS orders
FROM orders AS o
JOIN restaurants AS r ON r.restaurant_id = o.restaurant_id
JOIN cuisines AS c ON c.cuisine_id = r.cuisine_id
GROUP BY c.cuisine_id, c.cuisine_name
ORDER BY orders DESC
LIMIT 10
"""

DELIVERY_TIME_SQL = """
SELECT
    HOUR(placed_at) AS hr,
    AVG(TIMESTAMPDIFF(MINUTE, placed_at, delivered_at)) AS avg_delivery_min
FROM orders
WHERE status = 'DELIVERED' AND delivered_at IS NOT NULL
GROUP BY hr
ORDER BY hr
"""


def main():
    connection = mysql.connector.connect(
        host=os.getenv("FOODFLEET_DB_HOST", "localhost"),
        port=int(os.getenv("FOODFLEET_DB_PORT", "3306")),
        user=os.getenv("FOODFLEET_DB_USER", "root"),
        password=os.getenv("FOODFLEET_DB_PASSWORD", ""),
        database=os.getenv("FOODFLEET_DB_NAME", "foodfleet"),
    )
    try:
        datasets = {
            "orders_by_hour": pd.read_sql(HOUR_SQL, connection),
            "restaurant_revenue": pd.read_sql(RESTAURANT_REVENUE_SQL, connection),
            "orders_by_cuisine": pd.read_sql(CUISINE_SQL, connection),
            "delivery_time_by_hour": pd.read_sql(DELIVERY_TIME_SQL, connection),
        }
    finally:
        connection.close()

    output_dir = Path("outputs")
    output_dir.mkdir(exist_ok=True)

    charts = (
        ("orders_by_hour", "hr", "orders", "Orders by hour of day"),
        ("restaurant_revenue", "restaurant_name", "revenue", "Top restaurants by revenue"),
        ("orders_by_cuisine", "cuisine_name", "orders", "Orders by cuisine"),
        ("delivery_time_by_hour", "hr", "avg_delivery_min", "Average delivery time by hour"),
    )
    for key, x_column, y_column, title in charts:
        data = datasets[key]
        if data.empty:
            print(f"Skipping {title}: query returned no rows.")
            continue
        axis = data.plot(
            x=x_column,
            y=y_column,
            kind="bar",
            legend=False,
            title=title,
            figsize=(9, 5),
        )
        axis.set_xlabel(x_column.replace("_", " ").title())
        axis.set_ylabel(y_column.replace("_", " ").title())
        axis.figure.tight_layout()
        axis.figure.savefig(output_dir / f"{key}.png", dpi=150)
        plt.close(axis.figure)

    for key, data in datasets.items():
        print(f"\n{key.replace('_', ' ').title()}")
        print(data.to_string(index=False))


if __name__ == "__main__":
    main()
