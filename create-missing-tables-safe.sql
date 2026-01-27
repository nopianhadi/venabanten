-- ============================================
-- CREATE MISSING TABLES & COLUMNS (SAFE VERSION)
-- ============================================
-- Versi aman yang tidak akan error jika sudah ada
-- ============================================

-- 1. Create project_add_ons table (junction table) - SAFE
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'project_add_ons') THEN
        CREATE TABLE project_add_ons (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
            add_on_id UUID NOT NULL REFERENCES add_ons(id) ON DELETE CASCADE,
            created_at TIMESTAMP DEFAULT NOW(),
            updated_at TIMESTAMP DEFAULT NOW(),
            
            -- Prevent duplicate entries
            UNIQUE(project_id, add_on_id)
        );

        -- Create indexes for better performance
        CREATE INDEX idx_project_add_ons_project ON project_add_ons(project_id);
        CREATE INDEX idx_project_add_ons_add_on ON project_add_ons(add_on_id);

        -- Add comments
        COMMENT ON TABLE project_add_ons IS 'Junction table linking projects to their add-ons';
        COMMENT ON COLUMN project_add_ons.project_id IS 'Reference to the project';
        COMMENT ON COLUMN project_add_ons.add_on_id IS 'Reference to the add-on';
        
        RAISE NOTICE '✅ Created table: project_add_ons';
    ELSE
        RAISE NOTICE '⚠️  Table project_add_ons already exists, skipping...';
    END IF;
    
    -- Create trigger (safe)
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_project_add_ons_updated_at') THEN
        CREATE TRIGGER update_project_add_ons_updated_at
            BEFORE UPDATE ON project_add_ons
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE '✅ Created trigger: update_project_add_ons_updated_at';
    ELSE
        RAISE NOTICE '⚠️  Trigger update_project_add_ons_updated_at already exists, skipping...';
    END IF;
END $$;

-- 2. Create calendar_events table - SAFE
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'calendar_events') THEN
        CREATE TABLE calendar_events (
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
        CREATE INDEX idx_calendar_events_date ON calendar_events(date);
        CREATE INDEX idx_calendar_events_event_type ON calendar_events(event_type);
        CREATE INDEX idx_calendar_events_title ON calendar_events USING gin(to_tsvector('english', title));

        -- Add comments for calendar_events
        COMMENT ON TABLE calendar_events IS 'Calendar events and internal activities';
        COMMENT ON COLUMN calendar_events.title IS 'Event title/name';
        COMMENT ON COLUMN calendar_events.event_type IS 'Type of event (Meeting, Shooting, etc.)';
        COMMENT ON COLUMN calendar_events.date IS 'Event date';
        COMMENT ON COLUMN calendar_events.start_time IS 'Event start time';
        COMMENT ON COLUMN calendar_events.end_time IS 'Event end time';
        COMMENT ON COLUMN calendar_events.team IS 'Assigned team members (JSONB array)';
        COMMENT ON COLUMN calendar_events.location IS 'Event location';
        
        RAISE NOTICE '✅ Created table: calendar_events';
    ELSE
        RAISE NOTICE '⚠️  Table calendar_events already exists, skipping...';
    END IF;
    
    -- Create trigger (safe)
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_calendar_events_updated_at') THEN
        CREATE TRIGGER update_calendar_events_updated_at
            BEFORE UPDATE ON calendar_events
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
        RAISE NOTICE '✅ Created trigger: update_calendar_events_updated_at';
    ELSE
        RAISE NOTICE '⚠️  Trigger update_calendar_events_updated_at already exists, skipping...';
    END IF;
END $$;

-- 3. Add missing columns to packages table (SAFE)
DO $$ 
BEGIN
    -- Add duration_options column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'duration_options') THEN
        ALTER TABLE packages ADD COLUMN duration_options JSONB DEFAULT '[]'::jsonb;
        CREATE INDEX idx_packages_duration_options ON packages USING GIN (duration_options);
        COMMENT ON COLUMN packages.duration_options IS 'JSONB array of duration-based pricing options';
        RAISE NOTICE '✅ Added column: packages.duration_options';
    ELSE
        RAISE NOTICE '⚠️  Column packages.duration_options already exists, skipping...';
    END IF;
    
    -- Add other missing columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'physical_items') THEN
        ALTER TABLE packages ADD COLUMN physical_items JSONB DEFAULT '[]'::jsonb;
        CREATE INDEX idx_packages_physical_items ON packages USING GIN (physical_items);
        RAISE NOTICE '✅ Added column: packages.physical_items';
    ELSE
        RAISE NOTICE '⚠️  Column packages.physical_items already exists, skipping...';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'digital_items') THEN
        ALTER TABLE packages ADD COLUMN digital_items JSONB DEFAULT '[]'::jsonb;
        RAISE NOTICE '✅ Added column: packages.digital_items';
    ELSE
        RAISE NOTICE '⚠️  Column packages.digital_items already exists, skipping...';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'default_printing_cost') THEN
        ALTER TABLE packages ADD COLUMN default_printing_cost DECIMAL(15,2) DEFAULT 0;
        RAISE NOTICE '✅ Added column: packages.default_printing_cost';
    ELSE
        RAISE NOTICE '⚠️  Column packages.default_printing_cost already exists, skipping...';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'default_transport_cost') THEN
        ALTER TABLE packages ADD COLUMN default_transport_cost DECIMAL(15,2) DEFAULT 0;
        RAISE NOTICE '✅ Added column: packages.default_transport_cost';
    ELSE
        RAISE NOTICE '⚠️  Column packages.default_transport_cost already exists, skipping...';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'photographers') THEN
        ALTER TABLE packages ADD COLUMN photographers VARCHAR(100);
        RAISE NOTICE '✅ Added column: packages.photographers';
    ELSE
        RAISE NOTICE '⚠️  Column packages.photographers already exists, skipping...';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'videographers') THEN
        ALTER TABLE packages ADD COLUMN videographers VARCHAR(100);
        RAISE NOTICE '✅ Added column: packages.videographers';
    ELSE
        RAISE NOTICE '⚠️  Column packages.videographers already exists, skipping...';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'cover_image') THEN
        ALTER TABLE packages ADD COLUMN cover_image TEXT;
        RAISE NOTICE '✅ Added column: packages.cover_image';
    ELSE
        RAISE NOTICE '⚠️  Column packages.cover_image already exists, skipping...';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'packages' AND column_name = 'region') THEN
        ALTER TABLE packages ADD COLUMN region VARCHAR(100);
        CREATE INDEX idx_packages_region ON packages(region);
        RAISE NOTICE '✅ Added column: packages.region';
    ELSE
        RAISE NOTICE '⚠️  Column packages.region already exists, skipping...';
    END IF;
END $$;

-- 4. Add missing columns to projects table (SAFE)
DO $$ 
BEGIN
    -- Add printing_card_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'printing_card_id') THEN
        ALTER TABLE projects ADD COLUMN printing_card_id UUID REFERENCES cards(id) ON DELETE SET NULL;
        CREATE INDEX idx_projects_printing_card_id ON projects(printing_card_id);
        COMMENT ON COLUMN projects.printing_card_id IS 'Card used for printing expenses';
        RAISE NOTICE '✅ Added column: projects.printing_card_id';
    ELSE
        RAISE NOTICE '⚠️  Column projects.printing_card_id already exists, skipping...';
    END IF;
    
    -- Add transport_card_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'transport_card_id') THEN
        ALTER TABLE projects ADD COLUMN transport_card_id UUID REFERENCES cards(id) ON DELETE SET NULL;
        CREATE INDEX idx_projects_transport_card_id ON projects(transport_card_id);
        COMMENT ON COLUMN projects.transport_card_id IS 'Card used for transport expenses';
        RAISE NOTICE '✅ Added column: projects.transport_card_id';
    ELSE
        RAISE NOTICE '⚠️  Column projects.transport_card_id already exists, skipping...';
    END IF;
END $$;

-- 5. Add missing columns to galleries table (SAFE)
DO $$ 
BEGIN
    -- Add images column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'galleries' AND column_name = 'images') THEN
        ALTER TABLE galleries ADD COLUMN images JSONB DEFAULT '[]'::jsonb;
        CREATE INDEX idx_galleries_images ON galleries USING GIN (images);
        COMMENT ON COLUMN galleries.images IS 'JSONB array of gallery images';
        RAISE NOTICE '✅ Added column: galleries.images';
    ELSE
        RAISE NOTICE '⚠️  Column galleries.images already exists, skipping...';
    END IF;
END $$;

-- ============================================
-- VERIFY TABLES EXIST
-- ============================================

-- Check if all required tables exist
SELECT '📋 VERIFICATION RESULTS:' as info;

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

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'printing_card_id') 
        THEN '✅ projects.printing_card_id' 
        ELSE '❌ projects.printing_card_id' 
    END as projects_printing_card_id_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'transport_card_id') 
        THEN '✅ projects.transport_card_id' 
        ELSE '❌ projects.transport_card_id' 
    END as projects_transport_card_id_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'galleries' AND column_name = 'images') 
        THEN '✅ galleries.images' 
        ELSE '❌ galleries.images' 
    END as galleries_images_status;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT '🎉 Database setup completed successfully!' as result;
SELECT 'All missing tables and columns have been created or verified.' as message;
SELECT 'Storage buckets still need to be created separately.' as storage_note;
SELECT 'You can now test the application without 404 and column errors.' as next_step;