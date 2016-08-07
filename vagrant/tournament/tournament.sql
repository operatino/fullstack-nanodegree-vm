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

CREATE TABLE players(
	id serial primary key,
	name text
);

CREATE TABLE matches(
	id serial primary key,
	loser integer references players(id),
	winner integer references players(id)
);

CREATE VIEW matchParticipants AS
	SELECT matches.id, players.id as participant 
	from players, matches
	where players.id = matches.loser OR players.id = matches.winner;

CREATE VIEW matchesPlayed AS
	SELECT players.id, count(matchParticipants.participant) as num
	from players left join matchParticipants
	on players.id = participant
	group by players.id;

-- id: the player's unique id (assigned by the database)
-- name: the player's full name (as registered)
-- wins: the number of matches the player has won
-- matches: the number of matches the player has played

CREATE VIEW scores AS 
	SELECT players.id, players.name, count(matches.winner) as wins, matchesPlayed.num as matches 
	from players 
	left join matches on players.id = matches.winner 
	left join matchesPlayed on players.id = matchesPlayed.id
	group by players.id, matchesPlayed.num
	order by wins desc;