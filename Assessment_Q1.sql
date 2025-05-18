/*-----------------------------------------------------------
  Q1 – Customers with ≥1 funded savings plan AND ≥1 funded
       investment plan, ordered by total deposits
-----------------------------------------------------------*/

WITH savings AS (
    SELECT
        p.owner_id,
        COUNT(DISTINCT p.id)                       AS savings_count,
        SUM(sa.confirmed_amount) / 100.0           AS savings_deposits_naira
    FROM   plans_plan            p
    JOIN   savings_savingsaccount sa
           ON sa.plan_id = p.id
    WHERE  p.is_regular_savings = 1               -- savings plans
      AND  sa.confirmed_amount > 0                -- funded
    GROUP  BY p.owner_id
), investment AS (
    SELECT
        p.owner_id,
        COUNT(DISTINCT p.id)                       AS investment_count,
        SUM(sa.confirmed_amount) / 100.0           AS investment_deposits_naira
    FROM   plans_plan            p
    JOIN   savings_savingsaccount sa
           ON sa.plan_id = p.id
    WHERE  p.is_a_fund = 1                        -- investment plans
      AND  sa.confirmed_amount > 0
    GROUP  BY p.owner_id
)
SELECT
    s.owner_id AS owner_id,
	CONCAT_WS(' ', u.first_name, u.last_name)                    AS name,
    s.savings_count,
    i.investment_count,
    ROUND(s.savings_deposits_naira
        + i.investment_deposits_naira, 2)         AS total_deposits
FROM        savings      s
INNER JOIN  investment   i ON i.owner_id = s.owner_id     -- must have both
INNER JOIN  users_customuser u ON u.id = s.owner_id
ORDER BY     total_deposits DESC;
