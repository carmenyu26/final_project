-- CREATE DATABASE AND TABLES
-- LOAD DATA THROUGH PYTHON

-- ----- Create Database -----
DROP DATABASE IF EXISTS metabolic_pathways;
CREATE DATABASE metabolic_pathways;

USE metabolic_pathways;
SHOW TABLES;


-- ------ Create Tables ------

-- Organism
-- DROP TABLE IF EXISTS organism;
-- CREATE TABLE organism (
-- 	organism_id INT PRIMARY KEY AUTO_INCREMENT,
--     organism_name VARCHAR(55),
--     taxonomy VARCHAR(55)
-- );

-- Reactions
-- DROP TABLE IF EXISTS reaction;
-- CREATE TABLE reaction (
-- 	reaction_id INT PRIMARY KEY,
--     reaction_name VARCHAR(55) NOT NULL,
--     lower_bound INT,
--     upper_bound INT,
--     is_reversible TINYINT
-- );

CREATE TABLE reaction (
	id VARCHAR(55),
    name VARCHAR(55),
    lower_bound INT,
    upper_bound INT,
    objective_coefficient INT
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
