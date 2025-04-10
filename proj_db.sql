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
-- DROP TABLE IF EXISTS organism;
-- CREATE TABLE organism (
-- 	organism_id INT PRIMARY KEY AUTO_INCREMENT,
--     organism_name VARCHAR(55),
--     taxonomy VARCHAR(55)
-- );


-- PATHWAY TABLE
DROP TABLE IF EXISTS pathway;
CREATE TABLE pathway (
	pathway_id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    pathway_name VARCHAR(55),
    description VARCHAR(55)
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


