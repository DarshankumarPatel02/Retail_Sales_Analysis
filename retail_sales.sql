select * from fmcg_retail_data;

--data is cleaned and preprocessed
--KPI's Building

--Product Sales Growth
SELECT
    product_id,product,
    ((SUM(CASE WHEN dt_order BETWEEN '2023-01-01' AND '2023-12-31' THEN sales ELSE 0 END) -
      SUM(CASE WHEN dt_order BETWEEN '2022-01-01' AND '2022-12-31' THEN sales ELSE 0 END)) /
     SUM(CASE WHEN dt_order BETWEEN '2022-01-01' AND '2022-12-31' THEN sales ELSE 0 END) * 100) AS product_sales_growth_rate
FROM
    fmcg_retail_data
GROUP BY
    product_id,product;

--Category Market Share
SELECT
    category,
    (SUM(sales) / (SELECT SUM(sales) FROM fmcg_retail_data) * 100) AS category_market_share
FROM
    fmcg_retail_data
GROUP BY
    category;

--Profit Margin by Product
SELECT
    product_id,product,
    (SUM(profit) / SUM(sales) * 100) AS profit_margin_per_product
FROM
    fmcg_retail_data
GROUP BY
    product_id,product
ORDER BY profit_margin_per_product DESC;

--Discount Effectiveness
WITH sales_with_discount AS (
    SELECT
        product_id,product,
        SUM(sales) AS sales_with_discount
    FROM
        fmcg_retail_data
    WHERE
        discount > 0
    GROUP BY
        product_id,product
),
sales_without_discount AS (
    SELECT
        product_id,product,
        SUM(sales) AS sales_without_discount
    FROM
        fmcg_retail_data
    WHERE
        discount = 0
    GROUP BY
        product_id,product
)
SELECT
    w.product_id,w.product,
    ((w.sales_with_discount - d.sales_without_discount) / d.sales_without_discount * 100) AS discount_effectiveness
FROM
    sales_with_discount w
JOIN
    sales_without_discount d ON w.product_id = d.product_id;

--Average Sales per Product
SELECT
    product_id,product,
    (ROUND(SUM(sales) / COUNT(DISTINCT order_id),2)) AS average_sales_per_product
FROM
    fmcg_retail_data
GROUP BY
    product_id,product;


--Customer Acquisition
WITH new_customers AS (
    SELECT
        order_id,
        MIN(dt_order) AS first_order_date
    FROM
        fmcg_retail_data
    GROUP BY
        order_id
    HAVING
        MIN(dt_order) >= '2023-01-01' -- Example: New customers acquired in 2023
)
-- Calculate Total Acquisition Cost and Number of New Customers
SELECT
    SUM(sd.cost_per_unit * sd.quantity) AS total_acquisition_cost,
    COUNT(DISTINCT nc.order_id) AS number_of_new_customers,
    (SUM(sd.cost_per_unit * sd.quantity) / COUNT(DISTINCT nc.order_id)) AS customer_acquisition_cost
FROM
    fmcg_retail_data sd
JOIN
    new_customers nc ON sd.order_id = nc.order_id
WHERE
    sd.dt_order >= '2023-01-01';

-- Performing  Exploratory Data Analysis (EDA):

--Q1. What is the count of managers at the region, state and city level?

--Q2. How are Regional sales managers performing in sales and profit?

--Q3. Who are top performing state and city sales managers under Rohan Sharma?

--Q4. What are the sales under Rohan Sharma by store type?

--Q5. Who are the top performing sales reps in sales and profit?

--Q1---
SELECT
    'Regional Sales Manager' AS manager_level,
    COUNT(DISTINCT regional_sales_manager) AS manager_count
FROM
    fmcg_retail_data
UNION ALL
SELECT
    'State Sales Manager',
    COUNT(DISTINCT state_sales_manager)
FROM
    fmcg_retail_data
UNION ALL
SELECT
    'City Sales Manager',
    COUNT(DISTINCT city_sales_manager)
FROM
    fmcg_retail_data
UNION ALL
SELECT
    'Time Stores',
    COUNT(DISTINCT store_id)
FROM
    fmcg_retail_data;

--Q2--
SELECT
    regional_sales_manager,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM
    fmcg_retail_data
GROUP BY
    regional_sales_manager
ORDER BY
    total_sales DESC, total_profit DESC;

--Q3--
-- Top Performing State Sales Managers under Rohan Sharma
SELECT TOP 10
    state_sales_manager,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM
    fmcg_retail_data
WHERE
    regional_sales_manager = 'Rohan Sharma'
GROUP BY
    state_sales_manager
ORDER BY
    total_sales DESC, total_profit DESC;

-- Top Performing City Sales Managers under Rohan Sharma
SELECT TOP 10
    city_sales_manager,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM
    fmcg_retail_data
WHERE
    regional_sales_manager = 'Rohan Sharma'
GROUP BY
    city_sales_manager
ORDER BY
    total_sales DESC, total_profit DESC;

--Q4--
SELECT
    store_type,
    SUM(sales) AS total_sales
FROM
    fmcg_retail_data
WHERE
    regional_sales_manager = 'Rohan Sharma'
GROUP BY
    store_type
ORDER BY
    total_sales DESC;

--Q5---
SELECT TOP 10
    sales_rep,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM
    fmcg_retail_data
GROUP BY
    sales_rep
ORDER BY
    total_sales DESC, total_profit DESC;


