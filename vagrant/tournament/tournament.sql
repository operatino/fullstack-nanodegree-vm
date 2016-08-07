-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP DATABASE IF EXISTS tournament;
CREATE DATABASE tournament;

\c tournament;

CREATE TABLE players (
	id serial primary key,
	name text
);

CREATE TABLE matches (
	id serial,
	loser integer references players(id),
	winner integer references players(id),
	primary key (loser, winner)
);

CREATE VIEW matchParticipants AS
	SELECT matches.id, players.id as participant, matches.loser as player1, matches.winner as player2 
	from players, matches
	where players.id = matches.loser OR players.id = matches.winner;

CREATE VIEW matchesPlayed AS
	SELECT players.id, count(matchParticipants.participant) as num
	from players left join matchParticipants
	on players.id = participant
	group by players.id;

CREATE VIEW matchesWon AS
	SELECT players.id, count(matches.winner) as wins
	from players 
	left join matches on players.id = matches.winner
	group by players.id
	order by wins desc;

CREATE VIEW playedAgainst AS
	SELECT players.id, sum(matchesWon.wins) as competitorWins
	from players 
	left join (
		SELECT id, loser as participant, winner as competitor FROM matches
		UNION
		SELECT id, winner as participant, loser as competitor FROM matches
	) as mixedMatches on players.id = participant
	left join matchesWon on competitor = matchesWon.id
	group by players.id
	order by players.id;

-- id: the player's unique id (assigned by the database)
-- name: the player's full name (as registered)
-- wins: the number of matches the player has won
-- matches: the number of matches the player has played

CREATE VIEW scores AS 
	SELECT players.id, players.name, count(matches.winner) as wins, matchesPlayed.num as matches
	from players 
	left join matches on players.id = matches.winner 
	left join matchesPlayed on players.id = matchesPlayed.id
	left join playedAgainst on players.id = playedAgainst.id
	group by players.id, matchesPlayed.num, competitorWins
	order by wins desc, competitorWins desc;


-- FOR TESTS

-- INSERT INTO players (name) values ('player1');
-- INSERT INTO players (name) values ('player2');
-- INSERT INTO players (name) values ('player3');
-- INSERT INTO players (name) values ('player4');
-- INSERT INTO players (name) values ('player5');
-- INSERT INTO players (name) values ('player6');
-- INSERT INTO players (name) values ('player7');
-- INSERT INTO players (name) values ('player8');
-- INSERT INTO matches (loser, winner) values (1, 2);
-- INSERT INTO matches (loser, winner) values (4, 3);
-- INSERT INTO matches (loser, winner) values (5, 6);
-- INSERT INTO matches (loser, winner) values (8, 7);


-- INSERT INTO matches (loser, winner) values (2, 3);
-- INSERT INTO matches (loser, winner) values (6, 7);
-- INSERT INTO matches (loser, winner) values (1, 4);
-- INSERT INTO matches (loser, winner) values (5, 8);

-- INSERT INTO matches (loser, winner) values (3, 7);
-- INSERT INTO matches (loser, winner) values (4, 8);
-- INSERT INTO matches (loser, winner) values (6, 2);
-- INSERT INTO matches (loser, winner) values (5, 1);

-- SELECT * FROM scores;