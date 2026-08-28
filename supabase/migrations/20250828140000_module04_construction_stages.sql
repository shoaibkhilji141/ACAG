-- Module 04: construction stage progress (run once in Supabase SQL Editor)

CREATE TABLE IF NOT EXISTS public.module04_construction_stages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  stage_no int NOT NULL CHECK (stage_no BETWEEN 1 AND 7),
  stage_name text NOT NULL,
  image_base64 text,
  description text DEFAULT '',
  completed_at timestamptz DEFAULT now(),
  completed_by uuid REFERENCES auth.users(id),
  UNIQUE (project_id, stage_no)
);

CREATE INDEX IF NOT EXISTS idx_module04_stages_project
  ON public.module04_construction_stages(project_id, stage_no);

ALTER TABLE public.projects
  ADD COLUMN IF NOT EXISTS owner_phone text;

ALTER TABLE public.module04_construction_stages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS module04_select ON public.module04_construction_stages;
CREATE POLICY module04_select ON public.module04_construction_stages
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS module04_insert ON public.module04_construction_stages;
CREATE POLICY module04_insert ON public.module04_construction_stages
  FOR INSERT TO authenticated
  WITH CHECK (true);

DROP POLICY IF EXISTS module04_update ON public.module04_construction_stages;
CREATE POLICY module04_update ON public.module04_construction_stages
  FOR UPDATE TO authenticated
  USING (true)
  WITH CHECK (true);
