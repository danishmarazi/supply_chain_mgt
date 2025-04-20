-- 1.	Top-selling product types or SKUs.
SELECT 
    SKU, SUM(number_of_products_sold) AS total_sales
FROM
    supply
GROUP BY SKU
ORDER BY total_sales DESC;

-- 2.	Location-wise Revenue 
SELECT 
    location, SUM(revenue_generated) AS total_revenue
FROM
    supply
GROUP BY location
ORDER BY total_revenue DESC;

-- 3.	Top Product Types by Revenue Generated 
SELECT 
  * 
FROM 
  (
    SELECT 
      RANK() OVER (
        PARTITION BY product_type 
        ORDER BY 
          SUM(revenue_generated) DESC
      ) AS sales_rank, 
      product_type, 
      sku, 
      SUM(revenue_generated) AS total_revenue 
    FROM 
      supply 
    GROUP BY 
      sku, 
      product_type 
    ORDER BY 
      sales_rank DESC
  ) AS fist_supply 
WHERE 
  sales_rank = 1 
ORDER BY 
  total_revenue DESC;

-- 4.	Products with low sales but high production volumes.
SELECT
    SKU,
    product_type,
    number_of_products_sold,
    production_volumes,
    (production_volumes - number_of_products_sold) AS overproduction_gap
FROM
    supply
WHERE
    number_of_products_sold < (production_volumes * 0.5)
ORDER BY
    overproduction_gap DESC;

-- 5.	Products with unusually high manufacturing or shipping costs 
SELECT
    SKU,
    product_type,
    manufacturing_costs
FROM
    supply
WHERE
    manufacturing_costs > (
        SELECT AVG(manufacturing_costs) + STDDEV(manufacturing_costs)
        FROM supply
    )
ORDER BY
    manufacturing_costs DESC;

-- 6.	Products with low revenue per unit sold
SELECT 
    SKU,
    product_type,
    revenue_generated,
    number_of_products_sold,
    (revenue_generated / number_of_products_sold) AS revenue_per_unit
FROM 
    supply
WHERE 
    (revenue_generated / number_of_products_sold) < 10  -- adjust threshold as needed
ORDER BY 
    revenue_per_unit ASC;

-- 7.	Average manufacturing lead-time vs. shipping lead time by location or supplier
SELECT 
    Location,
    AVG(manufacturing_lead_time) AS avg_manufacturing_lead_time,
    AVG(shipping_lead_time) AS avg_shipping_lead_time
FROM 
    supply
GROUP BY 
    Location
ORDER BY 
    Location;

-- 8.	Identify SKUs with long total supply chain time 
SELECT 
    SKU,
    product_type,
    manufacturing_lead_time,
    shipping_lead_time,
    stock_lead_times,
    (manufacturing_lead_time + shipping_lead_time + stock_lead_times) AS total_supply_chain_time
FROM 
    supply
ORDER BY 
    total_supply_chain_time DESC;

-- 9.	Transportation mode vs. defect rate 
SELECT 
    transportation_modes,
    ROUND(AVG(defect_rates), 2) AS avg_defect_rate,
    COUNT(*) AS num_shipments
FROM
    supply
GROUP BY transportation_modes
ORDER BY avg_defect_rate DESC;

-- 10.	Stock Levels vs. Sales: 
SELECT 
    SKU,
    product_type,
    stock_levels,
    number_of_products_sold,
    ROUND((stock_levels / number_of_products_sold),
            2) AS stock_to_sales_ratio
FROM
    supply
ORDER BY stock_to_sales_ratio DESC;

-- 11.	Sales performance across customer demographics (e.g., Male, Female, Non-binary).
SELECT 
    customer_demographics,
    COUNT(*) AS total_orders,
    SUM(number_of_products_sold)AS total_units_sold,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(AVG(revenue_generated), 2) AS avg_revenue_per_order
FROM
    supply
GROUP BY customer_demographics
ORDER BY total_revenue DESC; 

-- 12.	Are there specific product types preferred by different customer groups?
SELECT 
    customer_demographics,
    product_type,
    SUM(number_of_products_sold) AS total_units_sold,
    COUNT(*) AS total_orders,
    SUM(revenue_generated) AS total_revenue
FROM
    supply
GROUP BY customer_demographics , product_type
ORDER BY customer_demographics , total_units_sold DESC; 

-- 13.	Compare average shipping time and cost across different cities 
SELECT 
    Location AS city,
    AVG(shipping_times) AS avg_shipping_time,
    AVG(shipping_costs) AS avg_shipping_cost,
    COUNT(*) AS total_shipments
FROM 
    supply
GROUP BY 
    Location
ORDER BY 
    avg_shipping_time ASC;

-- 14.	Products with high availability but low sales
SELECT 
    SKU,
    product_type,
    Availability,
    number_of_products_sold,
    revenue_generated
FROM
    supply
WHERE
    Availability > 50
        AND number_of_products_sold < 50
ORDER BY Availability DESC , number_of_products_sold ASC;

-- 15.	Products with low availability but high sales
SELECT 
    SKU,
    product_type,
    Availability,
    number_of_products_sold,
    revenue_generated
FROM
    supply
WHERE
    Availability < 50
        AND number_of_products_sold > 100
ORDER BY Availability DESC , number_of_products_sold ASC;
