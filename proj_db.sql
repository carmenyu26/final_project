-- CREATE DATABASE AND TABLES
-- LOAD DATA THROUGH PYTHON

-- ----- CREATE DATABASE -----
DROP DATABASE IF EXISTS metabolic_pathways;
CREATE DATABASE metabolic_pathways;

USE metabolic_pathways;
SHOW TABLES;



-- ignore
-- DROP TABLE IF EXISTS pathway_rxn_join;
-- DROP TABLE IF EXISTS rxn_gene_join;
-- DROP TABLE IF EXISTS rxn_met_join;
-- DROP TABLE IF EXISTS rxn_org_join;
-- DROP TABLE IF EXISTS org_gene_join;
-- DROP TABLE IF EXISTS reaction;
-- DROP TABLE IF EXISTS pathway;
-- DROP TABLE IF EXISTS metabolite;
-- DROP TABLE IF EXISTS gene;
-- DROP TABLE IF EXISTS organism;




-- ignore
-- TRUNCATE organism;
-- TRUNCATE pathway;
-- TRUNCATE gene;
-- TRUNCATE metabolite;
-- TRUNCATE reaction;
-- TRUNCATE pathway_rxn_join;
-- TRUNCATE rxn_gene_join;
-- TRUNCATE rxn_met_join;
-- TRUNCATE rxn_org_join;
-- TRUNCATE org_gene_join;


-- ------ CREATE TABLES ------
-- Organism
 DROP TABLE IF EXISTS organism;
 CREATE TABLE organism (
 	organism_id INT PRIMARY KEY AUTO_INCREMENT,
     organism_name VARCHAR(25)
 );
 -- loaded from python
 -- check organism table
 SELECT * FROM organism;



-- Pathway
DROP TABLE IF EXISTS pathway;
CREATE TABLE pathway (
	pathway_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    pathway_name VARCHAR(25),
    description VARCHAR(255)
);
-- Insert values into pathway table
INSERT INTO pathway VALUES
(1, 'Glycolysis', 'Breaks down glucose into two molecules of pyruvate, generating energy in the form of ATP and NADH.'),
(2, 'Krebs Cycle', 'Breaks down acetyl-CoA into carbon dioxide, while generating NADH, FADH₂, and ATP (or GTP).'),
(3, 'Electron Transport Chain', 'Final stage of cellular respiration, where most of the cell’s ATP is produced.'),
(4, 'Urea Cycle', 'Detoxifies ammonia by converting it into urea, which is then excreted in the urine.'),
(5, 'Fermentation', 'Anaerobic process that allows cells to produce ATP in the absence of oxygen by converting glucose into other byproducts, such as lactic acid or ethanol.');
-- Check pathway table
SELECT * FROM pathway;



-- Gene
 DROP TABLE IF EXISTS gene;
 CREATE TABLE gene (
	gene_id INT PRIMARY KEY AUTO_INCREMENT,
    gene_letter_id VARCHAR(25) UNIQUE,
    gene_name VARCHAR(25)
);
-- load data from python script
-- check gene table
SELECT * FROM gene;



-- Metabolite
DROP TABLE IF EXISTS metabolite;
CREATE TABLE metabolite (
	metabolite_id INT PRIMARY KEY AUTO_INCREMENT,
	metabolite_letter_id VARCHAR(90) UNIQUE,
    metabolite_name VARCHAR(250)
);
-- load data from python script
-- check metabolite table
SELECT * FROM metabolite;



-- Reaction
DROP TABLE IF EXISTS reaction;
CREATE TABLE reaction (
	reaction_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    reaction_letter_id VARCHAR(90) NOT NULL,
    reaction_name VARCHAR(205) NOT NULL
);
-- load data from python script
-- check reaction table
SELECT * FROM reaction;





-- ----- CREATE JOIN TABLES ------
-- Reaction-Pathway join table
DROP TABLE IF EXISTS pathway_rxn_join;
CREATE TABLE pathway_rxn_join (
	pathway_id INT NOT NULL,
    reaction_id INT NOT NULL,
	CONSTRAINT pat_rxn_pathway_fk FOREIGN KEY (pathway_id) REFERENCES pathway (pathway_id),
    CONSTRAINT pat_rxn_reaction_fk FOREIGN KEY (reaction_id) REFERENCES reaction (reaction_id)
);
-- load data from python
-- check pathway reaction join table
SELECT * FROM pathway_rxn_join;



-- Reaction-Gene join table
DROP TABLE IF EXISTS rxn_gene_join;
CREATE TABLE rxn_gene_join (
	reaction_id INT NOT NULL,
    gene_id INT NOT NULL,
    CONSTRAINT rxn_gene_reactions_fk FOREIGN KEY (reaction_id) REFERENCES reaction (reaction_id),
    CONSTRAINT rxn_gene_genes_fk FOREIGN KEY (gene_id) REFERENCES gene (gene_id)
);
-- load data from python
-- check rxn_gene join table
SELECT * FROM rxn_gene_join;



-- Reaction-Metabolite join table
DROP TABLE IF EXISTS rxn_met_join;
CREATE TABLE rxn_met_join (
	reaction_id INT NOT NULL,
    metabolite_id INT NOT NULL,
    CONSTRAINT rxn_met_reaction_fk FOREIGN KEY (reaction_id) REFERENCES reaction (reaction_id),
    CONSTRAINT rxn_met_metabolite_fk FOREIGN KEY (metabolite_id) REFERENCES metabolite (metabolite_id)
);
-- load data from python
-- check rxn metabolite join table
SELECT * FROM rxn_met_join;



-- Reaction-Organism join table
DROP TABLE IF EXISTS rxn_org_join;
CREATE TABLE rxn_org_join (
	reaction_id INT NOT NULL,
    organism_id INT NOT NULL,
    CONSTRAINT rxn_org_reaction_fk FOREIGN KEY (reaction_id) REFERENCES reaction (reaction_id),
    CONSTRAINT rxn_org_organism_fk FOREIGN KEY (organism_id) REFERENCES organism (organism_id)
);
-- load data
-- check rxn_org join table
SELECT * FROM rxn_org_join;



-- Organism-Gene join table
DROP TABLE IF EXISTS org_gene_join;
CREATE TABLE org_gene_join (
	organism_id INT NOT NULL,
    gene_id INT NOT NULL,
    CONSTRAINT org_gene_organism_fk FOREIGN KEY (organism_id) REFERENCES organism (organism_id),
    CONSTRAINT org_gene_gene_fk FOREIGN KEY (gene_id) REFERENCES gene (gene_id)
);
-- load data
-- check org_gene join table
SELECT * FROM org_gene_join;


-- use metabolic_pathways db
USE metabolic_pathways;


-- show data from all tables
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
