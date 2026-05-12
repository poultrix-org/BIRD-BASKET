-- 1. vet_bookings (Used by VetHomeController for direct nearby vet booking)
CREATE TABLE IF NOT EXISTS public.vet_bookings (
    booking_id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    farmer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    vet_id TEXT, 
    status TEXT DEFAULT 'pending',
    latitude NUMERIC,
    longitude NUMERIC
);

-- 2. VaccinationBookings (Used by VaccinationBookingController)
CREATE TABLE IF NOT EXISTS public."VaccinationBookings" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    farmer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    farm_name TEXT,
    bird_type TEXT,
    total_birds INTEGER,
    bird_age TEXT,
    vaccination_type TEXT,
    preferred_date DATE,
    preferred_time TIME,
    consultation_type TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    address TEXT,
    reminder_enabled BOOLEAN DEFAULT false,
    notes TEXT,
    status TEXT DEFAULT 'scheduled'
);

-- 3. VaccinationHistory (Used by VaccinationBookingController)
CREATE TABLE IF NOT EXISTS public."VaccinationHistory" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    farmer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    farm_name TEXT,
    bird_type TEXT,
    vaccination_type TEXT,
    vaccination_date DATE,
    next_due_date DATE,
    notes TEXT
);

-- 4. VetBookings (Used by EmergencyBookingController)
CREATE TABLE IF NOT EXISTS public."VetBookings" (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    farmer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    vet_id TEXT,
    issue_type TEXT,
    description TEXT,
    number_of_birds INTEGER,
    affected_birds_count INTEGER,
    symptoms TEXT[],
    location JSONB,
    image_url TEXT,
    image_urls TEXT[],
    audio_url TEXT,
    consultation_type TEXT,
    emergency_level TEXT,
    payment_mode TEXT,
    status TEXT DEFAULT 'pending'
);

-- Don't forget to enable Row Level Security (RLS) if you haven't already!
-- ALTER TABLE public.vet_bookings ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public."VaccinationBookings" ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public."VaccinationHistory" ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public."VetBookings" ENABLE ROW LEVEL SECURITY;
