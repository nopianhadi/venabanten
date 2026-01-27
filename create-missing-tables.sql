-- ============================================
-- CREATE MISSING TABLES & COLUMNS
-- ============================================
-- Tabel dan kolom yang dibutuhkan tapi belum ada
-- ============================================

-- 1. Create project_add_ons table (junction table)
CREATE TABLE IF NOT EXISTS project_add_ons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    add_on_id UUID NOT NULL REFERENCES add_ons(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Prevent duplicate entries
    UNIQUE(project_id, add_on_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_project_add_ons_project ON project_add_ons(project_id);
CREATE INDEX IF NOT EXISTS idx_project_add_ons_add_on ON project_add_ons(add_on_id);

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS update_project_add_ons_updated_at ON project_add_ons;
CREATE TRIGGER update_project_add_ons_updated_at
    BEFORE UPDATE ON project_add_ons
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add comments
COMMENT ON TABLE project_add_ons IS 'Junction table linking projects to their add-ons';
COMMENT ON COLUMN project_add_ons.project_id IS 'Reference to the project';
COMMENT ON COLUMN project_add_ons.add_on_id IS 'Reference to the add-on';

-- 2. Create calendar_events table
CREATE TABLE IF NOT EXISTS calendar_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    notes TEXT,
    team JSONB DEFAULT '[]'::jsonb,
    image TEXT,
    location TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for calendar_events
CREATE INDEX IF NOT EXISTS idx_calendar_events_date ON calendar_events(date);
CREATE INDEX IF NOT EXISTS idx_calendar_events_event_type ON calendar_events(event_type);
CREATE INDEX IF NOT EXISTS idx_calendar_events_title ON calendar_events USING gin(to_tsvector('english', title));

-- Create trigger for calendar_events updated_at
DROP TRIGGER IF EXISTS update_calendar_events_updated_at ON calendar_events;
CREATE TRIGGER update_calendar_events_updated_at
    BEFORE UPDATE ON calendar_events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add comments for calendar_events
COMMENT ON TABLE calendar_events IS 'Calendar events and internal activities';
COMMENT ON COLUMN calendar_events.title IS 'Event title/name';
COMMENT ON COLUMN calendar_events.event_type IS 'Type of event (Meeting, Shooting, etc.)';
COMMENT ON COLUMN calendar_events.date IS 'Event date';
COMMENT ON COLUMN calendar_events.start_time IS 'Event start time';
COMMENT ON COLUMN calendar_events.end_time IS 'Event end time';
COMMENT ON COLUMN calendar_events.team IS 'Assigned team members (JSONB array)';
COMMENT ON COLUMN calendar_events.location IS 'Event location';

-- 3. Add missing columns to packages table (if they don't exist)
DO $$ 
BEGIN
    -- Add duration_options column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'duration_options') THEN
        ALTER TABLE packages ADD COLUMN duration_options JSONB DEFAULT '[]'::jsonb;
        CREATE INDEX IF NOT EXISTS idx_packages_duration_options ON packages USING GIN (duration_options);
        COMMENT ON COLUMN packages.duration_options IS 'JSONB array of duration-based pricing options';
    END IF;
    
    -- Add other missing columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'physical_items') THEN
        ALTER TABLE packages ADD COLUMN physical_items JSONB DEFAULT '[]'::jsonb;
        CREATE INDEX IF NOT EXISTS idx_packages_physical_items ON packages USING GIN (physical_items);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'digital_items') THEN
        ALTER TABLE packages ADD COLUMN digital_items JSONB DEFAULT '[]'::jsonb;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'default_printing_cost') THEN
        ALTER TABLE packages ADD COLUMN default_printing_cost DECIMAL(15,2) DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'default_transport_cost') THEN
        ALTER TABLE packages ADD COLUMN default_transport_cost DECIMAL(15,2) DEFAULT 0;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'photographers') THEN
        ALTER TABLE packages ADD COLUMN photographers VARCHAR(100);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'videographers') THEN
        ALTER TABLE packages ADD COLUMN videographers VARCHAR(100);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'cover_image') THEN
        ALTER TABLE packages ADD COLUMN cover_image TEXT;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'region') THEN
        ALTER TABLE packages ADD COLUMN region VARCHAR(100);
        CREATE INDEX IF NOT EXISTS idx_packages_region ON packages(region);
    END IF;
END $$;

-- ============================================
-- VERIFY TABLES EXIST
-- ============================================

-- Check if all required tables exist
SELECT 'Required tables check:' as info;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'profiles') 
        THEN '✅ profiles' 
        ELSE '❌ profiles' 
    END as profiles_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'project_team_assignments') 
        THEN '✅ project_team_assignments' 
        ELSE '❌ project_team_assignments' 
    END as team_assignments_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'project_add_ons') 
        THEN '✅ project_add_ons' 
        ELSE '❌ project_add_ons' 
    END as project_add_ons_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'add_ons') 
        THEN '✅ add_ons' 
        ELSE '❌ add_ons' 
    END as add_ons_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'calendar_events') 
        THEN '✅ calendar_events' 
        ELSE '❌ calendar_events' 
    END as calendar_events_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'duration_options') 
        THEN '✅ packages.duration_options' 
        ELSE '❌ packages.duration_options' 
    END as packages_duration_options_status;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT '🎉 All missing tables and columns created successfully!' as result;