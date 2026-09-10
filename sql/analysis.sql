-- ============================================================
-- Finland Electricity Price Analysis — Analysis Queries
-- ============================================================
-- Structure:
-- Chapter 1: Setting the scene (2 queries) — pre-crisis baseline
-- Chapter 2: The crisis (3 queries) — 2022 shock and Finland-specific factors
-- Chapter 3: The recovery — OL3 natural experiment (3 queries)
-- Chapter 4: New normal (2 queries) — before/after comparison
-- ============================================================


-- ============================================================
-- CHAPTER 1: SETTING THE SCENE
-- Establishing the pre-crisis baseline (2018-2021)
-- ============================================================

-- Q1: Average annual price Finland vs Germany vs Sweden 2018-2021
-- Question: What did normal electricity prices look like before the crisis?
-- Expected outcome: Relatively stable, low prices across all three countries

--      
    SELECT 
        EXTRACT (YEAR FROM fp.timestamp) AS year,
        ROUND(AVG(fp.price_eur_mwh), 2) AS finland_avg_price,
        ROUND(AVG(gp.price_eur_mwh), 2) AS germany_avg_price,
        ROUND(AVG(sp.price_eur_mwh), 2) AS sweden_avg_price
    FROM finland_price fp
    LEFT JOIN germany_price gp ON fp.timestamp = gp.timestamp
    LEFT JOIN sweden_price sp ON fp.timestamp = sp.timestamp
    WHERE EXTRACT(YEAR FROM fp.timestamp) BETWEEN 2018 AND 2021
    GROUP BY year
    ORDER BY year;

-- Answer/Analysis:
    -- Pre-crisis baseline (2018-2020): prices stable and low across all three countries (28-47 EUR/MWh)
    -- Finland and Sweden tracked closely, Germany slightly higher due to greater gas dependence
    -- 2021 already shows early crisis signs — all three jumped sharply before the war even started
    -- Germany hit 97 EUR/MWh in 2021 vs Finland's 72 — gas exposure already visible in the data


-- Q2: Average generation mix share by year 2018-2021
-- Question: What was Finland's energy source breakdown before the crisis?
-- Expected outcome: Nuclear dominant, some hydro, growing wind, low fossil

-- 
    SELECT 
        EXTRACT(YEAR FROM timestamp) AS year,
        production_type,
        ROUND(AVG(generation_mw), 2) AS avg_generation_mw
    FROM finland_generation_mix 
    WHERE EXTRACT(YEAR FROM timestamp) BETWEEN 2018 AND 2021
    GROUP BY production_type, year
    HAVING ROUND(AVG(generation_mw), 2) > 0
    ORDER BY year;


-- Answer/Analysis:
    -- Nuclear dominates Finland's pre-crisis generation mix at ~2,500 MW average,
    -- roughly 2x hydro and 4x wind — establishes the baseline for the OL3 story in Chapter 3
    -- Fossil fuels (Gas, Hard Coal, Peat) were already declining 2018-2021,
    -- suggesting Finland was cleaning up its mix even before the crisis hit
    -- Wind Onshore grew nearly 50% from 615 MW (2018) to 902 MW (2021) — steady upward trend
    -- Hydro fluctuates year to year (1,306-1,649 MW) likely reflecting rainfall and snowmelt variation
    -- Nuclear stable at 2,500-2,600 MW throughout — this is the pre-OL3 baseline,
    -- any increase beyond this range in later chapters points directly to OL3's contribution


-- ============================================================
-- CHAPTER 2: THE CRISIS
-- The 2022 shock and Finland-specific factors
-- ============================================================

-- Q3: Monthly price Finland vs Germany vs Sweden 2021-2023
-- Question: How did prices move during the crisis, and did all three countries move together?
-- Expected outcome: Sharp spike in 2022, Finland and Germany diverge from Sweden at points
-- Key events: Feb 2022 (Russia-Ukraine war), May 2022 (Russia cuts Finnish electricity imports)

-- 


-- Answer/Analysis:
-- [fill in after running]


-- Q4: Finland vs Sweden price spread by month 2021-2023
-- Question: Did Finland's price diverge specifically from Sweden around May 2022?
-- Expected outcome: Positive spread (Finland more expensive than Sweden) peaking around mid-2022
-- Why this matters: divergence points to Finland-specific factors beyond the general European crisis

-- <query here>

-- Answer/Analysis:
-- [fill in after running]


-- Q5: Generation mix during crisis vs pre-crisis
-- Question: Did Finland's energy source breakdown shift during the 2022 crisis?
-- Expected outcome: Fossil share may have increased, nuclear/hydro relatively stable

-- <query here>

-- Answer/Analysis:
-- [fill in after running]


-- ============================================================
-- CHAPTER 3: THE RECOVERY — OL3 NATURAL EXPERIMENT
-- Did Finland's nuclear ramp-up explain the price recovery?
-- ============================================================

-- Q6: Nuclear generation share by quarter 2021-2024
-- Question: How did nuclear's share of Finland's generation mix change as OL3 came online?
-- Expected outcome: Clear step-change increase in nuclear share from 2022-2023 onward

-- <query here>

-- Answer/Analysis:
-- [fill in after running]


-- Q7: Monthly nuclear share vs average price 2021-2024
-- Question: Does higher nuclear share correlate with lower electricity prices?
-- Expected outcome: Negative correlation — as nuclear share rises, price tends to fall

-- <query here>

-- Answer/Analysis:
-- [fill in after running]


-- Q8: Wind-price correlation stratified by season
-- Question: Does wind generation correlate with lower prices, even after controlling for season?
-- Expected outcome: Negative correlation within each season — more wind means lower prices
-- Why stratify: wind and demand both vary seasonally, so pooled correlation could be misleading

-- <query here>

-- Answer/Analysis:
-- [fill in after running]


-- ============================================================
-- CHAPTER 4: NEW NORMAL
-- Where did prices settle after the crisis?
-- ============================================================

-- Q9: Annual price and generation mix 2018 vs 2023 vs 2024 vs 2025
-- Question: How do post-crisis prices and generation mix compare to the pre-crisis baseline?
-- Expected outcome: Prices lower than 2022 peak but pattern may differ from pre-crisis baseline

-- <query here>

-- Answer/Analysis:
-- [fill in after running]


-- Q10: Crisis period summary table
-- Question: What is the complete before/during/after picture across all key metrics?
-- Expected outcome: Clean summary showing price, nuclear share, wind share, Finland-Sweden spread
-- per crisis period — directly answers the core project question

-- <query here>

-- Answer/Analysis:
-- [fill in after running]