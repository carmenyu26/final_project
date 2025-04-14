
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
        (COUNT(DISTINCT r.reaction_name) - COUNT(DISTINCT ex_glycolysis.reaction_name) * 20) AS glycolysis_cov,
        (COUNT(DISTINCT r.reaction_name) - COUNT(DISTINCT ex_krebs.reaction_name) * 20) AS krebs_cycle_cov,
        (COUNT(DISTINCT r.reaction_name) - COUNT(DISTINCT ex_etc.reaction_name) * 20) AS etc_cov,
        (COUNT(DISTINCT r.reaction_name) - COUNT(DISTINCT ex_urea.reaction_name) * 20) AS urea_cycle_cov,
        (COUNT(DISTINCT r.reaction_name) - COUNT(DISTINCT ex_ferment.reaction_name) * 20) AS ferment_cov
    FROM organism o
    JOIN rxn_org_join ro ON ro.organism_id = o.organism_id
    JOIN reaction r ON r.reaction_id = ro.reaction_id
    LEFT JOIN reaction ex_glycolysis ON ex_glycolysis.reaction_name IN ('R_FBA','R_ENO','R_G3PD2','R_F6PA','R_F6PP') AND ex_glycolysis.reaction_id = r.reaction_id
    LEFT JOIN reaction ex_krebs ON ex_krebs.reaction_name IN ('R_FBP','R_FBA','R_F6PA','R_F6PP','R_F6Pt6_2pp') AND ex_krebs.reaction_id = r.reaction_id
    LEFT JOIN reaction ex_etc ON ex_etc.reaction_name IN ('R_CYTBO3_4pp','R_FDH4pp','R_FDH5pp','R_FLDR','R_FLVR') AND ex_etc.reaction_id = r.reaction_id
    LEFT JOIN reaction ex_urea ON ex_urea.reaction_name IN ('R_ARGSS','R_ARGSL','R_ACOTA','R_ARGDC','R_ARGORNt7pp') AND ex_urea.reaction_id = r.reaction_id
    LEFT JOIN reaction ex_ferment ON ex_ferment.reaction_name IN ('R_ACALD','R_ACKr','R_FHL','R_ALDD2y','R_ETOHtex') AND ex_ferment.reaction_id = r.reaction_id
    GROUP BY o.organism_name
)
SELECT
    organism_name,
    ROUND((glycolysis_cov + krebs_cycle_cov + etc_cov + urea_cycle_cov + ferment_cov) / 500, 2) AS avg_coverage
FROM reaction_coverage
ORDER BY avg_coverage DESC;




-- Query 2
SELECT
    o.organism_name,
    COUNT(r.reaction_letter_id) AS oxygen_labile_count
FROM organism o
LEFT JOIN rxn_org_join ro ON o.organism_id = ro.organism_id
LEFT JOIN reaction r ON ro.reaction_id = r.reaction_id
    AND r.reaction_letter_id IN ('R_ACKr', 'R_ENO', 'R_FBP', 'R_PFOR')
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
HAVING krebs_coverage_percent >= 80;




-- Query 4
WITH 
atp_rxns_per_org AS (SELECT o.organism_id, COUNT(ro.reaction_id) AS 'atp_rxns'
						FROM organism o
						JOIN rxn_org_join ro ON o.organism_id = ro.organism_id
						WHERE ro.reaction_id IN (SELECT r.reaction_id
												FROM reaction r
												JOIN rxn_met_join rm ON r.reaction_id = rm.reaction_id
												JOIN metabolite m ON rm.metabolite_id = m.metabolite_id
												WHERE metabolite_letter_id LIKE 'M\_%atp\_%'
												   OR metabolite_letter_id LIKE 'M\_adp\_%')
						GROUP BY o.organism_id),
rxns_per_org AS (SELECT o.organism_id, COUNT(ro.reaction_id) AS 'total_rxns'
					FROM organism o
					JOIN rxn_org_join ro ON o.organism_id = ro.organism_id
					GROUP BY o.organism_id)
                    
SELECT o.organism_id, o.organism_name, atp_rxns, total_rxns, 
	   ROUND(atp_rxns/total_rxns * 100, 2) AS 'pct_atp_rxns'
FROM atp_rxns_per_org
JOIN rxns_per_org USING (organism_id)
JOIN organism o USING (organism_id)
GROUP BY organism_id, atp_rxns, total_rxns
HAVING pct_atp_rxns >= 20
ORDER BY pct_atp_rxns DESC;




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
