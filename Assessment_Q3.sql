/*-------------------------------------------------------------
  Q3 – Account-Inactivity Alert
---------------------------------------------------------------*/

WITH last_txn AS (                              -- 1️⃣  last inflow per plan
    SELECT
        sa.plan_id,
        MAX(sa.transaction_date) AS last_transaction_date
    FROM   savings_savingsaccount sa
    WHERE  sa.confirmed_amount   > 0            -- inflow only
      AND  sa.transaction_status = 'SUCCESS'    -- keep valid transactions
    GROUP  BY sa.plan_id
),

active_plans AS (                               -- 2️⃣  only active plans
    SELECT
        p.id          AS plan_id,
        p.owner_id,
        CASE
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund          = 1 THEN 'Investment'
            ELSE 'Other'
        END              AS type,
        lt.last_transaction_date
    FROM  plans_plan p
    LEFT JOIN last_txn lt ON lt.plan_id = p.id
    WHERE p.status_id      = 1                 -- status “active”—adjust if needed
)

SELECT
    plan_id,
    owner_id,
    type,
    DATE(last_transaction_date) AS last_transaction_date,
    DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days  
FROM active_plans
WHERE last_transaction_date IS NULL                     -- never funded
   OR last_transaction_date <= CURDATE() - INTERVAL 365 DAY
ORDER BY
    last_transaction_date IS NULL ASC,   -- NULLs first (true=1, false=0)
    inactivity_days DESC;                 -- then longest inactivity
