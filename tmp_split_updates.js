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

const updates = [
  [
    'cnic',
    map.cnic_front,
    [
      { label: 'Front', data: map.cnic_front },
      { label: 'Back', data: map.cnic_back },
    ],
  ],
  ['property', map.property, [{ label: 'Page 1', data: map.property }]],
  ['plan', map.plan, [{ label: 'Plan', data: map.plan }]],
  ['noc', map.noc, [{ label: 'NOC', data: map.noc }]],
  ['loan', map.loan, [{ label: 'Loan docs', data: map.loan }]],
  [
    'engineer_report',
    map.engineer_report,
    [{ label: 'Report', data: map.engineer_report }],
  ],
  [
    'completion_cert',
    map.completion_cert,
    [{ label: 'Certificate', data: map.completion_cert }],
  ],
];

const parts = updates.map(([type, b64, files]) => {
  return `UPDATE public.project_documents SET file_base64 = '${esc(b64)}', files_json = '${esc(JSON.stringify(files))}'::jsonb, updated_at = now() WHERE doc_type = '${type}';`;
});

fs.writeFileSync(
  'c:/Users/shoai/Downloads/FYP_App/acag/tmp_updates_split.json',
  JSON.stringify(parts),
);
console.log(parts.length, parts[0].length);
