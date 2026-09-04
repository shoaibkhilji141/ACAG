-- Admin-managed project location fields (engineer read-only)
ALTER TABLE public.projects
  ADD COLUMN IF NOT EXISTS district text,
  ADD COLUMN IF NOT EXISTS tehsil text;

-- Visit log: site image upload counts as a visit (dates set by app)
CREATE TABLE IF NOT EXISTS public.engineer_visits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  engineer_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  visited_at timestamptz NOT NULL DEFAULT now(),
  next_visit_at timestamptz NOT NULL,
  trigger_source text NOT NULL DEFAULT 'image_upload',
  notes text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS engineer_visits_project_id_idx
  ON public.engineer_visits(project_id);
CREATE INDEX IF NOT EXISTS engineer_visits_engineer_id_idx
  ON public.engineer_visits(engineer_id);

ALTER TABLE public.engineer_visits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS engineer_visits_all ON public.engineer_visits;
CREATE POLICY engineer_visits_all ON public.engineer_visits
  FOR ALL TO public
  USING (true)
  WITH CHECK (true);

ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS category text DEFAULT 'info';

CREATE INDEX IF NOT EXISTS notifications_user_id_created_at_idx
  ON public.notifications(user_id, created_at DESC);
