-----------------------------------------------------
/*----------- SALES & REVENUE INSIGHTS ------------*/
----------------------------------------------------- 
-- Q1: Which products generated the highest revenue over time, and what trends can be observed across categories?
WITH
    revenue_over_time AS (
        SELECT
            prd.product_name,
            ctg.category_name,
            EXTRACT(
                MONTH
                FROM
                    odr.order_date
            ) AS order_month,
            EXTRACT(
                YEAR
                FROM
                    odr.order_date
            ) AS order_year,
            SUM(
                (odd.unit_price * odd.quantity) - (odd.unit_price * odd.quantity) * odd.discount
            ) AS total_revenue
        FROM
            public.products prd
            JOIN order_details odd ON (odd.product_id = prd.product_id)
            JOIN categories ctg ON (prd.category_id = ctg.category_id)
            JOIN orders odr ON (odd.order_id = odr.order_id)
        GROUP BY
            prd.product_name,
            ctg.category_id,
            order_month,
            order_year
        ORDER BY
            order_year,
            order_month,
            total_revenue DESC
    )
SELECT
    product_name AS product,
    category_name AS product_category,
    order_year,
    order_month,
    ROUND(total_revenue, 2) AS total_revenue
FROM
    revenue_over_time
ORDER BY
    order_year,
    order_month,
    total_revenue DESC;

-- Q2: Who are the top 10 customers by total spending, and how much do they contribute to overall sales?
WITH
    customer_spending AS (
        SELECT
            cst.company_name as customers,
            SUM(
                (odd.quantity * odd.unit_price) - (odd.quantity * odd.unit_price) * odd.discount
            ) AS total_spending
        FROM
            customers cst
            JOIN orders odr ON (odr.customer_id = cst.customer_id)
            JOIN order_details odd ON (odd.order_id = odr.order_id)
        GROUP BY
            cst.company_name
    )
SELECT
    customers,
    ROUND(total_spending, 2) AS total_spending,
    ROUND(
        total_spending / SUM(total_spending) OVER () * 100,
        2
    ) AS spending_share
FROM
    customer_spending
ORDER BY
    total_spending DESC
LIMIT
    10;

-- Q3: Which regions or countries contribute the most to revenue, and how does their performance compare year-over-year?
WITH
    country_revenue AS (
        SELECT
            odr.ship_country AS countries,
            EXTRACT(
                YEAR
                FROM
                    odr.order_date
            ) AS order_year,
            ROUND(
                SUM(
                    (odd.unit_price * odd.quantity) - (odd.unit_price * odd.quantity) * odd.discount
                ),
                2
            ) AS total_revenue
        FROM
            order_details odd
            JOIN orders odr ON (odd.order_id = odr.order_id)
        GROUP BY
            countries,
            order_year
        ORDER BY
            order_year,
            total_revenue
    ),
    revenue_yoy AS (
        SELECT
            countries,
            SUM(
                CASE
                    WHEN order_year = 1996 THEN total_revenue
                    ELSE 0
                END
            ) AS revenue_1996,
            SUM(
                CASE
                    WHEN order_year = 1997 THEN total_revenue
                    ELSE 0
                END
            ) AS revenue_1997,
            SUM(
                CASE
                    WHEN order_year = 1998 THEN total_revenue
                    ELSE 0
                END
            ) AS revenue_1998
        FROM
            country_revenue
        GROUP BY
            countries
    )
SELECT
    countries,
    revenue_1996,
    revenue_1997,
    revenue_1998,
    CASE
        WHEN revenue_1996 = 0 THEN 0
        ELSE ROUND(
            (revenue_1997 - revenue_1996) / revenue_1996 * 100,
            2
        )
    END AS yoy_1997vs1996,
    CASE
        WHEN revenue_1997 = 0 THEN 0
        ELSE ROUND(
            (revenue_1998 - revenue_1997) / revenue_1997 * 100,
            2
        )
    END AS yoy_1998vs1997
FROM
    revenue_yoy
ORDER BY
    revenue_1996 DESC,
    revenue_1997 DESC,
    revenue_1998 DESC;

-- Q4: What percentage of revenue comes from repeat customers vs. new customers?
WITH
    first_order AS (
        SELECT
            customer_id,
            MIN(order_date) AS first_order_date
        FROM
            orders
        GROUP BY
            customer_id
    ),
    customer_revenue AS (
        SELECT
            odr.customer_id,
            SUM(
                (odd.unit_price * odd.quantity) - (odd.unit_price * odd.quantity) * odd.discount
            ) AS total_revenue,
            CASE
                WHEN odr.order_date = fod.first_order_date THEN 'New Customer'
                ELSE 'Repeat Customer'
            END AS customer_type
        FROM
            orders odr
            JOIN order_details odd ON (odd.order_id = odr.order_id)
            JOIN first_order fod ON (fod.customer_id = odr.customer_id)
        GROUP BY
            odr.customer_id,
            customer_type
    ),
    customer_type_revenue AS (
        SELECT
            customer_type,
            SUM(total_revenue) AS total_revenue
        FROM
            customer_revenue
        GROUP BY
            customer_type
    )
SELECT
    customer_type,
    total_revenue,
    ROUND(
        (total_revenue / SUM(total_revenue) OVER ()) * 100,
        2
    ) AS revenue_percentage
FROM
    customer_type_revenue;

---------------------------------------------------------
/*---------- PRODUCT & INVENTORY PERFORMENCE ----------*/
---------------------------------------------------------
-- Q5: Which pairs or groups of products tend to be bought together based on order data?
WITH
    first_products AS (
        SELECT
            odd.order_id,
            prd.product_name
        FROM
            order_details odd
            JOIN products prd ON (odd.product_id = prd.product_id)
    ),
    second_products AS (
        SELECT
            odd.order_id,
            prd.product_name
        FROM
            order_details odd
            JOIN products prd ON (odd.product_id = prd.product_id)
    )
SELECT
    fpd.product_name AS product_one,
    spd.product_name AS product_two,
    COUNT(*) AS times_order_together
FROM
    first_products fpd
    JOIN second_products spd ON fpd.order_id = spd.order_id
    AND fpd.product_name < spd.product_name
GROUP BY
    fpd.product_name,
    spd.product_name
ORDER BY
    times_order_together DESC
LIMIT
    10;

-- Q6: Which items show poor sales performance relative to their inventory quantity?
WITH
    sales_data AS (
        SELECT
            product_id,
            SUM(
                (unit_price * quantity) - (unit_price * quantity) * discount
            ) AS total_revenue
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
    inv.product_id,
    inv.product_name,
    inv.units_in_stock,
    sls.total_revenue
FROM
    inventory_data inv
    JOIN sales_data sls ON inv.product_id = sls.product_id
ORDER BY
    inv.units_in_stock DESC,
    total_revenue
LIMIT
    10;

-- Q7: What is the average order size across product categories, and which categories dominate bulk orders?
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
    category_name,
    average_order_size,
    bulk_order_count
FROM
    category_bulk_order
ORDER BY
    bulk_order_count DESC;

-- Q8: Which suppliers provide the most profitable products to the company?
WITH
    supplier_classified AS (
        SELECT
            spl.company_name AS supplier,
            ROUND(SUM(prd.unit_price * odd.quantity), 2) AS total_cost,
            ROUND(SUM(odd.unit_price * odd.quantity), 2) AS total_sales,
            ROUND(
                SUM((odd.unit_price * odd.quantity) * odd.discount),
                2
            ) AS discount_amount
        FROM
            order_details odd
            JOIN products prd ON (odd.product_id = prd.product_id)
            JOIN suppliers spl ON (spl.supplier_id = prd.supplier_id)
        GROUP BY
            spl.company_name
    )
SELECT
    supplier,
    ((total_sales - total_cost) - discount_amount) as net_profit
FROM
    supplier_classified
ORDER BY
    net_profit DESC
LIMIT
    10;

---------------------------------------------------
/*---------- CUSTOMER & ORDER BEHAVIOUR ----------*/
---------------------------------------------------
-- Q9: What is the average time gap between successive orders from the same customer?
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
    customer_name,
    ROUND(AVG(days_frequency), 2) AS avg_order_days_frequency
FROM
    order_frequency
GROUP BY
    customer_name
ORDER BY
    avg_order_days_frequency DESC
LIMIT
    10;

-- Q10: Which customers have the longest relationships with the company, and what is their lifetime value?
WITH
    customer_relation AS (
        SELECT
            cst.company_name AS customer,
            MIN(odr.order_date) AS first_order,
            MAX(odr.order_date) AS recent_order,
            SUM(odd.unit_price * odd.quantity) AS life_time_value
        FROM
            order_details odd
            JOIN orders odr ON odr.order_id = odd.order_id
            JOIN customers cst ON cst.customer_id = odr.customer_id
        GROUP BY
            customer
    )
SELECT
    customer,
    (recent_order - first_order) AS relation_period,
    life_time_value
FROM
    customer_relation
ORDER BY
    relation_period DESC,
    life_time_value DESC
LIMIT
    10;

-- Q11: Which shipping method is most cost-effective based on average order value and delivery frequency?
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
    shipping_company,
    delivery_duration,
    shipping_charges,
    cost_effectiveness
FROM
    shippers_stats;

------------------------------------------------
/*---------- OPERATIONAL EFFICIENCY ----------*/
------------------------------------------------
-- Q12 : Which sales representatives generate the highest revenue, and how does their performance vary across different regions?
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
    employee_name,
    regions,
    net_revenue,
    ROUND((net_revenue / SUM(net_revenue) OVER () * 100), 2) AS revenue_share
FROM
    employee_revenue
ORDER BY
    net_revenue DESC,
    regions;