/*--------------------------------------------------------------
  Q2 – Transaction-Frequency Analysis
----------------------------------------------------------------*/

WITH cust_txn AS (          -- raw counts per customer per month
    SELECT
        sa.owner_id,
        DATE_FORMAT(sa.transaction_date, '%Y-%m')  AS ym,
        COUNT(*) AS txns_in_month
    FROM savings_savingsaccount sa
    WHERE sa.transaction_status = 'SUCCESS'      
    GROUP BY sa.owner_id, ym
),
avg_txn AS (                -- average monthly volume per customer
    SELECT
        owner_id,
        AVG(txns_in_month) AS avg_txn_per_month
    FROM   cust_txn
    GROUP  BY owner_id
),
banded AS (                 -- bucket customers into frequency categories
    SELECT
        CASE
            WHEN avg_txn_per_month >= 10 THEN 'High Frequency'
            WHEN avg_txn_per_month >= 3  THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_txn_per_month
    FROM avg_txn
)

SELECT
    frequency_category,
    COUNT(*)                                   AS customer_count,
    ROUND(AVG(avg_txn_per_month), 1)           AS avg_transactions_per_month
FROM banded
GROUP BY frequency_category
ORDER BY FIELD(frequency_category,
               'High Frequency',
               'Medium Frequency',
               'Low Frequency');            