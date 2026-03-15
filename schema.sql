-- ============================================================
-- Fleet Prestart System — Supabase Schema
-- Run this in your Supabase SQL Editor (Database > SQL Editor)
-- ============================================================

-- Vehicles
CREATE TABLE IF NOT EXISTS vehicles (
  id TEXT PRIMARY KEY,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER,
  color TEXT DEFAULT '#BA7517',
  last_service_km INTEGER DEFAULT 0,
  last_service_date DATE,
  service_interval_km INTEGER DEFAULT 5000,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Daily prestarts (one per vehicle per day)
CREATE TABLE IF NOT EXISTS prestarts (
  id TEXT PRIMARY KEY,
  vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  submitted_by TEXT NOT NULL,
  shift TEXT DEFAULT 'Day',
  crew TEXT,
  odometer INTEGER NOT NULL,
  checks JSONB NOT NULL DEFAULT '{}',
  comments JSONB NOT NULL DEFAULT '{}',
  has_critical_fail BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(vehicle_id, date)
);

-- Issues flagged during prestarts
CREATE TABLE IF NOT EXISTS issues (
  id TEXT PRIMARY KEY,
  vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  check_id TEXT,
  label TEXT NOT NULL,
  category TEXT,
  description TEXT,
  date DATE NOT NULL,
  reported_by TEXT,
  resolved BOOLEAN DEFAULT FALSE,
  resolved_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Odometer history (one entry per prestart submission)
CREATE TABLE IF NOT EXISTS km_history (
  id TEXT PRIMARY KEY,
  vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  odometer INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(vehicle_id, date)
);

-- Mechanic service records
CREATE TABLE IF NOT EXISTS service_records (
  id TEXT PRIMARY KEY,
  vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  odometer INTEGER NOT NULL,
  technician TEXT,
  completed TEXT,
  outstanding TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Row Level Security
-- This is an internal tool — we use a simple open policy.
-- For production, replace with proper auth.
-- ============================================================

ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE prestarts ENABLE ROW LEVEL SECURITY;
ALTER TABLE issues ENABLE ROW LEVEL SECURITY;
ALTER TABLE km_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_records ENABLE ROW LEVEL SECURITY;

-- Allow all operations with the anon key (internal tool)
CREATE POLICY "public_all" ON vehicles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON prestarts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON issues FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON km_history FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "public_all" ON service_records FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- Seed demo fleet (optional — delete if adding your own)
-- ============================================================

INSERT INTO vehicles (id, make, model, year, color, last_service_km, last_service_date, service_interval_km)
VALUES
  ('LV159', 'Toyota', 'HiLux', 2022, '#BA7517', 45000, '2025-10-15', 5000),
  ('LV162', 'Toyota', 'LandCruiser 200', 2021, '#0F6E56', 87200, '2025-11-02', 5000),
  ('LV047', 'Ford', 'Ranger', 2023, '#185FA5', 23450, '2025-12-01', 5000),
  ('LV203', 'Mitsubishi', 'Triton', 2020, '#993C1D', 112300, '2025-09-20', 5000)
ON CONFLICT (id) DO NOTHING;
