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
    SELECT
        production_type,
        ROUND(AVG(generation_mw) FILTER (
            WHERE EXTRACT(YEAR FROM timestamp) BETWEEN 2018 AND 2021
        ), 2) AS pre_crisis_avg_mw,
        ROUND(AVG(generation_mw) FILTER (
            WHERE EXTRACT(YEAR FROM timestamp) BETWEEN 2022 AND 2023
        ), 2) AS crisis_avg_mw
    FROM finland_generation_mix
    WHERE EXTRACT(YEAR FROM timestamp) BETWEEN 2018 AND 2023
    GROUP BY production_type
    HAVING ROUND(AVG(generation_mw), 2) > 0
    ORDER BY production_type;


-- Answer/Analysis:

-- Nuclear: 2558.52 to 3240.45 MW (~27% increase) — biggest absolute gain, tracks with OL3
-- Wind Onshore: 746.78 to 1433.44 MW (~92% increase) — fastest proportional growth
-- Hydro roughly flat (1506.59 to 1524.44) — stable baseline, not a crisis response
-- Solar not comparable — reporting only begins 2023, pre-crisis 0.00 isn't real data

-- Contrary to the query's expected outcome, all fossil sources DECREASED during the crisis:
-- Gas (-60%), Hard Coal (-33%), Peat (-18%)

-- Key finding: Finland leaned on nuclear + wind during the crisis, not fossil backup —
-- early evidence for the "domestic supply mix" side of the core project question


-- ============================================================
-- CHAPTER 3: THE RECOVERY — OL3 NATURAL EXPERIMENT
-- Did Finland's nuclear ramp-up explain the price recovery?
-- ============================================================

-- Q6: Nuclear generation share by quarter 2021-2024
-- Question: How did nuclear's share of Finland's generation mix change as OL3 came online?
-- Expected outcome: Clear step-change increase in nuclear share from 2022-2023 onward

-- <query here>

    WITH generation_with_totals AS (
        SELECT
            production_type,
            timestamp,
            EXTRACT(YEAR FROM timestamp) AS year,
            EXTRACT(QUARTER FROM timestamp) AS quarter,
            generation_mw,
            SUM(generation_mw) OVER (PARTITION BY timestamp) AS hourly_total_mw
        FROM finland_generation_mix
        WHERE EXTRACT(YEAR FROM timestamp) BETWEEN 2021 AND 2024
    )
    SELECT
        year,
        quarter,
        ROUND(AVG(generation_mw), 2) AS nuclear_avg_mw,
        ROUND(AVG(hourly_total_mw), 2) AS avg_hourly_total_mw,
        ROUND(AVG(generation_mw) / AVG(hourly_total_mw) * 100, 2) AS nuclear_share_pct
    FROM generation_with_totals
    WHERE production_type = 'Nuclear'
    GROUP BY year, quarter
    ORDER BY year, quarter;

-- Answer/Analysis:

    -- Nuclear share steady in 32-44% range from Q1 2021 to Q1 2023
    -- Clear step-change from Q2 2023: jumps to 48.61%, then 49.81% Q3 2023 — right when
    -- OL3 entered regular commercial operation (Apr 2023)
    -- Confirmed real, not just a ratio effect: nuclear_avg_mw itself rises too (3171→3881 MW)
    -- Share eases slightly through 2024 (37-45%) but stays above pre-2023 levels — OL3 now
    -- part of the baseline mix, not a temporary spike

    -- Key finding: clearest evidence yet for the "domestic supply" side of the core question —
    -- a specific, dateable jump tied directly to OL3, distinct from general crisis timing


-- Q7: Monthly nuclear share vs average price 2021-2024
-- Question: Does higher nuclear share correlate with lower electricity prices?
-- Expected outcome: Negative correlation — as nuclear share rises, price tends to fall

-- <query here>

    WITH generation_with_totals AS (
        SELECT
            gm.production_type,
            gm.timestamp,
            EXTRACT(YEAR FROM gm.timestamp) AS year,
            EXTRACT(MONTH FROM gm.timestamp) AS month,
            gm.generation_mw,
            SUM(gm.generation_mw) OVER (PARTITION BY gm.timestamp) AS hourly_total_mw,
            fp.price_eur_mwh
        FROM finland_generation_mix gm
        LEFT JOIN finland_price fp ON gm.timestamp = fp.timestamp
        WHERE EXTRACT(YEAR FROM gm.timestamp) BETWEEN 2021 AND 2024
    )
    SELECT
        year,
        month,
        ROUND(AVG(generation_mw), 2) AS nuclear_avg_mw,
        ROUND(AVG(hourly_total_mw), 2) AS avg_hourly_total_mw,
        ROUND(AVG(generation_mw) / AVG(hourly_total_mw) * 100, 2) AS nuclear_share_pct,
        ROUND(AVG(price_eur_mwh), 2) AS avg_price
    FROM generation_with_totals
    WHERE production_type = 'Nuclear'
    GROUP BY year, month
    ORDER BY year, month;

-- Answer/Analysis:
    -- 2021-2022: nuclear share stays in a normal 30-48% range both years, but price is wildly
    -- different (2021: 36-193, 2022: 79-261) — share doesn't explain 2022's extreme prices,
    -- confirms something external (gas crisis) was the real driver that year

    -- 2023 onward: share climbs above the old range, peaking at 60.54% (Jul 2023), price
    -- drops sharply in the same window (32.94) — negative correlation shows up clearly here

    -- 2024 strongest case: Jul-Aug high share (50-46%) paired with lowest prices in dataset
    -- (16.78, 12.53)

    -- Not clean throughout though — Jul 2021 has high share (47.99%) AND high price (78.74),
    -- opposite of expected, showing link is inconsistent before OL3

    -- Key finding: negative correlation is real but only clear from 2023 onward, once OL3
    -- pushed nuclear share meaningfully higher — in 2021-2022 price was driven by something
    -- else entirely (external gas crisis), not nuclear share


-- Q8: Wind-price correlation stratified by season
-- Question: Does wind generation correlate with lower prices, even after controlling for season?
-- Expected outcome: Negative correlation within each season — more wind means lower prices
-- Why stratify: wind and demand both vary seasonally, so pooled correlation could be misleading

-- <query here>

    SELECT
        CASE
            WHEN EXTRACT(MONTH FROM gm.timestamp) IN(12,1, 2) THEN 'Winter'
            WHEN EXTRACT(MONTH FROM gm.timestamp) IN (3,4,5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM gm.timestamp) IN (6,7,8) THEN 'Summer'
            ELSE 'Autumn'
            END AS season,
        ROUND(AVG( gm.generation_mw), 2) AS avg_wind_mw,
        ROUND(AVG(fp.price_eur_mwh),2) AS avg_price
    FROM finland_generation_mix gm
    LEFT JOIN finland_price fp ON gm.timestamp = fp.timestamp
    WHERE gm.production_type = 'Wind Onshore'
    GROUP BY 
        CASE
            WHEN EXTRACT(MONTH FROM gm.timestamp) IN (12, 1, 2) THEN 'Winter'
            WHEN EXTRACT(MONTH FROM gm.timestamp) IN (3, 4, 5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM gm.timestamp) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Autumn'
        END
    ORDER BY avg_wind_mw DESC;

-- Answer/Analysis:

    -- Wind highest in Winter (1609 MW), lowest in Summer (811 MW) — roughly doubles winter vs summer

    -- Price does NOT follow "more wind = lower price": Winter has BOTH highest wind AND
    -- highest price (74.24) — opposite of expected

    -- Caveat: this shows seasonal averages only, not true within-season correlation — winter's
    -- high price likely driven by heating demand, not wind. A proper test would need CORR()
    -- or month-by-month variation within each season, not one pooled number per season

    -- Key finding: at this level, wind shows no negative relationship with price — demand
    -- appears to dominate wind's effect, contrary to the query's expected outcome


-- ============================================================
-- CHAPTER 4: NEW NORMAL
-- Where did prices settle after the crisis?
-- ============================================================

-- Q9: Annual price and generation mix 2018 vs 2023 vs 2024 vs 2025
-- Question: How do post-crisis prices and generation mix compare to the pre-crisis baseline?
-- Expected outcome: Prices lower than 2022 peak but pattern may differ from pre-crisis baseline

-- <query 1>
        SELECT 
            EXTRACT(YEAR FROM timestamp) AS year,
            ROUND(AVG(price_eur_mwh), 2) AS avg_price_mwh
        FROM finland_price
        WHERE EXTRACT(YEAR FROM timestamp) IN (2018, 2023, 2024, 2025)
        GROUP BY year
        ORDER BY year;
-- <query 2>

        SELECT 
            EXTRACT(YEAR FROM timestamp) AS year,
            production_type,
            ROUND(AVG(generation_mw),2) AS avg_generation_mw
        FROM finland_generation_mix
        WHERE EXTRACT(YEAR FROM timestamp) IN (2018, 2023, 2024, 2025)
        GROUP BY production_type, year
        HAVING ROUND(AVG(generation_mw),2) > 0
        ORDER BY production_type, year;

-- Answer/Analysis:

    -- Price (EUR/MWh): 2018 = 46.80, 2023 = 56.47, 2024 = 45.58, 2025 = 40.48
    -- 2023 still elevated by early-year crisis prices; 2024 is back to 2018 level,
    -- 2025 is below it

    -- Nuclear: 2498 MW (2018) to 3730 (2023), then plateau at ~3540-3570 (2024-2025)
    -- a one-time step up from OL3, not continued growth
    -- Wind Onshore: 615 to 1600 to 2215 to 2460 MW, about 4x since 2018 and still growing
    -- Fossil fell in every period: Gas 571 to 99, Hard coal 682 to 44, Peat 488 to 129 MW
    -- Hydro roughly flat (1369-1637 MW), varies with rainfall
    -- Solar only comparable from 2023 (97 to 149 MW), earlier zeros are a reporting gap

    -- Key finding: the new normal is a nuclear + wind mix with almost no fossil generation,
    -- and prices are at or below the pre-crisis level. Consistent with the domestic supply
    -- explanation, but not proof, since European gas prices also fell in the same period


-- Q10: Crisis period summary table
-- Question: What is the complete before/during/after picture across all key metrics?
-- Expected outcome: Clean summary showing price, nuclear share, wind share, Finland-Sweden spread
-- per crisis period — directly answers the core project question

-- <query here>

        WITH price_summary AS (
            SELECT
                CASE
                    WHEN EXTRACT(YEAR FROM fp.timestamp) BETWEEN 2018 AND 2020 THEN 'Pre-crisis'
                    WHEN EXTRACT(YEAR FROM fp.timestamp) = 2021 THEN 'Early crisis'
                    WHEN EXTRACT(YEAR FROM fp.timestamp) = 2022 THEN 'Crisis'
                    WHEN EXTRACT(YEAR FROM fp.timestamp) = 2023 THEN 'Recovery'
                    WHEN EXTRACT(YEAR FROM fp.timestamp) BETWEEN 2024 AND 2025 THEN 'New normal'
                END AS period,
                CASE
                    WHEN EXTRACT(YEAR FROM fp.timestamp) BETWEEN 2018 AND 2020 THEN 1
                    WHEN EXTRACT(YEAR FROM fp.timestamp) = 2021 THEN 2
                    WHEN EXTRACT(YEAR FROM fp.timestamp) = 2022 THEN 3
                    WHEN EXTRACT(YEAR FROM fp.timestamp) = 2023 THEN 4
                    WHEN EXTRACT(YEAR FROM fp.timestamp) BETWEEN 2024 AND 2025 THEN 5
                END AS period_order,
                ROUND(AVG(fp.price_eur_mwh), 2) AS finland_avg_price,
                ROUND(AVG(sp.price_eur_mwh), 2) AS sweden_avg_price,
                ROUND(AVG(fp.price_eur_mwh) - AVG(sp.price_eur_mwh), 2) AS fi_se_spread
            FROM finland_price fp
            LEFT JOIN sweden_price sp ON fp.timestamp = sp.timestamp
            WHERE EXTRACT(YEAR FROM fp.timestamp) BETWEEN 2018 AND 2025
            GROUP BY period, period_order
        ),

        hourly_mix AS (
            SELECT
                timestamp,
                SUM(generation_mw) AS total_mw,
                SUM(generation_mw) FILTER (WHERE production_type = 'Nuclear') AS nuclear_mw,
                SUM(generation_mw) FILTER (WHERE production_type = 'Wind Onshore') AS wind_mw
            FROM finland_generation_mix
            WHERE EXTRACT(YEAR FROM timestamp) BETWEEN 2018 AND 2025
            GROUP BY timestamp
        ),

        mix_summary AS (
            SELECT
                CASE
                    WHEN EXTRACT(YEAR FROM timestamp) BETWEEN 2018 AND 2020 THEN 'Pre-crisis'
                    WHEN EXTRACT(YEAR FROM timestamp) = 2021 THEN 'Early crisis'
                    WHEN EXTRACT(YEAR FROM timestamp) = 2022 THEN 'Crisis'
                    WHEN EXTRACT(YEAR FROM timestamp) = 2023 THEN 'Recovery'
                    WHEN EXTRACT(YEAR FROM timestamp) BETWEEN 2024 AND 2025 THEN 'New normal'
                END AS period,
                ROUND(SUM(nuclear_mw) / SUM(total_mw) * 100, 2) AS nuclear_share_pct,
                ROUND(SUM(wind_mw) / SUM(total_mw) * 100, 2) AS wind_share_pct
            FROM hourly_mix
            GROUP BY period
        )

        SELECT
            p.period,
            p.finland_avg_price,
            p.sweden_avg_price,
            p.fi_se_spread,
            m.nuclear_share_pct,
            m.wind_share_pct
        FROM price_summary p
        JOIN mix_summary m ON p.period = m.period
        ORDER BY p.period_order;

-- Answer/Analysis:

    -- Price (EUR/MWh): 39.61 -> 72.34 -> 154.07 (Crisis) -> 56.47 -> 43.03
    -- Crisis was ~4x pre-crisis; new normal is only ~9% above baseline

    -- FI-SE spread: 4.93 -> 7.99 -> 34.24 (Crisis) -> 4.79 -> 3.68
    -- Finland's extra premium over Sweden peaked in 2022 and was gone by 2023

    -- Nuclear share: 36.4% -> 35.5% -> 37.9% -> 44.2% (Recovery) -> 39.7%
    -- Step-up in 2023 matches OL3; the later dip is because wind grew the total,
    -- not because nuclear output fell

    -- Wind share: 9.9% -> 12.4% -> 17.5% -> 19.0% -> 26.1% (~2.6x since pre-crisis)

    -- Key finding: both mattered. External factors (European gas) drove the 2022 spike,
    -- since Sweden's price also rose and fell (119.83 -> 51.68). Domestic supply (OL3 + wind)
    -- explains why Finland's extra premium over Sweden disappeared

    -- Caveat: period averages show timing and association, not proof of cause