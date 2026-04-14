-- Run this in Neon SQL Editor

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  password_salt VARCHAR(64) NOT NULL,
  college VARCHAR(255) NOT NULL DEFAULT '',
  department VARCHAR(255) NOT NULL DEFAULT '',
  role VARCHAR(20) NOT NULL DEFAULT 'student',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  logo_base64 TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  club_id UUID REFERENCES clubs(id) ON DELETE SET NULL,
  club_name VARCHAR(255) NOT NULL DEFAULT '',
  venue VARCHAR(255) NOT NULL DEFAULT '',
  start_date_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date_time TIMESTAMP WITH TIME ZONE NOT NULL,
  registration_deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  max_participants INTEGER NOT NULL DEFAULT 0,
  banner_base64 TEXT,
  tag VARCHAR(50) NOT NULL DEFAULT 'General',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(event_id, user_id)
);

-- Indexes for performance
CREATE INDEX idx_events_club_id ON events(club_id);
CREATE INDEX idx_events_start ON events(start_date_time);
CREATE INDEX idx_registrations_event ON registrations(event_id);
CREATE INDEX idx_registrations_user ON registrations(user_id);
CREATE INDEX idx_users_email ON users(email);

-- Seed initial clubs
INSERT INTO clubs (name, description) VALUES
  ('CyberNerds', 'Tech Club focused on web apps and security.'),
  ('Artistry', 'Cultural Club for arts and dance.'),
  ('SportsHub', 'Sports Club promoting fitness.');
