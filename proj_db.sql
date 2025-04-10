-- CREATE DATABASE AND TABLES
-- LOAD DATA THROUGH PYTHON

-- ----- Create Database -----
DROP DATABASE IF EXISTS metabolic_pathways;
CREATE DATABASE metabolic_pathways;

USE metabolic_pathways;
SHOW TABLES;


-- ------ Create Tables ------

-- Organism
 DROP TABLE IF EXISTS organism;
 CREATE TABLE organism (
 	organism_id INT PRIMARY KEY AUTO_INCREMENT,
     organism_name VARCHAR(55),
     taxonomy VARCHAR(55)
 );

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

-- check reaction table
DROP TABLE IF EXISTS reaction;
SELECT * FROM reaction;
SELECT COUNT(*) FROM reaction;

-- check metabolite table
DROP TABLE IF EXISTS metabolite;
SELECT * FROM metabolite;
SELECT COUNT(*) FROM metabolite;

-- check gene table
DROP TABLE IF EXISTS gene;
SELECT * FROM gene;
SELECT COUNT(*) FROM gene;
