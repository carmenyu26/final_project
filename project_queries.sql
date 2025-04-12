-- Query 1
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




#Query 2












# Query 3
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
