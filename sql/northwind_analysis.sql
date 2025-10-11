-----------------------------------------------------
/*----------- SALES & REVENUE INSIGHTS ------------*/
-----------------------------------------------------

-- Q1: Which products and categories drive the most revenue, and how can this information guide sales and inventory strategies?

WITH
    revenue_by_product AS (
        SELECT
            prd.product_name,
            ctg.category_name,
            SUM(
                odd.unit_price * odd.quantity * (1 - odd.discount)
            ) AS total_revenue
        FROM
            public.products prd
            JOIN order_details odd ON (odd.product_id = prd.product_id)
            JOIN categories ctg ON (prd.category_id = ctg.category_id)
        GROUP BY
            prd.product_name,
            ctg.category_name
    )
SELECT
    product_name AS "Product Name",
    category_name AS "Product Category",
    ROUND(total_revenue, 2) AS "Total Revenue ($)",
    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100,
        2
    ) AS "Revenue Share (%)"
FROM
    revenue_by_product
ORDER BY
    total_revenue DESC;

-- Q2: Who are the top customers, and what portion of total sales do they represent?

WITH
    customer_spending AS (
        SELECT
            cst.company_name as customers,
            SUM(
                odd.quantity * odd.unit_price * (1 - odd.discount)
            ) AS total_spending
        FROM
            customers cst
            JOIN orders odr ON (odr.customer_id = cst.customer_id)
            JOIN order_details odd ON (odd.order_id = odr.order_id)
        GROUP BY
            cst.company_name
    ),
    top_customers AS (
        SELECT
            customers,
            ROUND(total_spending, 2) AS total_spending
        FROM
            customer_spending
        WHERE -- top cusomers
            total_spending >= (
                SELECT
                    PERCENTILE_CONT(0.75) WITHIN GROUP (
                        ORDER BY
                            total_spending
                    )
                FROM
                    customer_spending
            )
    )
SELECT
    customers AS "Customers",
    total_spending AS "Total Spending ($)",
    ROUND(
        total_spending / SUM(total_spending) OVER () * 100,
        2
    ) AS "Spending Share (%)"
FROM
    top_customers
ORDER BY
    total_spending DESC;

-- Q3: Which countries or markets contribute most to revenue, and where are the opportunities for growth?

WITH
    country_revenue AS (
        SELECT
            odr.ship_country AS countries,
            ROUND(
                SUM(
                    odd.unit_price * odd.quantity * (1 - odd.discount)
                ),
                2
            ) AS total_revenue
        FROM
            order_details odd
            JOIN orders odr ON (odd.order_id = odr.order_id)
        GROUP BY
            countries
    )
SELECT
    countries AS "Countries",
    total_revenue AS "Total Revenue ($)",
    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100,
        2
    ) AS "Revenue Share (%)"
FROM
    country_revenue
ORDER BY
    total_revenue DESC;

---------------------------------------------------------
/*---------- PRODUCT & INVENTORY PERFORMENCE ----------*/
---------------------------------------------------------

-- Q4: Which products are frequently ordered together, and how can this support cross-selling or bundling strategies?

WITH
    product_orders AS (
        SELECT
            odd.order_id,
            prd.product_name
        FROM
            order_details odd
            JOIN products prd ON (odd.product_id = prd.product_id)
    ),
    bundled_order AS (
        SELECT
            pdo.product_name AS first_product,
            prd.product_name AS second_product,
            COUNT(*) AS order_count
        FROM
            order_details odd
            JOIN products prd ON (odd.product_id = prd.product_id)
            JOIN product_orders pdo ON pdo.order_id = odd.order_id
            AND pdo.product_name < prd.product_name
        GROUP BY
            pdo.product_name,
            prd.product_name
    )
SELECT
    first_product AS "Product 1",
    second_product AS "Product 2",
    order_count AS "Times Ordered Together"
FROM
    bundled_order
ORDER BY
    order_count DESC
LIMIT
    10;

-- Q5: Which products are underperforming, and how can inventory and supply chain decisions be optimized?

WITH
    sales_data AS (
        SELECT
            product_id,
            SUM(unit_price * quantity * (1 - discount)) AS total_revenue
        FROM
            order_details
        GROUP BY
            product_id
    ),
    inventory_data AS (
        SELECT
            product_id,
            product_name,
            units_in_stock
        FROM
            products -- or products table with inventory info
    )
SELECT
    inv.product_name AS "Product Name",
    inv.units_in_stock AS "Units in Stock",
    ROUND(sls.total_revenue, 2) AS "Total Revenue"
FROM
    inventory_data inv
    JOIN sales_data sls ON inv.product_id = sls.product_id
ORDER BY
    inv.units_in_stock DESC,
    total_revenue
LIMIT
    10;

-- Q6: What is the average order size across product categories, and which categories dominate bulk orders?

WITH
    category_order_size AS (
        SELECT
            odd.order_id,
            ctg.category_name,
            SUM(odd.quantity) AS quantity_per_order
        FROM
            order_details odd
            JOIN products pdt ON odd.product_id = pdt.product_id
            JOIN categories ctg ON ctg.category_id = pdt.category_id
        GROUP BY
            odd.order_id,
            ctg.category_name
    ),
    category_bulk_order AS (
        SELECT
            category_name,
            ROUND(AVG(quantity_per_order), 2) AS average_order_size,
            COUNT(
                CASE
                    WHEN quantity_per_order > 20 THEN 1
                    ELSE 0
                END
            ) AS bulk_order_count -- above 20 qty count as bulk order
        FROM
            category_order_size
        GROUP BY
            category_name
    )
SELECT
    category_name AS "Product Category",
    average_order_size AS "Average Order Size",
    bulk_order_count AS "Bulk Order Count"
FROM
    category_bulk_order
ORDER BY
    bulk_order_count DESC;

---------------------------------------------------
/*---------- CUSTOMER & ORDER BEHAVIOUR ----------*/
---------------------------------------------------

-- Q7: What is the average time gap between successive orders from the same customer?

WITH
    order_frequency AS (
        SELECT
            cst.company_name AS customer_name,
            odr.order_date,
            COALESCE(
                odr.order_date - LAG(odr.order_date) OVER (
                    PARTITION BY
                        cst.company_name
                    ORDER BY
                        odr.order_date
                ),
                0
            ) AS days_frequency
        FROM
            orders odr
            JOIN customers cst ON odr.customer_id = cst.customer_id
    )
SELECT
    customer_name AS "Customer Name",
    ROUND(AVG(days_frequency), 2) AS "AVG Order Day Frequency"
FROM
    order_frequency
GROUP BY
    customer_name
ORDER BY
    "AVG Order Day Frequency" DESC
LIMIT
    10;

-- Q8: Which customers have the longest relationships with the company, and what is their lifetime value?

WITH
    customer_relation AS (
        SELECT
            cst.company_name AS customer_name,
            MIN(odr.order_date) AS first_order,
            MAX(odr.order_date) AS recent_order,
            ROUND(
                SUM(
                    odd.unit_price * odd.quantity * (1 - odd.discount)
                ),
                2
            ) AS life_time_value
        FROM
            order_details odd
            JOIN orders odr ON odr.order_id = odd.order_id
            JOIN customers cst ON cst.customer_id = odr.customer_id
        GROUP BY
            customer_name
    )
SELECT
    customer_name AS "Customer Name",
    (recent_order - first_order) AS "Relation Period",
    life_time_value AS "Life Time Value"
FROM
    customer_relation
ORDER BY
    "Relation Period" DESC,
    "Life Time Value" DESC
LIMIT
    10;

-- Q9: Which shipping method is most cost-effective based on average order value and delivery frequency?

WITH
    order_total AS (
        SELECT
            odr.order_id,
            odr.ship_via AS shipper_id,
            CASE
                WHEN odr.shipped_date ISNULL THEN 0
                ELSE odr.shipped_date - odr.order_date
            END AS delivery_duration,
            odr.freight AS shipping_charges,
            SUM(
                odd.unit_price * odd.quantity * (1 - odd.discount)
            ) AS order_total
        FROM
            orders odr
            JOIN order_details odd ON odd.order_id = odr.order_id
        GROUP BY
            odr.order_id,
            odr.ship_via
    ),
    shippers_stats AS (
        SELECT
            spr.company_name AS shipping_company,
            COUNT(odt.order_id) AS delivery_frequency,
            ROUND(AVG(odt.delivery_duration), 2) AS delivery_duration,
            ROUND(AVG(odt.shipping_charges), 2) AS shipping_charges,
            ROUND(AVG(odt.order_total), 2) AS average_order_value,
            ROUND(AVG(odt.order_total) / COUNT(odt.order_id), 2) AS cost_effectiveness
        FROM
            shippers spr
            JOIN order_total odt ON odt.shipper_id = spr.shipper_id
        GROUP BY
            shipping_company
    )
SELECT
    shipping_company AS "Shipping Company",
    delivery_duration AS "Delivery Duration",
    shipping_charges AS "Shipping Charges",
    cost_effectiveness AS "Cost Effectiveness"
FROM
    shippers_stats;

------------------------------------------------
/*------- Employee & Sales Performence -------*/
------------------------------------------------

-- Q10: Which sales representatives generate the highest revenue, and how does their performance vary across different regions?

WITH
    employee_revenue AS (
        SELECT
            odr.employee_id,
            CONCAT(emp.first_name, ' ', emp.last_name) AS employee_name,
            rgn.region_description AS regions,
            ROUND(
                SUM(
                    odd.unit_price * odd.quantity * (1 - odd.discount)
                ),
                2
            ) AS net_revenue
        FROM
            order_details odd
            JOIN orders odr ON odr.order_id = odd.order_id
            JOIN employees emp ON odr.employee_id = emp.employee_id
            JOIN employee_territories etr ON etr.employee_id = emp.employee_id
            JOIN territories trt ON trt.territory_id = etr.territory_id
            JOIN region rgn ON rgn.region_id = trt.region_id
        WHERE
            emp.title = 'Sales Representative'
        GROUP BY
            odr.employee_id,
            employee_name,
            regions
    )
SELECT
    employee_name AS "Employee Name",
    regions AS "Regions",
    net_revenue AS "Net Revenue ($)",
    ROUND((net_revenue / SUM(net_revenue) OVER () * 100), 2) AS "Revenue Share (%)"
FROM
    employee_revenue
ORDER BY
    net_revenue DESC,
    regions;

-- Q11: Which employees are responsible for managing the most valuable customers according to order value?

WITH
    customer_order_total AS (
        SELECT
            odr.customer_id,
            SUM(
                odd.unit_price * odd.quantity * (1 - odd.discount)
            ) AS total_customer_value
        FROM
            order_details odd
            JOIN orders odr ON odr.order_id = odd.order_id
        GROUP BY
            odr.customer_id
    ),
    high_value_customer AS (
        SELECT
            customer_id,
            total_customer_value
        FROM
            customer_order_total
        WHERE
            total_customer_value >= (
                SELECT
                    PERCENTILE_CONT(0.75) WITHIN GROUP (
                        ORDER BY
                            total_customer_value
                    )
                FROM
                    customer_order_total
            ) -- top 25% in order value
    ),
    employee_high_value_customers AS (
        SELECT
            emp.employee_id,
            CONCAT(emp.first_name, ' ', emp.last_name) AS employee_name,
            COUNT(DISTINCT hvc.customer_id) AS high_value_customer_count
        FROM
            high_value_customer hvc
            JOIN orders odr ON odr.customer_id = hvc.customer_id
            JOIN employees emp ON emp.employee_id = odr.employee_id
        GROUP BY
            emp.employee_id,
            employee_name
    )
SELECT
    employee_name AS "Employee Name",
    high_value_customer_count AS "High Value Customer Count"
FROM
    employee_high_value_customers
ORDER BY
    high_value_customer_count DESC;

--------------------------------------------------
/*---------- OPERATIONAL EFFICIENCY ------------*/
--------------------------------------------------

-- Q12: Do customer orders exhibit seasonal fluctuations, such as increased activity in certain quarters?

WITH
    quarterly_revenue AS (
        SELECT
            EXTRACT(
                YEAR
                FROM
                    odr.order_date
            ) AS order_year,
            EXTRACT(
                QUARTER
                FROM
                    odr.order_date
            ) AS order_qtr,
            SUM(
                odd.unit_price * odd.quantity * (1 - odd.discount)
            ) AS customer_orders
        FROM
            orders odr
            JOIN order_details odd ON (odd.order_id = odr.order_id)
        GROUP BY
            order_year,
            order_qtr
    )
SELECT
    order_year AS "Order Year",
    order_qtr AS "Order Qtr",
    ROUND(AVG(customer_orders), 2) AS "AVG Qtr Revenue"
FROM
    quarterly_revenue
GROUP BY
    order_year,
    order_qtr
ORDER BY
    order_year,
    order_qtr;

-- Q13: Which product categories show the highest return on investment when comparing cost vs. sales revenue?

WITH
    categories_cost_revenue AS (
        SELECT
            ctg.category_id,
            ctg.category_name,
            SUM(odd.quantity * prd.unit_price) AS total_cost,
            ROUND(
                SUM(
                    odd.unit_price * odd.quantity * (1 - odd.discount)
                ),
                2
            ) AS net_revenue
        FROM
            order_details odd
            JOIN products prd ON prd.product_id = odd.product_id
            JOIN categories ctg ON ctg.category_id = prd.category_id
        GROUP BY
            ctg.category_id,
            ctg.category_name
    )
SELECT
    category_name AS "Product Category",
    ROUND(
        ((net_revenue - total_cost) / total_cost) * 100,
        2
    ) AS "Category ROI"
FROM
    categories_cost_revenue
ORDER BY
    "Category ROI" DESC;