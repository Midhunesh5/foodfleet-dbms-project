# FoodFleet

FoodFleet is a DBMS for Food Delivery Orders and Restaurant Rating Analytics. It follows the project presentation: MySQL stores transactional data in a normalized relational schema, MongoDB stores restaurant menus and reviews, and Python connects to MySQL and plots business metrics.

## Project files

- `schema.sql` — the eight-table MySQL schema, keys, constraints, timestamp trigger, and revenue view.
- `data.sql` — a small, clearly labeled synthetic fixture for trying the schema.
- `queries.sql` — the SQL business questions shown in the presentation.
- `analysis.py` — Python DB-API connection and chart generation.
- `notebook.ipynb` — interactive Python DB-API analysis and charts.
- `mongodb/seed.js` — a sample restaurant document and indexes.
- `mongodb/analytics.js` — CRUD examples and the two aggregation pipelines.
- `FoodFleet_DBMS_Presentation.pptx` — the original project presentation.

The presentation contains code excerpts and reported aggregate results, but not the original full source files or underlying records. The SQL fixture is synthetic and intentionally small; it does not claim to reproduce the presentation's reported totals.

## Requirements

- MySQL 8.0+
- MongoDB 5.0+ and `mongosh`
- Python 3.10+

Install the Python dependencies:

```powershell
python -m pip install -r requirements.txt
```

## MySQL setup

Create a database, then execute the scripts in order:

```sql
CREATE DATABASE foodfleet;
```

```powershell
mysql -u root -p foodfleet < schema.sql
mysql -u root -p foodfleet < data.sql
```

Run the business queries with:

```powershell
mysql -u root -p foodfleet < queries.sql
```

The `trg_status_timestamps` trigger fills `picked_at` and `delivered_at` when an order changes to the corresponding status. The fixture includes a placed order that can be used to demonstrate the trigger:

```sql
UPDATE orders SET status = 'PICKED_UP' WHERE order_id = 2;
UPDATE orders SET status = 'DELIVERED' WHERE order_id = 2;
```

## Python analysis

Set the connection values in the current PowerShell session (or copy `.env.example` into your own environment-management workflow; the script reads environment variables directly):

```powershell
$env:FOODFLEET_DB_HOST = "localhost"
$env:FOODFLEET_DB_PORT = "3306"
$env:FOODFLEET_DB_USER = "root"
$env:FOODFLEET_DB_PASSWORD = "your-local-password"
$env:FOODFLEET_DB_NAME = "foodfleet"
python analysis.py
```

Charts are written to `outputs/`. The script reports database and query errors rather than substituting sample results.

Open `notebook.ipynb` in Jupyter or VS Code to run the same analysis interactively. Set the same `FOODFLEET_DB_*` environment variables before starting the notebook kernel.

## MongoDB

Select the target database in `mongosh`, then load the seed and analytics scripts:

```javascript
use foodfleet
load("mongodb/seed.js")
load("mongodb/analytics.js")
```

The seed script uses an upsert for its sample document and creates the indexes from the presentation. The analytics script includes insert, find, update, and delete examples; its delete example targets a nonexistent sample ID.

## Findings reported in the presentation

These are the presentation's reported results, not results from the small synthetic fixture:

- Peak hour: 8 PM (83 orders); next listed hours are 6 PM (61), noon (51), and 9 PM (50).
- Average delivery: 45.4 minutes; 8 PM average: 57.1 minutes.
- Biryani: 130 orders; Hyderabad Kitchen: INR 43,127 revenue.
- Cancellations: 6.3%.
- MongoDB: 20 restaurant documents and 385 reviews.

The original dataset or complete submission source was not included with the presentation. Replace the fixture with that source data if these reported figures need to be independently reproduced.
