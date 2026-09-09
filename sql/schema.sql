-- ============================================================
-- Finland Electricity Price Analysis — Database Schema
-- ============================================================

-- Database: finland_electricity

-- DROP DATABASE IF EXISTS finland_electricity;

CREATE DATABASE finland_electricity
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_Finland.1252'
    LC_CTYPE = 'English_Finland.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

CREATE TABLE finland_generation_mix (
	production_type VARCHAR(100),
	timestamp TIMESTAMPTZ,
	generation_mw NUMERIC(10,4),
	PRIMARY KEY (timestamp, production_type)
);

CREATE TABLE finland_price(
	timestamp TIMESTAMPTZ PRIMARY KEY,
	price_eur_mwh NUMERIC(10,4)
);


CREATE TABLE finland_consumption (
	timestamp TIMESTAMPTZ PRIMARY KEY,
	consumption_mwh NUMERIC(10,4)
);

CREATE TABLE  germany_price(
	timestamp TIMESTAMPTZ PRIMARY KEY,
	price_eur_mwh NUMERIC(10,4)
);

CREATE TABLE  sweden_price(
	timestamp TIMESTAMPTZ PRIMARY KEY,
	price_eur_mwh NUMERIC(10,4)
);



