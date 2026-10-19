-- 02_analysis.sql
-- Analysis queries for the e-commerce packaging waste survey (Pune and Delhi)
-- Run 01_create_and_load.sql first. Table: respondents (113 rows).
-- two_city = 1 keeps Maharashtra and Delhi only (drops "Other").
-- pay_yes, premium_n etc. are NULL where the answer was "Not sure".

-- Q1. What share of each city would definitely pay Rs 5-20 extra for eco-friendly packaging?
SELECT residence,
       COUNT(*) AS n,
       ROUND(100.0 * SUM(pay_yes) / COUNT(pay_yes), 1) AS pct_definitely_pay
FROM respondents
WHERE two_city = 1
GROUP BY residence;

-- Q2. Full breakdown of the pay-extra answers by city
SELECT residence, pay_premium, COUNT(*) AS n,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY residence), 1) AS pct
FROM respondents
WHERE two_city = 1
GROUP BY residence, pay_premium
ORDER BY residence, n DESC;

-- Q3. What matters most when choosing a platform? (1 = most important, so lower = more important)
SELECT residence,
       ROUND(AVG(rk_price), 2)     AS price,
       ROUND(AVG(rk_speed), 2)     AS speed,
       ROUND(AVG(rk_quality), 2)   AS quality,
       ROUND(AVG(rk_packaging), 2) AS packaging,
       ROUND(AVG(rk_returns), 2)   AS returns
FROM respondents
WHERE two_city = 1
GROUP BY residence;

-- Q4. Do people who order more notice more excess packaging? (score 0 = never ... 4 = always)
SELECT orders, COUNT(*) AS n, ROUND(AVG(excess_n), 2) AS avg_excess_score
FROM respondents
GROUP BY orders
ORDER BY CASE orders WHEN '1-3' THEN 1 WHEN '4-6' THEN 2 WHEN '7-10' THEN 3 ELSE 4 END;

-- Q5. Awareness of eco-packaging options by age group
SELECT age_group, COUNT(*) AS n,
       ROUND(100.0 * SUM(CASE WHEN opted_n = 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_not_aware
FROM respondents
GROUP BY age_group
ORDER BY age_group;

-- Q6. Which policies are most popular, by city? (respondents could pick up to two)
SELECT residence,
       SUM(pol_plasticlimit) AS plastic_limits,
       SUM(pol_reuse)        AS return_reuse,
       SUM(pol_taxbreak)     AS tax_incentives,
       SUM(pol_community)    AS community_recycling,
       SUM(pol_activism)     AS activism
FROM respondents
WHERE two_city = 1
GROUP BY residence;

-- Q7. What do people do with packaging, by city?
SELECT residence, disposal, COUNT(*) AS n
FROM respondents
WHERE two_city = 1
GROUP BY residence, disposal
ORDER BY residence, n DESC;

-- Q8. Do people who think companies are not doing enough also contact them?
SELECT cos_effort, contacted_co, COUNT(*) AS n
FROM respondents
GROUP BY cos_effort, contacted_co
ORDER BY cos_effort, n DESC;
