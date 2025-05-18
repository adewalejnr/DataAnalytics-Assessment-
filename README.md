# DataAnalytics-Assessment  
**Author:** *Nurudeen Abiodun Babalola*

---

## Question-by-Question Discussion  

### Q1 – Cross-Selling: Customers with Both Funded Savings and Investment Plans  

**What I did**  
1. Wrote two common-table expressions (CTEs) to separately summarise funded **savings** and **investment** plans.  
   * Savings plans were identified with `is_regular_savings = 1`; investments with `is_a_fund = 1`.  
   * Only transactions with a positive `confirmed_amount` were counted, ensuring plans were genuinely funded.  
2. Joined the two CTEs on `owner_id`; this intersection yields customers who hold at least one of each product.  
3. Aggregated deposits (converted from kobo to Naira) and ordered the result by total deposits in descending order.  

**Why**  
The business wants a target list for cross-selling. Customers already active in both products are the highest-value cohort and are ranked by their historical deposit volume.

---

### Q2 – Transaction Frequency Analysis  

**What I did**  
1. Collapsed every successful savings transaction (`transaction_status = 'SUCCESS'`) into monthly buckets (`YYYY-MM`) to obtain *transactions-per-customer-per-month*.  
2. Calculated each customer’s **average monthly transaction count** across their entire activity window.  
3. Classified customers into “High (≥10)”, “Medium (3-9)”, or “Low (≤2)” frequency bands with a `CASE` expression.  
4. Produced the final summary showing the number of customers in each band and the band-level average transaction frequency.  
5. Used `FIELD()` in the `ORDER BY` clause to force the logical display order High → Medium → Low.

**Why**  
Marketing can segment customers by engagement intensity, informing differentiated messaging and product nudges.

---

### Q3 – Account Inactivity Alert  

**What I did**  
1. Identified the **last successful inflow date** for every plan via a `MAX(transaction_date)` aggregation (restricted to `confirmed_amount > 0`).  
2. Selected only *active* plans (`status_id = 1`) from `plans_plan`, tagging each as “Savings” or “Investment” based on the hint flags.  
3. Flagged plans that **never received a deposit** (*NULL* last date) or that have been idle for > 365 days.  
4. Calculated `inactivity_days` with `DATEDIFF(CURDATE(), last_transaction_date)` and presented the results sorted with the stalest accounts at the bottom (NULLs last, then longest gap).  

**Why**  
Operations can now prioritise outreach to dormant account holders to re-activate funds or close stagnant products.

---

### Q4 – Customer Lifetime Value (CLV) Estimation  

**What I did**  
1. Computed the customer’s tenure in months from `date_joined` to the current date using `TIMESTAMPDIFF`.  
2. Counted total transactions and averaged the monetary value of those transactions (converted to Naira).  
3. Applied the simplified formula  
   \[
      \text{CLV} = \bigl(\frac{\text{total transactions}}{\text{tenure months}}\bigr)
                   \times 12 \times (\text{avg transaction value} \times 0.001)
   \]  
   The 0.001 multiplier implements the 0.1 % profit assumption.  
4. Protected against zero-month tenure with `NULLIF`, rounded the result to two decimals, and listed customers from highest to lowest CLV.

**Why**  
This approximation surfaces customers whose behaviour drives disproportionate lifetime profit, helping marketing refine retention spend.

---

## Challenges Encountered and Resolutions  

| Challenge | Resolution |
|-----------|------------|
| **Unit conversion** – All monetary values were stored in kobo, risking inflated metrics. | I divided by 100 wherever monetary aggregates were required. |
| **Plan typing** – Savings vs. investment products reside in the same table. | I followed the hint flags: `is_regular_savings` and `is_a_fund` to isolate plan categories. |
| **NULL handling** – Some plans had no transactions; some customers had zero tenure months. | I used `LEFT JOIN` plus `NULLIF` and conditional filters to avoid divide-by-zero errors and to keep dormant entities visible. |
| **Ordering NULLs last in MySQL** (no `NULLS LAST` keyword). | I added boolean expressions in `ORDER BY` to push NULL values to the end of result sets. |

---
  

