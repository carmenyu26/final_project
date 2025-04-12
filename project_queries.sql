-- Query 1
SELECT
    coverage_data.organism_name,
    coverage_data.glycolysis_cov,
    coverage_data.cbb_cycle_cov,
    coverage_data.etc_cov,
    coverage_data.urea_cycle_cov,
    coverage_data.ferment_cov,
    -- Compute the average coverage across all 5 pathways
    (
        coverage_data.glycolysis_cov
      + coverage_data.cbb_cycle_cov
      + coverage_data.etc_cov
      + coverage_data.urea_cycle_cov
      + coverage_data.ferment_cov
    ) / 5 AS avg_coverage
FROM
(
    SELECT 
        o.organism_name,

        -- 1) Glycolysis Coverage: Count how many of the 5 glycolysis reactions the organism has, /5 * 100
        ( 
            (1.0 * SUM( CASE 
                          WHEN r.reaction_name IN ('R_FBA','R_ENO','R_G3PD2','R_F6PA','R_F6PP') 
                          THEN 1 
                          ELSE 0 
                        END )
            ) / 5
        ) * 100 AS glycolysis_cov,

        -- 2) CBB Cycle Coverage
        ( 
            (1.0 * SUM( CASE 
                          WHEN r.reaction_name IN ('R_FBP','R_FBA','R_F6PA','R_F6PP','R_F6Pt6_2pp') 
                          THEN 1 
                          ELSE 0 
                        END )
            ) / 5
        ) * 100 AS cbb_cycle_cov,

        -- 3) Electron Transport Chain Coverage
        ( 
            (1.0 * SUM( CASE 
                          WHEN r.reaction_name IN ('R_CYTBO3_4pp','R_FDH4pp','R_FDH5pp','R_FLDR','R_FLVR')
                          THEN 1 
                          ELSE 0 
                        END )
            ) / 5
        ) * 100 AS etc_cov,

        -- 4) Urea Cycle Coverage
        ( 
            (1.0 * SUM( CASE 
                          WHEN r.reaction_name IN ('R_ARGSS','R_ARGSL','R_ACOTA','R_ARGDC','R_ARGORNt7pp')
                          THEN 1 
                          ELSE 0 
                        END )
            ) / 5
        ) * 100 AS urea_cycle_cov,

        -- 5) Fermentation Coverage
        ( 
            (1.0 * SUM( CASE 
                          WHEN r.reaction_name IN ('R_ACALD','R_ACKr','R_FHL','R_ALDD2y','R_ETOHtex')
                          THEN 1 
                          ELSE 0 
                        END )
            ) / 5
        ) * 100 AS ferment_cov

    FROM organisms o
    JOIN reactions r
      ON r.organism_id = o.organism_id

    GROUP BY o.organism_name
) AS coverage_data
ORDER BY avg_coverage DESC;
-- Query 2
SELECT
    o.organism_name,
    org_stats.oxygen_labile_count,
    org_stats.oxygen_detox_count
FROM
(
    SELECT
        r.organism_id,
        SUM(
            CASE 
                WHEN r.reaction_name IN ('R_FHL','R_FDH4pp','R_FDH5pp') 
                     /* Add more known anaerobic reactions as desired */
                THEN 1 
                ELSE 0 
            END
        ) AS oxygen_labile_count,

        /* 2) Count # of oxygen-detox genes for each organism */
        SUM(
            CASE 
                WHEN g.gene_name IN ('sodA','sodB','katG') 
                     /* Add catalase/peroxidase genes or other relevant detox genes */
                THEN 1 
                ELSE 0 
            END
        ) AS oxygen_detox_count

    FROM reactions r
    LEFT JOIN reaction_genes rg 
        ON r.reaction_id = rg.reaction_id
    LEFT JOIN genes g 
        ON rg.gene_id = g.gene_id
    GROUP BY r.organism_id
) AS org_stats
JOIN organisms o
    ON o.organism_id = org_stats.organism_id
WHERE org_stats.oxygen_labile_count > 0
  AND org_stats.oxygen_detox_count = 0
ORDER BY org_stats.oxygen_labile_count DESC;



-- Query 3
SELECT 
    o.organism_name,

    (COUNT(DISTINCT r.reaction_id) * 1.0 
     / total_krebs.krebs_reaction_count) * 100 AS krebs_coverage_percent
FROM organisms AS o
JOIN reactions AS r 
    ON o.organism_id = r.organism_id
JOIN pathway_reactions AS pr
    ON r.reaction_id = pr.reaction_id
JOIN pathways AS p
    ON p.pathway_id = pr.pathway_id
CROSS JOIN (
    SELECT COUNT(DISTINCT r2.reaction_id) AS krebs_reaction_count
    FROM pathways AS p2
    JOIN pathway_reactions AS pr2
      ON p2.pathway_id = pr2.pathway_id
    JOIN reactions AS r2
      ON r2.reaction_id = pr2.reaction_id
    WHERE p2.pathway_name = 'Krebs Cycle'
) AS total_krebs
WHERE p.pathway_name = 'Krebs Cycle'
GROUP BY 
    o.organism_name,
    total_krebs.krebs_reaction_count
HAVING 
    (COUNT(DISTINCT r.reaction_id) * 1.0 
     / total_krebs.krebs_reaction_count) >= 0.80
ORDER BY 
    krebs_coverage_percent DESC
LIMIT 5;


-- Query 4
-- carmen write this one










-- Query 5
SELECT
    r.reaction_id,
    r.reaction_name,
    GROUP_CONCAT(DISTINCT g.gene_name) AS associated_genes,
    GROUP_CONCAT(DISTINCT m.metabolite_name) AS associated_metabolites,    
    COUNT(DISTINCT r.organism_id) AS reaction_organism_count,    
    total_organisms.uc_organism_count,    
    ROUND(
      (COUNT(DISTINCT r.organism_id) * 1.0 / total_organisms.uc_organism_count) * 100,
      2
    ) AS coverage_percent
FROM pathways AS p
JOIN pathway_reactions AS pr
    ON p.pathway_id = pr.pathway_id
JOIN reactions AS r
    ON pr.reaction_id = r.reaction_id
JOIN reaction_genes AS rg
    ON r.reaction_id = rg.reaction_id
JOIN genes AS g
    ON rg.gene_id = g.gene_id
JOIN reaction_metabolites AS rm
    ON r.reaction_id = rm.reaction_id
JOIN metabolites AS m
    ON rm.metabolite_id = m.metabolite_id
CROSS JOIN (
    SELECT COUNT(DISTINCT r2.organism_id) AS uc_organism_count
    FROM pathways AS p2
    JOIN pathway_reactions AS pr2
      ON p2.pathway_id = pr2.pathway_id
    JOIN reactions AS r2
      ON pr2.reaction_id = r2.reaction_id
    WHERE p2.pathway_name = 'Urea Cycle'
) AS total_organisms
WHERE p.pathway_name = 'Urea Cycle'
GROUP BY
    r.reaction_id,
    r.reaction_name,
    total_organisms.uc_organism_count
HAVING
    (COUNT(DISTINCT r.organism_id) * 1.0 / total_organisms.uc_organism_count) >= 0.80
ORDER BY
    coverage_percent DESC;
