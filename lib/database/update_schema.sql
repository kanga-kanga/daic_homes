-- EXÉCUTER CE SCRIPT DANS L'ÉDITEUR SQL SUPABASE
-- AJOUT DES COLONNES POUR "LOCAL COMMERCIAL" ET "PARCELLE"

ALTER TABLE public.immobilier 
ADD COLUMN IF NOT EXISTS dimension text,
ADD COLUMN IF NOT EXISTS business_type text,
ADD COLUMN IF NOT EXISTS commercial_zone text,
ADD COLUMN IF NOT EXISTS visibility text DEFAULT 'NON';

COMMENT ON COLUMN public.immobilier.business_type IS 'Type d''activité (boutique, bureau, restaurant...)';
COMMENT ON COLUMN public.immobilier.commercial_zone IS 'Zone (marché, centre-ville...)';
COMMENT ON COLUMN public.immobilier.visibility IS 'Visibilité route principale (OUI/NON)';
