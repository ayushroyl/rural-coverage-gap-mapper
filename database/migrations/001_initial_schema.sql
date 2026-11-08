-- SW-27: Rural Coverage Gap Mapper — PostGIS Schema Bootstrap
-- Run this script once against a fresh PostgreSQL database to set up
-- the PostGIS extension and initial schema structure.
--
-- Usage:
--   psql -U postgres -d coverage_mapper -f 001_initial_schema.sql

-- ── Extensions ────────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;

-- ── Districts ─────────────────────────────────────────────────────────────────
-- Stores administrative district boundaries (GeoJSON polygon geometries)
CREATE TABLE IF NOT EXISTS districts (
    id          SERIAL PRIMARY KEY,
    name        TEXT        NOT NULL,
    state       TEXT        NOT NULL DEFAULT 'Karnataka',
    lgd_code    TEXT,                        -- LGD (Local Government Directory) code
    boundary    GEOMETRY(MULTIPOLYGON, 4326) NOT NULL,
    population  INTEGER,
    area_km2    NUMERIC(12, 4),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_districts_boundary
    ON districts USING GIST (boundary);

-- ── Coverage zones ────────────────────────────────────────────────────────────
-- Existing mobile tower coverage footprints (from public data or simulation)
CREATE TABLE IF NOT EXISTS coverage_zones (
    id          SERIAL PRIMARY KEY,
    district_id INTEGER REFERENCES districts(id) ON DELETE CASCADE,
    operator    TEXT,
    technology  TEXT,       -- 2G / 3G / 4G / 5G
    footprint   GEOMETRY(POLYGON, 4326) NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coverage_zones_footprint
    ON coverage_zones USING GIST (footprint);

-- ── Coverage gaps ─────────────────────────────────────────────────────────────
-- Computed uncovered regions within a district
CREATE TABLE IF NOT EXISTS coverage_gaps (
    id          SERIAL PRIMARY KEY,
    district_id INTEGER REFERENCES districts(id) ON DELETE CASCADE,
    gap_area    GEOMETRY(MULTIPOLYGON, 4326) NOT NULL,
    population_affected INTEGER,
    area_km2    NUMERIC(12, 4),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_coverage_gaps_area
    ON coverage_gaps USING GIST (gap_area);

-- ── Tower recommendations ─────────────────────────────────────────────────────
-- Output of the Greedy Maximum Coverage Algorithm
CREATE TABLE IF NOT EXISTS tower_recommendations (
    id              SERIAL PRIMARY KEY,
    district_id     INTEGER REFERENCES districts(id) ON DELETE CASCADE,
    location        GEOMETRY(POINT, 4326) NOT NULL,
    priority_rank   INTEGER,
    population_covered INTEGER,
    coverage_radius_km NUMERIC(6, 2),
    algorithm       TEXT DEFAULT 'greedy_max_coverage',
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tower_recommendations_location
    ON tower_recommendations USING GIST (location);

