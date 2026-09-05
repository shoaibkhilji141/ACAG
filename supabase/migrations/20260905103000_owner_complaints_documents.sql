-- Owner Part 3: complaints, documents, feedback category
ALTER TABLE public.owner_feedback
  ADD COLUMN IF NOT EXISTS category text;

CREATE TABLE IF NOT EXISTS public.complaints (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  raised_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  category text NOT NULL,
  description text NOT NULL,
  photo_base64 text,
  photos_json jsonb NOT NULL DEFAULT '[]'::jsonb,
  location_text text,
  priority text NOT NULL DEFAULT 'medium',
  status text NOT NULL DEFAULT 'submitted',
  response_text text,
  responded_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  responded_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT complaints_priority_check CHECK (priority IN ('low','medium','high')),
  CONSTRAINT complaints_status_check CHECK (status IN ('submitted','under_review','in_progress','resolved'))
);

CREATE INDEX IF NOT EXISTS complaints_project_id_idx ON public.complaints(project_id);

ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS complaints_all ON public.complaints;
CREATE POLICY complaints_all ON public.complaints FOR ALL TO public USING (true) WITH CHECK (true);

CREATE TABLE IF NOT EXISTS public.project_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  doc_type text NOT NULL,
  title text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  file_base64 text,
  notes text,
  uploaded_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT project_documents_status_check CHECK (status IN ('pending','submitted','approved','rejected'))
);

CREATE INDEX IF NOT EXISTS project_documents_project_id_idx ON public.project_documents(project_id);

ALTER TABLE public.project_documents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS project_documents_all ON public.project_documents;
CREATE POLICY project_documents_all ON public.project_documents FOR ALL TO public USING (true) WITH CHECK (true);
