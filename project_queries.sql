
USE metabolic_pathways;

-- show all tables
SELECT * FROM organism;
SELECT * FROM pathway;
SELECT * FROM gene;
SELECT * FROM metabolite;
SELECT * FROM reaction;
SELECT * FROM pathway_rxn_join;
SELECT * FROM rxn_gene_join;
SELECT * FROM rxn_met_join;
SELECT * FROM rxn_org_join;
SELECT * FROM org_gene_join;

SHOW TABLES; 
-- Query 1
WITH reaction_coverage AS (
    SELECT 
        o.organism_name,
        SUM(CASE WHEN r.reaction_name IN ('R_FBA','R_ENO','R_G3PD2','R_F6PA','R_F6PP') THEN 0 ELSE 1 END) * 20 AS glycolysis_cov,
        SUM(CASE WHEN r.reaction_name IN ('R_FBP','R_FBA','R_F6PA','R_F6PP','R_F6Pt6_2pp') THEN 0 ELSE 1 END) * 20 AS krebs_cycle_cov,
        SUM(CASE WHEN r.reaction_name IN ('R_CYTBO3_4pp','R_FDH4pp','R_FDH5pp','R_FLDR','R_FLVR') THEN 0 ELSE 1 END) * 20 AS etc_cov,
        SUM(CASE WHEN r.reaction_name IN ('R_ARGSS','R_ARGSL','R_ACOTA','R_ARGDC','R_ARGORNt7pp') THEN 0 ELSE 1 END) * 20 AS urea_cycle_cov,
        SUM(CASE WHEN r.reaction_name IN ('R_ACALD','R_ACKr','R_FHL','R_ALDD2y','R_ETOHtex') THEN 0 ELSE 1 END) * 20 AS ferment_cov
    FROM organism o
    JOIN rxn_org_join ro ON ro.organism_id = o.organism_id
    JOIN reaction r ON r.reaction_id = ro.reaction_id
    GROUP BY o.organism_name
)
SELECT
    organism_name,
    (glycolysis_cov + krebs_cycle_cov + etc_cov + urea_cycle_cov + ferment_cov) / 50 AS avg_coverage
FROM reaction_coverage
ORDER BY avg_coverage DESC;



-- Query 2
SELECT
    o.organism_name,
    SUM(CASE WHEN r.reaction_letter_id IN ('R_ACKr', 'R_ENO', 'R_FBP', 'R_PFOR') 
			 THEN 1 
             ELSE 0 END) AS oxygen_labile_count
FROM organism o
LEFT JOIN rxn_org_join ro ON o.organism_id = ro.organism_id
LEFT JOIN reaction r ON ro.reaction_id = r.reaction_id
GROUP BY o.organism_name
ORDER BY oxygen_labile_count DESC;



-- Query 3
SELECT 
    o.organism_name,
    ROUND((COUNT(DISTINCT r.reaction_id) * 100.0 / total_krebs.krebs_reaction_count)) AS krebs_coverage_percent
FROM organism AS o
JOIN rxn_org_join ro ON o.organism_id = ro.organism_id
JOIN reaction AS r ON ro.reaction_id = r.reaction_id
JOIN pathway_rxn_join AS pr ON r.reaction_id = pr.reaction_id
JOIN pathway AS p ON p.pathway_id = pr.pathway_id
CROSS JOIN (
    SELECT COUNT(DISTINCT r2.reaction_id) AS krebs_reaction_count
    FROM pathway p2
    JOIN pathway_rxn_join pr2 ON p2.pathway_id = pr2.pathway_id
    JOIN reaction r2 ON r2.reaction_id = pr2.reaction_id
    WHERE p2.pathway_name = 'Krebs Cycle'
) AS total_krebs
WHERE p.pathway_name = 'Krebs Cycle'
GROUP BY o.organism_name, total_krebs.krebs_reaction_count
HAVING (COUNT(DISTINCT r.reaction_id) * 100.0 / total_krebs.krebs_reaction_count) >= 0;




-- Query 4 - still working on it (carmen)
-- SELECT g.gene_id, g.gene_letter_id, g.gene_name, og.organism_id
-- FROM gene g
-- JOIN org_gene_join og USING (gene_id)
-- JOIN rxn_gene_join rg USING (gene_id)
-- JOIN pathway_rxn_join rp USING (reaction_id)
-- JOIN pathway p USING (pathway_id)
-- WHERE pathway_name = 'Electron Transport Chain'
-- ORDER BY gene_id;

-- SELECT p.pathway_id, p.pathway_name, r.reaction_id, r.reaction_letter_id
-- FROM pathway p
-- JOIN pathway_rxn_join pr USING (pathway_id)
-- JOIN reaction r USING (reaction_id);

-- -- for each pathway, how many organisms (models) contain reactions from the given pathway?
-- SELECT *
-- FROM pathway p
-- JOIN pathway_rxn_join pr USING (pathway_id)
-- JOIN reaction r USING (reaction_id)
-- JOIN rxn_org_join USING (reaction_id)
-- JOIN organism o USING (organism_id);












-- Query 5
WITH total_organism_count AS (
  SELECT COUNT(DISTINCT ro.organism_id) AS uc_organism_count
  FROM pathway p
  JOIN pathway_rxn_join pr ON p.pathway_id = pr.pathway_id
  JOIN reaction r ON pr.reaction_id = r.reaction_id
  JOIN rxn_org_join ro ON r.reaction_id = ro.reaction_id
  WHERE p.pathway_name = 'Urea Cycle'
),
urea_cycle_reactions AS (
  SELECT r.reaction_id, r.reaction_name, ro.organism_id, g.gene_name, m.metabolite_name
  FROM pathway p
  JOIN pathway_rxn_join pr ON p.pathway_id = pr.pathway_id
  JOIN reaction r ON pr.reaction_id = r.reaction_id
  LEFT JOIN rxn_gene_join rg ON r.reaction_id = rg.reaction_id
  LEFT JOIN rxn_org_join ro ON r.reaction_id = ro.reaction_id
  LEFT JOIN gene g ON rg.gene_id = g.gene_id
  LEFT JOIN rxn_met_join rm ON r.reaction_id = rm.reaction_id
  LEFT JOIN metabolite m ON rm.metabolite_id = m.metabolite_id
  WHERE p.pathway_name = 'Urea Cycle'
)
SELECT reaction_id, reaction_name,
  GROUP_CONCAT(DISTINCT gene_name) AS associated_genes,
  GROUP_CONCAT(DISTINCT metabolite_name) AS associated_metabolites,
  COUNT(DISTINCT organism_id) AS reaction_organism_count,
  toc.uc_organism_count,
  ROUND((COUNT(DISTINCT organism_id) * 100.0 / toc.uc_organism_count), 2) AS coverage_percent
FROM urea_cycle_reactions
CROSS JOIN total_organism_count toc
GROUP BY reaction_id, reaction_name, toc.uc_organism_count
HAVING (COUNT(DISTINCT organism_id) * 1.0 / toc.uc_organism_count) >= 0.80
ORDER BY coverage_percent DESC;
