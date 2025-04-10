-- CREATE DATABASE AND TABLES
-- LOAD DATA THROUGH PYTHON

-- ----- Create Database -----
DROP DATABASE IF EXISTS metabolic_pathways;
CREATE DATABASE metabolic_pathways;

USE metabolic_pathways;
SHOW TABLES;

SHOW VARIABLES;
SHOW VARIABLES LIKE '%local%';
-- SET GLOBAL local_infile=ON;


-- ------ Create Tables ------

-- Organism
 DROP TABLE IF EXISTS organism;
 CREATE TABLE organism (
 	organism_id INT PRIMARY KEY AUTO_INCREMENT,
     organism_name VARCHAR(55),
     taxonomy VARCHAR(55)
 );



-- PATHWAY TABLE
DROP TABLE IF EXISTS pathway;
CREATE TABLE pathway (
	pathway_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    pathway_name VARCHAR(55),
    description VARCHAR(55)

-- Reactions
 DROP TABLE IF EXISTS reaction;
 CREATE TABLE reaction (
 	reaction_id INT PRIMARY KEY,
     reaction_name VARCHAR(55) NOT NULL,
     lower_bound INT,
     upper_bound INT,
     is_reversible TINYINT
 );
 
-- Genes
 DROP TABLE IF EXISTS gene;
 CREATE TABLE gene (
	gene_id INT PRIMARY KEY,
    organism_id INT,
    gene_name VARCHAR(45),
    gene_function VARCHAR(45),
    CONSTRAINT gene_organism_fk FOREIGN KEY (organism_id) references organism (organism_id)
);

-- Metabolite
DROP TABLE IF EXISTS metabolite;
CREATE TABLE metabolite (
	metabolite_id INT PRIMARY KEY,
    metabolite_name VARCHAR(45),
    formula VARCHAR(45),
    charge VARCHAR(45),
    compartment VARCHAR(45)
);

-- Insert values into pathway table
INSERT INTO pathway VALUES
(1, 'Glycolysis', NULL),
(2, 'Calvin Cycle', NULL),
(3, 'Electron Transport Chain', NULL),
(4, 'Urea Cycle', NULL),
(5, 'Fermentation', NULL);

-- Check pathway table
SELECT * FROM pathway;


-- REACTION TABLE
DROP TABLE IF EXISTS reaction;
CREATE TABLE reaction (
	reaction_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    letter_id VARCHAR(55) NOT NULL,
    reaction_name VARCHAR(55) NOT NULL,
    pathway_id INT NOT NULL,
    CONSTRAINT reaction_pathway_fk FOREIGN KEY (pathway_id) REFERENCES pathway(pathway_id)
);

-- Data inserted directly from python script

-- Check reaction table
SELECT * FROM reaction;







-- check metabolite table
DROP TABLE IF EXISTS metabolite;
SELECT * FROM metabolite;
SELECT COUNT(*) FROM metabolite;

-- check gene table
DROP TABLE IF EXISTS gene;
SELECT * FROM gene;
SELECT COUNT(*) FROM gene;

-- check pathway table
SELECT * FROM pathway;


