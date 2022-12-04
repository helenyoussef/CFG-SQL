CREATE DATABASE MarioKart;
USE MarioKart;

-- CREATING TABLES 

CREATE TABLE Player
(p_id VARCHAR(3) PRIMARY KEY,
name VARCHAR(50) UNIQUE NOT NULL,
weight INTEGER,
speed INTEGER);

CREATE TABLE Kart
(k_id VARCHAR(3) PRIMARY KEY, 
name VARCHAR(50) UNIQUE NOT NULL,
weight INTEGER,
speed INTEGER);

CREATE TABLE Wheel
(w_id VARCHAR(3) PRIMARY KEY, 
name VARCHAR(50) UNIQUE NOT NULL,
weight INTEGER,
speed INTEGER);

CREATE TABLE Cup
(d_id VARCHAR(3) PRIMARY KEY,
name VARCHAR(50) UNIQUE NOT NULL);

CREATE TABLE Course
(c_id VARCHAR(3) PRIMARY KEY,
name VARCHAR(50) UNIQUE NOT NULL,       
difficulty INTEGER,
d_id VARCHAR(3),
FOREIGN KEY (d_id) REFERENCES Cup(d_id));

CREATE TABLE Medal
(position INTEGER PRIMARY KEY,
medal VARCHAR(50));

CREATE TABLE Game
(g_id INT AUTO_INCREMENT PRIMARY KEY,
d_id VARCHAR(3),
CC ENUM('50', '100', '150', '150M', '200'),
entry_time TIMESTAMP,
FOREIGN KEY (d_id) REFERENCES Cup(d_id));

CREATE TABLE Ranking
(r_id INT AUTO_INCREMENT PRIMARY KEY,
g_id INT,
p_id VARCHAR(3),
k_id VARCHAR(3),
w_id VARCHAR(3),
position INTEGER,
FOREIGN KEY (g_id) REFERENCES Game(g_id),
FOREIGN KEY (p_id) REFERENCES Player(p_id),
FOREIGN KEY (k_id) REFERENCES Kart(k_id),
FOREIGN KEY (w_id) REFERENCES Wheel(w_id),
FOREIGN KEY (position) REFERENCES Medal(position));

-- TRIGGER to ensure consistency in the display of player names

DELIMITER //
CREATE TRIGGER check_names
BEFORE INSERT on Player
FOR EACH ROW
BEGIN
	SET NEW.name = CONCAT(UPPER(SUBSTRING(NEW.name,1,1)),
						LOWER(SUBSTRING(NEW.name FROM 2)));
END//
DELIMITER ;

-- POPULATE TABLES 

INSERT INTO Player
(p_id, name, weight, speed)
VALUES
('P1', 'MARIO', 6, 6),
('P2', 'Luigi', 6, 6),
('P3', 'Peach', 4, 5),
('P4', 'Daisy', 4, 5),
('P5', 'Yoshi', 4, 5),
('P6', 'Toad', 3, 3),
('P7', 'bOwser', 10, 10),
('P8', 'Wario', 9, 10),
('P9', 'Waluigi', 8, 9),
('P10', 'Mii', 6, 6);

INSERT INTO Kart
(k_id, name, weight, speed)
VALUES
('K1', 'StandardKart', 2, 3),
('K2', 'PipeFrame', 1, 1),
('K3', 'Mach8', 3, 3),
('K4', 'SteelDriver', 4, 4),
('K5', 'CatCruiser', 2, 2),
('K6', 'CircuitSpecial', 3, 5);

INSERT INTO Wheel
(w_id, name, weight, speed)
VALUES
('W1', 'Standard', 2, 2),
('W2', 'Monster', 4, 2),
('W3', 'Roller', 0, 0),
('W4', 'Slim', 2, 3),
('W5', 'Slick', 3, 4),
('W6', 'Metal', 4, 4);

INSERT INTO Cup
(d_id, name)
VALUES
('D1', 'MushroomCup'),
('D2', 'FlowerCup'),
('D3', 'StarCup'),
('D4', 'SpecialCup');

INSERT INTO Course
(c_id, name, difficulty, d_id)
VALUES
('C1', 'MarioKartStadium', 2, 'D1'),
('C2', 'WaterPark', 4, 'D1'),
('C3', 'SweetSweetCanyon', 6, 'D1'),
('C4', 'ThwompRuins', 3, 'D1'),
('C5', 'MarioCircuit', 1, 'D2'),
('C6', 'ToadHarbor', 5, 'D2'),
('C7', 'TwistedMansion', 8, 'D2'),
('C8', 'ShyGuyFalls', 3, 'D2'),
('C9', 'SunshineAirport', 6, 'D3'),
('C10', 'DolphinShoals', 4, 'D3'),
('C11', 'Electrodrome', 2, 'D3'),
('C12', 'MountWario', 7, 'D3'),
('C13', 'CloudtopCruise', 5, 'D4'),
('C14', 'BoneDryDunes', 2, 'D4'),
('C15', 'BowsersCastle', 8, 'D4'),
('C16', 'RainbowRoad', 9, 'D4');

INSERT INTO Medal
(position, medal)
VALUES
(1, 'Gold'),
(2, 'Silver'),
(3, 'Bronze'),
(4, NULL);

-- CHECK TRIGGER WORKED

SELECT p.name 
FROM player p;

-- CREATE FUNCTION to categorise the difficulties of different courses

DELIMITER //
CREATE FUNCTION DIFFICULTY_CLASS (difficulty INTEGER)
RETURNS VARCHAR (20)
DETERMINISTIC
BEGIN
	DECLARE difficulty_level VARCHAR (20);
	IF difficulty <= 3 THEN 
		SET difficulty_level= 'Easy';
	ELSEIF (difficulty > 3 AND difficulty <= 6) THEN 
		SET difficulty_level='Medium';
	ELSEIF difficulty > 6 THEN 
		SET difficulty_level='Hard';
	END IF;
	RETURN (difficulty_level);
END//difficulty
DELIMITER ;

-- USE FUNCTION

SELECT 
c.Name, 
DIFFICULTY_CLASS(c.difficulty) AS 'Difficulty Class'
FROM Course c
ORDER BY c.difficulty;

-- STORED PROC

SET sql_safe_updates=0;

DELIMITER //
CREATE PROCEDURE new_game(IN did VARCHAR(3), 
		IN CCs ENUM('50', '100', '150', '150M', '200'))
BEGIN
	INSERT INTO game
	(d_id, CC, entry_time)
	VALUES 
    (did, CCs, current_timestamp());
END //
DELIMITER ;

#DROP PROCEDURE new_game;

-- EVENT

SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS DropOldData;

DELIMITER //
CREATE EVENT DropOldData
	ON SCHEDULE EVERY 2 SECOND
    STARTS NOW()
DO BEGIN
	DELETE FROM Game g
    WHERE TIMESTAMPDIFF(DAY, g.entry_time, current_timestamp())>10;
END//
DELIMITER ;

#DROP EVENT dropolddata;

-- POPULATE GAME & RANKINGS
CALL new_game('d2', '150M');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (1, 'P1', 'K1', 'W1', 1),
    (1, 'P3', 'K2', 'W4', 2),
    (1, 'P9', 'K5', 'W2', 3),
    (1, 'P4', 'K4', 'W3', 4);

CALL new_game('d3', '150');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (2, 'P3', 'K1', 'W1', 1),
    (2, 'P1', 'K2', 'W5', 2),
    (2, 'P9', 'K3', 'W2', 3),
    (2, 'P4', 'K2', 'W3', 4);

CALL new_game('d1', '150M');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (3, 'P1', 'K6', 'W5', 1),
    (3, 'P3', 'K6', 'W3', 2),
    (3, 'P4', 'K1', 'W2', 3),
    (3, 'P9', 'K2', 'W3', 4);
    
CALL new_game('d2', '100');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (4, 'P1', 'K2', 'W3', 1),
    (4, 'P3', 'K3', 'W4', 2),
    (4, 'P9', 'K5', 'W2', 3),
    (4, 'P4', 'K4', 'W1', 4);

CALL new_game('d1', '100');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (5, 'P4', 'K1', 'W1', 1),
    (5, 'P3', 'K2', 'W3', 2),
    (5, 'P9', 'K6', 'W1', 3),
    (5, 'P1', 'K6', 'W3', 4);

CALL new_game('d4', '200');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (6, 'P9', 'K3', 'W1', 1),
    (6, 'P4', 'K4', 'W6', 2),
    (6, 'P3', 'K3', 'W5', 3),
    (6, 'P1', 'K2', 'W3', 4);

CALL new_game('d4', '200');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (7, 'P6', 'K6', 'W1', 1),
    (7, 'P2', 'K1', 'W5', 2),
    (7, 'P8', 'K4', 'W4', 3),
    (7, 'P6', 'K2', 'W2', 4);
    
CALL new_game('d4', '100');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (8, 'P6', 'K6', 'W6', 1),
    (8, 'P9', 'K2', 'W5', 2),
    (8, 'P8', 'K4', 'W3', 3),
    (8, 'P4', 'K2', 'W2', 4);
    
CALL new_game('d2', '100');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (9, 'P2', 'K1', 'W6', 1),
    (9, 'P7', 'K4', 'W4', 2),
    (9, 'P8', 'K6', 'W3', 3),
    (9, 'P3', 'K2', 'W2', 4);

CALL new_game('d4', '50');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (10, 'P2', 'K1', 'W6', 1),
    (10, 'P7', 'K4', 'W4', 2),
    (10, 'P8', 'K6', 'W3', 3),
    (10, 'P3', 'K2', 'W2', 4);

CALL new_game('d4', '200');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (11, 'P6', 'K3', 'W3', 1),
    (11, 'P4', 'K1', 'W5', 2),
    (11, 'P5', 'K6', 'W1', 3),
    (11, 'P2', 'K4', 'W6', 4);

CALL new_game('d4', '150');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (12, 'P2', 'K2', 'W1', 1),
    (12, 'P6', 'K6', 'W3', 2),
    (12, 'P5', 'K4', 'W1', 3),
    (12, 'P4', 'K3', 'W5', 4);

CALL new_game('d4', '150M');
	INSERT INTO Ranking
    (g_id, p_id, k_id, w_id, position)
    VALUES
    (13, 'P5', 'K1', 'W3', 1),
    (13, 'P4', 'K3', 'W2', 2),
    (13, 'P2', 'K6', 'W5', 3),
    (13, 'P1', 'K5', 'W6', 4);

SELECT * FROM GAME;

SELECT * FROM RANKING;

-- EXAMPLE QUERY WITH JOINS AND GROUP BY AND HAVING: to query number of wins per winning player ordered most to least wins

SELECT p.name, COUNT(r.p_id) AS 'Number of Wins'
FROM Ranking r
	INNER JOIN Player p
    ON r.p_id=p.p_id
GROUP BY p.name, r.position, r.p_id
HAVING r.position=1
ORDER BY COUNT(r.p_id) desc;

-- EXAMPLE QUERY WITH SUBQUERY: to show the player speeds of players who won at least one game

SELECT p.name, p.speed
FROM Player p
WHERE p.p_id IN
	(SELECT r.p_id
	FROM Ranking r
    WHERE r.position=1);

-- VIEW OF AT LEAST 3 TABLES

CREATE VIEW mk_view AS 
SELECT d.name AS Cup, g.CC, p.name AS Player, m.Medal
FROM Cup d 
	INNER JOIN Game g
	INNER JOIN Player p
    INNER JOIN Medal m
	INNER JOIN Ranking r
ON d.d_id=g.d_id and g.g_id=r.g_id and p.p_id=r.p_id and m.position=r.position
WITH CHECK OPTION;

-- QUERY ON THE VIEW: Players that got Gold in non mirrored CC settings and which cup it was in

SELECT v.Cup, v.CC, v.Player, v.Medal
FROM mk_view v
WHERE v.Medal = 'Gold' and v.CC != '150M';


#DROP DATABASE mariokart;

