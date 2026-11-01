-- Customer Shopping Behavior Analysis (PostgreSQL)
-- Run after the notebook loads the cleaned dataframe to public.customer.

-- Q1. Total revenue and purchase count by gender.
SELECT gender, COUNT(*) AS purchase_count, SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY gender
ORDER BY gender;

-- Q2. Customers with at least one discount purchase whose discounted-row spend
-- exceeds the overall average transaction amount.
SELECT customer_id, SUM(purchase_amount) AS discounted_spend
FROM customer
WHERE discount_applied = 'Yes'
GROUP BY customer_id
HAVING SUM(purchase_amount) > (SELECT AVG(purchase_amount) FROM customer)
ORDER BY discounted_spend DESC;

-- Q3. Five products with the highest average review rating (ignore null ratings).
SELECT item_purchased, ROUND(AVG(review_rating)::numeric, 2) AS avg_rating,
       COUNT(review_rating) AS rated_purchase_count
FROM customer
GROUP BY item_purchased
ORDER BY avg_rating DESC, rated_purchase_count DESC
LIMIT 5;

-- Q4. Compare average purchase amount for Standard and Express shipping.
SELECT shipping_type, ROUND(AVG(purchase_amount)::numeric, 2) AS avg_purchase_amount,
       COUNT(*) AS purchase_count
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type
ORDER BY shipping_type;

-- Q5. Average spend and revenue by subscription status.
SELECT subscription_status, ROUND(AVG(purchase_amount)::numeric, 2) AS avg_purchase_amount,
       SUM(purchase_amount) AS total_revenue, COUNT(*) AS purchase_count
FROM customer
GROUP BY subscription_status
ORDER BY subscription_status;

-- Q6. Five products with the highest share of purchases using a discount.
SELECT item_purchased,
       ROUND(100.0 * COUNT(*) FILTER (WHERE discount_applied = 'Yes') / COUNT(*), 2)
           AS discounted_purchase_pct,
       COUNT(*) AS purchase_count
FROM customer
GROUP BY item_purchased
ORDER BY discounted_purchase_pct DESC, purchase_count DESC
LIMIT 5;

-- Q7. Customer history segments using stated illustrative thresholds.
WITH customer_segments AS (
    SELECT customer_id,
           CASE WHEN MAX(previous_purchases) <= 10 THEN 'New'
                WHEN MAX(previous_purchases) <= 30 THEN 'Returning'
                ELSE 'Loyal' END AS segment
    FROM customer
    GROUP BY customer_id
)
SELECT segment, COUNT(*) AS customer_count
FROM customer_segments
GROUP BY segment
ORDER BY CASE segment WHEN 'New' THEN 1 WHEN 'Returning' THEN 2 ELSE 3 END;

-- Q8. Three most frequently purchased products within each category.
WITH product_counts AS (
    SELECT category, item_purchased, COUNT(*) AS purchase_count,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS product_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT category, item_purchased, purchase_count, product_rank
FROM product_counts
WHERE product_rank <= 3
ORDER BY category, product_rank, item_purchased;

-- Q9. Subscription rate among repeat buyers (>5 previous purchases), compared
-- with customers at or below the threshold. Each customer is counted once.
WITH customer_level AS (
    SELECT customer_id,
           MAX(previous_purchases) AS previous_purchases,
           BOOL_OR(subscription_status = 'Yes') AS subscribed
    FROM customer
    GROUP BY customer_id
)
SELECT CASE WHEN previous_purchases > 5 THEN 'Repeat buyer (>5)'
            ELSE 'Not repeat buyer (<=5)' END AS buyer_group,
       COUNT(*) AS customer_count,
       COUNT(*) FILTER (WHERE subscribed) AS subscribed_customers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE subscribed) / COUNT(*), 2) AS subscription_rate_pct
FROM customer_level
GROUP BY buyer_group
ORDER BY buyer_group;

-- Q10. Revenue and share of total revenue by fixed age bands.
WITH age_revenue AS (
    SELECT CASE WHEN age BETWEEN 18 AND 29 THEN '18-29'
                WHEN age BETWEEN 30 AND 44 THEN '30-44'
                WHEN age BETWEEN 45 AND 59 THEN '45-59'
                ELSE '60+' END AS age_group,
           SUM(purchase_amount) AS revenue
    FROM customer
    GROUP BY 1
)
SELECT age_group, revenue,
       ROUND(100.0 * revenue / NULLIF(SUM(revenue) OVER (), 0), 2) AS revenue_share_pct
FROM age_revenue
ORDER BY CASE age_group WHEN '18-29' THEN 1 WHEN '30-44' THEN 2 WHEN '45-59' THEN 3 ELSE 4 END;
