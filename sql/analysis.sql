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
    SELECT
        EXTRACT (YEAR FROM fp.timestamp) AS year,
        EXTRACT (MONTH FROM fp.timestamp) AS month,
        ROUND(AVG(fp.price_eur_mwh), 2) as finland_avg_price,
        ROUND(AVG(gp.price_eur_mwh), 2) as germany_avg_price,
        ROUND(AVG(sp.price_eur_mwh), 2) as sweden_avg_price
    FROM finland_price fp
    LEFT JOIN germany_price gp ON fp.timestamp = gp.timestamp
    LEFT JOIN sweden_price sp ON fp.timestamp = sp.timestamp
    WHERE EXTRACT(YEAR FROM fp.timestamp) BETWEEN 2021 AND 2023
    GROUP BY year, month
    ORDER BY year, month;

-- Answer/Analysis:
    -- All three markets show early warning signs well before the war: by Dec 2021, prices
    -- were already 3x their early-2021 levels (Finland 51→193, Germany 53→225, Sweden 48→157)

    -- FINLAND: peaked at 261.48 EUR/MWh in Aug 2022 — ~6x its 2018-2021 baseline avg (Q1: 28-47)
    -- Rise phase May-Aug 2022 (113.94 → 261.48), which lags the May 2022 Russian import cutoff
    -- by about 3 months rather than reacting immediately — points to a slower-building cause
    -- rather than a single-event shock

    -- GERMANY: longest and highest crisis of the three. Rise started earliest (Sep 2021) and
    -- peaked latest and highest (463.13 EUR/MWh, Aug 2022) — ~1.8x Finland's peak. Decline was
    -- also the slowest, still elevated through most of 2023 (avg ~90-100) vs Finland/Sweden
    -- dropping into the 30s-60s by mid-2023 — consistent with Germany's heavier gas dependence

    -- SWEDEN: peaked latest of all three (235.93 EUR/MWh, Dec 2022) but fell the fastest and
    -- furthest afterward, down to 22.27 EUR/MWh by Sep 2023 — the lowest point any country
    -- reached in this entire window, suggesting the fastest recovery of the three

    -- Recovery speed ranking: Sweden > Finland > Germany — this lines up with grid composition,
    -- not just crisis timing: Sweden and Finland lean nuclear/hydro, Germany leans more heavily
    -- on gas, which tracks with the "domestic supply mix matters" side of the core question

    -- Caveat: this query alone shows correlation in timing, not cause — it can't separate
    -- "Finland-specific factors" from "general European gas prices" driving Finland's move.
    -- Q4 (Finland-Sweden spread) is designed to isolate exactly that


-- Q4: Finland vs Sweden price spread by month 2021-2023
-- Question: Did Finland's price diverge specifically from Sweden around May 2022?
-- Expected outcome: Positive spread (Finland more expensive than Sweden) peaking around mid-2022
-- Why this matters: divergence points to Finland-specific factors beyond the general European crisis

-- 
    SELECT
        EXTRACT (YEAR FROM fp.timestamp) AS year,
        EXTRACT (MONTH FROM fp.timestamp) AS month,
        ROUND(AVG(fp.price_eur_mwh), 2) as finland_avg_price,
        ROUND(AVG(sp.price_eur_mwh), 2) as sweden_avg_price,
        ROUND(
                AVG(fp.price_eur_mwh) - AVG(sp.price_eur_mwh),2
        ) AS price_spread
    FROM finland_price fp
    LEFT JOIN sweden_price sp ON fp.timestamp = sp.timestamp
    WHERE EXTRACT(YEAR FROM fp.timestamp) BETWEEN 2021 AND 2023
    GROUP BY year, month
    ORDER BY year, month;

-- Answer/Analysis:

    -- 2021: spread small and steady (0.02-36.50), Finland and Sweden moved together
    -- Mar 2022 (2 months before cutoff): spread goes NEGATIVE (-22.15) — Sweden pricier than Finland
    -- Jul 2022 (2 months after cutoff): spread peaks at 108.97 — larger than an entire pre-crisis
    -- month's price (Q1 baseline: 28-47 EUR/MWh)
    -- 2023: spread collapses, turns negative 3 times (Jan, Apr, May), settles at 6.79 by Dec —
    -- close to 2021 levels, showing the divergence was temporary, not permanent

    -- Cross-check with Q3: two similar Nordic grids (Finland/Sweden) diverging this sharply from
    -- EACH OTHER is stronger evidence of a Finland-specific shock than general European conditions

    -- Caveat: timing lines up with the May 2022 cutoff but doesn't prove cause — weather or
    -- demand swings could also explain part of the gap


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