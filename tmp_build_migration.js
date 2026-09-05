const fs = require('fs');
const lines = fs
  .readFileSync('c:/Users/shoai/Downloads/FYP_App/acag/tmp_doc_b64.txt', 'utf8')
  .trim()
  .split(/\n/);
const map = {};
for (const line of lines) {
  const i = line.indexOf('|');
  map[line.slice(0, i)] = line.slice(i + 1);
}
function esc(s) {
  return s.replace(/'/g, "''");
}
function filesJson(entries) {
  return JSON.stringify(
    entries.map(([label, key]) => ({ label, data: map[key] })),
  );
}

const pairs = [
  ['cnic', map.cnic_front, filesJson([['Front', 'cnic_front'], ['Back', 'cnic_back']])],
  ['property', map.property, filesJson([['Page 1', 'property']])],
  ['plan', map.plan, filesJson([['Plan', 'plan']])],
  ['noc', map.noc, filesJson([['NOC', 'noc']])],
  ['loan', map.loan, filesJson([['Loan docs', 'loan']])],
  [
    'engineer_report',
    map.engineer_report,
    filesJson([['Report', 'engineer_report']]),
  ],
  [
    'completion_cert',
    map.completion_cert,
    filesJson([['Certificate', 'completion_cert']]),
  ],
];

const values = pairs
  .map(
    ([t, b64, files]) =>
      `('${t}', '${esc(b64)}', '${esc(files)}'::jsonb)`,
  )
  .join(',\n  ');

const sql = `
ALTER TABLE public.project_documents
  ADD COLUMN IF NOT EXISTS files_json jsonb NOT NULL DEFAULT '[]'::jsonb;

UPDATE public.project_documents d
SET
  file_base64 = v.file_b64,
  files_json = v.files,
  updated_at = now()
FROM (VALUES
  ${values}
) AS v(doc_type, file_b64, files)
WHERE d.doc_type = v.doc_type;
`;

fs.writeFileSync(
  'c:/Users/shoai/Downloads/FYP_App/acag/tmp_migration.sql',
  sql,
);
console.log('sql bytes', sql.length);
