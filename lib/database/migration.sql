-- RUN THIS IN THE SUPABASE SQL EDITOR

-- Add new columns for "Parcelle" category
ALTER TABLE public.immobilier 
ADD COLUMN IF NOT EXISTS surface text,
ADD COLUMN IF NOT EXISTS is_cloture text;

-- Optional: Update category list to be consistent
-- UPDATE public.immobilier SET categorie = 'Parcelle' WHERE categorie = 'Terrain';
