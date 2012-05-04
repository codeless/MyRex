-- SQL-statements for creating the necessary tables and records
-- for the MyRex example

DROP DATABASE IF EXISTS myrex_example;
CREATE DATABASE myrex_example;
USE myrex_example;

DROP TABLE IF EXISTS records;
CREATE TABLE records (
	r_id TINYINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	r_datetime DATETIME NOT NULL,
	r_value INT NOT NULL
);

INSERT INTO records (r_datetime, r_value) VALUES ("2012-05-04 12:00:00", 1);
INSERT INTO records (r_datetime, r_value) VALUES ("2012-05-04 13:00:00", 2);
INSERT INTO records (r_datetime, r_value) VALUES ("2012-05-04 14:00:00", 100);
INSERT INTO records (r_datetime, r_value) VALUES ("2012-05-04 15:00:00", 9);
INSERT INTO records (r_datetime, r_value) VALUES ("2012-05-04 16:00:00", 125);

DROP VIEW IF EXISTS critical_records;
CREATE VIEW critical_records AS
	SELECT * FROM records WHERE r_value > 5;
