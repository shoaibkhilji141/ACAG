/**
 * Generates ACAG User Manual PDF (Engineer + House Owner).
 * Run: node scripts/generate_user_manual_pdf.js
 */
const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');

const outPath = path.join(__dirname, '..', 'USER_MANUAL.pdf');
const doc = new PDFDocument({
  size: 'A4',
  bufferPages: true,
  margins: { top: 56, bottom: 56, left: 54, right: 54 },
  info: {
    Title: 'ACAG User Manual',
    Author: 'ACAG — Apni Chhat Apna Ghar',
    Subject: 'Engineer and House Owner user guide',
  },
});

const stream = fs.createWriteStream(outPath);
doc.pipe(stream);

const GREEN = '#00512C';
const MUTED = '#3F4941';
const BLACK = '#111C2D';
const pageWidth = doc.page.width - doc.page.margins.left - doc.page.margins.right;

function ensureSpace(needed = 60) {
  if (doc.y + needed > doc.page.height - doc.page.margins.bottom) {
    doc.addPage();
  }
}

function h1(text) {
  ensureSpace(40);
  doc.moveDown(0.4);
  doc
    .font('Helvetica-Bold')
    .fontSize(16)
    .fillColor(GREEN)
    .text(text, { width: pageWidth });
  doc
    .moveTo(doc.page.margins.left, doc.y + 2)
    .lineTo(doc.page.margins.left + pageWidth, doc.y + 2)
    .strokeColor(GREEN)
    .lineWidth(1)
    .stroke();
  doc.moveDown(0.6);
  doc.fillColor(BLACK);
}

function h2(text) {
  ensureSpace(32);
  doc.moveDown(0.35);
  doc
    .font('Helvetica-Bold')
    .fontSize(12.5)
    .fillColor(GREEN)
    .text(text, { width: pageWidth });
  doc.moveDown(0.25);
  doc.fillColor(BLACK);
}

function h3(text) {
  ensureSpace(28);
  doc.moveDown(0.2);
  doc
    .font('Helvetica-Bold')
    .fontSize(11)
    .fillColor(BLACK)
    .text(text, { width: pageWidth });
  doc.moveDown(0.15);
}

function p(text) {
  ensureSpace(24);
  doc
    .font('Helvetica')
    .fontSize(10)
    .fillColor(BLACK)
    .text(text, { width: pageWidth, align: 'left', lineGap: 2 });
  doc.moveDown(0.25);
}

function bullet(text) {
  ensureSpace(22);
  doc
    .font('Helvetica')
    .fontSize(10)
    .fillColor(BLACK)
    .text(`•  ${text}`, {
      width: pageWidth,
      indent: 8,
      lineGap: 1.5,
    });
}

function note(text) {
  ensureSpace(36);
  doc.moveDown(0.15);
  doc
    .font('Helvetica-Oblique')
    .fontSize(9.5)
    .fillColor(MUTED)
    .text(text, { width: pageWidth, lineGap: 1.5 });
  doc.moveDown(0.25);
  doc.fillColor(BLACK);
}

function table(headers, rows) {
  ensureSpace(40 + rows.length * 18);
  const colCount = headers.length;
  const colW = pageWidth / colCount;
  const startX = doc.page.margins.left;
  let y = doc.y;

  doc.rect(startX, y, pageWidth, 18).fill(GREEN);
  doc.fillColor('#FFFFFF').font('Helvetica-Bold').fontSize(9);
  headers.forEach((h, i) => {
    doc.text(h, startX + i * colW + 4, y + 5, {
      width: colW - 8,
      ellipsis: true,
    });
  });
  y += 18;

  rows.forEach((row, idx) => {
    if (y + 18 > doc.page.height - doc.page.margins.bottom) {
      doc.addPage();
      y = doc.page.margins.top;
    }
    if (idx % 2 === 0) {
      doc.rect(startX, y, pageWidth, 18).fill('#F0F3FF');
    }
    doc.fillColor(BLACK).font('Helvetica').fontSize(8.5);
    row.forEach((cell, i) => {
      doc.text(String(cell), startX + i * colW + 4, y + 5, {
        width: colW - 8,
        ellipsis: true,
      });
    });
    y += 18;
  });

  doc.y = y + 8;
  doc.fillColor(BLACK);
}

function footer() {
  const range = doc.bufferedPageRange();
  for (let i = range.start; i < range.start + range.count; i++) {
    doc.switchToPage(i);
    const label = `ACAG User Manual  ·  Page ${i + 1} of ${range.count}`;
    doc
      .font('Helvetica')
      .fontSize(8)
      .fillColor(MUTED)
      .text(label, doc.page.margins.left, doc.page.height - 36, {
        width: pageWidth,
        align: 'center',
      });
  }
}

// ── Cover ──────────────────────────────────────────────
doc
  .font('Helvetica-Bold')
  .fontSize(26)
  .fillColor(GREEN)
  .text('ACAG', { align: 'center' });
doc.moveDown(0.3);
doc
  .font('Helvetica-Bold')
  .fontSize(18)
  .fillColor(BLACK)
  .text('User Manual', { align: 'center' });
doc.moveDown(0.4);
doc
  .font('Helvetica')
  .fontSize(12)
  .fillColor(MUTED)
  .text('Apni Chhat Apna Ghar — Construction Validation App', {
    align: 'center',
  });
doc.moveDown(0.6);
doc
  .font('Helvetica')
  .fontSize(10)
  .fillColor(BLACK)
  .text('Government of Punjab  ·  The Urban Unit', { align: 'center' });
doc.moveDown(1.2);
doc
  .font('Helvetica')
  .fontSize(10)
  .text('This guide covers both app roles:', { align: 'center' });
doc.moveDown(0.3);
doc.text('1. Field Engineer', { align: 'center' });
doc.text('2. House Owner (Homeowner)', { align: 'center' });
doc.moveDown(1.5);
doc
  .font('Helvetica-Oblique')
  .fontSize(9)
  .fillColor(MUTED)
  .text('Demo project: ACAG-1  ·  Flutter + Supabase', { align: 'center' });

doc.addPage();

// ── 1 Getting Started ──────────────────────────────────
h1('1. Getting Started');
h2('1.1 Open the app');
bullet('Launch ACAG on your phone.');
bullet('Wait for the splash screen.');
bullet('You will see the Login screen.');

h2('1.2 Demo accounts (testing / FYP demo)');
table(
  ['Role', 'Email', 'Password'],
  [
    ['Field Engineer', 'shoaibkhilji141@gmail.com', '12345678'],
    ['House Owner', 'ali.raza.owner@gmail.com', '12345678'],
  ],
);
p('Demo project linked to both accounts: ACAG-1');
p('Owner: Ali Raza  ·  Engineer: Shoaib Khilji');

h2('1.3 Login');
bullet('Enter email and password.');
bullet('Tap Login.');
bullet('The app opens the correct home screen for your role.');

h2('1.4 Common UI elements');
bullet('Top bar: title / branding and notification bell (unread count).');
bullet('Back arrow: on screens opened from another screen.');
bullet('Pull down to refresh: reloads latest data on many lists.');
bullet('Bottom navigation: switch main sections.');

// ── 2 Engineer ─────────────────────────────────────────
h1('2. Field Engineer Guide');
h2('2.1 Bottom navigation');
table(
  ['Tab', 'Purpose'],
  [
    ['Dashboard', 'Overview, stats, recent notifications'],
    ['Projects', 'Assigned house projects list'],
    ['Camera (center)', 'Quick site photo → visit logged'],
    ['Reports', 'Module completion certificates'],
    ['Profile', 'Profile, documents, settings, logout'],
  ],
);

h2('2.2 Dashboard');
bullet('See assigned projects summary.');
bullet('Open notifications from the bell icon.');
bullet('Use shortcuts to Projects or key actions.');

h2('2.3 Assigned Projects');
bullet('Open Projects and tap a project (e.g. ACAG-1).');
bullet('Review Project ID, address, district/tehsil, progress %, owner, modules, images.');

h2('2.4 Construction Modules (01–05)');
table(
  ['Module', 'What you do'],
  [
    ['01 Planning & Elevation', 'Plot, rooms, floor plans, elevation'],
    ['02 Structure', 'Stories, soil, foundation, frame type'],
    ['03 Materials', 'Material estimation'],
    ['04 Construction Tracking', 'Stages, photos, quality assessment'],
    ['05 Handover', 'Handover, HSE, completion certificate'],
  ],
);
note(
  'Note: Completing a module can notify the owner. Visit/completion times use the device clock automatically.',
);

h2('2.5 Site photos & engineer visits');
h3('Option A — Camera button (bottom center)');
bullet('Tap the camera FAB → Take Photo or Gallery.');
bullet('Photo is saved to the assigned project.');
bullet('App logs an engineer visit (visited now, next visit ≈ +7 days).');
h3('Option B — Module / project upload');
bullet('Upload progress photos with captions in Module 04 flows.');

h2('2.6 Reports');
bullet('Open Reports tab.');
bullet('View module completion certificates for finished modules.');
bullet('Tap a report to open the certificate view.');

h2('2.7 Notifications (Engineer)');
bullet('Open the bell icon or Profile → Notifications.');
p('You may receive:');
bullet('Owner complaint submitted');
bullet('Owner feedback / rating submitted');
bullet('Module / visit related updates');

h2('2.8 Profile (Engineer)');
bullet('View/edit name, phone, location and profile picture.');
bullet('Documents: tap CNIC (etc.) to open picture viewer.');
bullet('Logout from the bottom of the screen.');

// ── 3 Owner ────────────────────────────────────────────
h1('3. House Owner Guide');
h2('3.1 Bottom navigation');
table(
  ['Tab', 'Purpose'],
  [
    ['Dashboard', 'Progress, shortcuts, recent notifications'],
    ['My Project', 'Full house / project details'],
    ['Reports', 'Module reports + documents'],
    ['Profile', 'Profile, documents, settings, logout'],
  ],
);

h2('3.2 Dashboard');
bullet('Overall construction progress %.');
bullet('Quick links: Project, Notifications, Visits.');
bullet('Shortcuts: Feedback, Complaints, Documents.');
bullet('Recent notifications list.');

h2('3.3 My Project (House information)');
p('You can view:');
bullet('Project / House ID, address, city / district / tehsil');
bullet('Plot size, covered area, number of floors');
bullet('Start date, expected completion, progress %');
bullet('Module status (read-only), images & materials');
p('Track Construction actions:');
bullet('Construction Progress · Site Photos · Engineer Visits');
bullet('Documents · Complaints / Issues · Feedback & Rating');

h2('3.4 Construction Progress');
bullet('Open Construction Progress from My Project.');
bullet('See the stage timeline from site prep to completion.');
bullet('Tap a stage for status, dates, remarks, and photos.');
note(
  'Stages show Completed after the engineer records them in Module 04; otherwise Pending.',
);

h2('3.5 Engineer Visits');
bullet('Open Engineer Visits from Dashboard or My Project.');
bullet('See assigned engineer, date/time, purpose, remarks, next visit.');
bullet('Visits are logged when the engineer uploads a site photo.');

h2('3.6 Site Photographs');
bullet('Browse photos uploaded by the engineer.');
bullet('Each item can show caption, date, and uploader name.');
bullet('Tap to view larger.');

h2('3.7 Documents');
p('Open from: Reports → Documents, Profile → Documents, or Dashboard shortcut.');
p('Document types:');
bullet('CNIC · Property · Construction plan · NOC');
bullet('Loan/grant · Engineer reports · Completion certificate');
h3('How to view');
bullet('Tap a document row (e.g. CNIC).');
bullet('Viewer opens with image(s); swipe Front/Back for CNIC.');
bullet('Pinch-to-zoom where supported; back arrow returns to list.');

h2('3.8 Complaints / Issues');
bullet('Open Complaints → New Complaint.');
bullet('Fill category, priority, description, location, optional photos.');
bullet('Submit — status starts as Submitted.');
bullet('Workflow: Submitted → Under Review → In Progress → Resolved.');
bullet('Your assigned engineer receives an in-app notification.');

h2('3.9 Feedback & Rating');
bullet('Select 1–5 stars, optional category and comments.');
bullet('Submit Feedback — engineer is notified in-app.');

h2('3.10 Notifications (Owner)');
bullet('Open the bell icon for visit/module/project alerts.');
note('Owner alerts are in-app only (no external push notifications).');

h2('3.11 Profile (Owner)');
bullet('Name, CNIC, phone, email, address, photo, account status.');
bullet('Documents section with the same viewer.');
bullet('Edit Profile, Notifications, Logout.');

// ── 4 Notifications ────────────────────────────────────
h1('4. Notifications — Quick Reference');
table(
  ['Event', 'Who gets notified'],
  [
    ['Owner submits complaint', 'Assigned Engineer'],
    ['Owner submits feedback', 'Assigned Engineer'],
    ['Engineer completes a module', 'Project parties (incl. Owner)'],
    ['Site photo → visit logged', 'Project parties (incl. Owner)'],
  ],
);

// ── 5 Tips ─────────────────────────────────────────────
h1('5. Tips for Smooth Use');
bullet('Internet is required — data loads from the cloud.');
bullet('First open may be slower; later opens use cache.');
bullet('Pull-to-refresh if data looks outdated.');
bullet('Engineer should upload photos regularly for visits & evidence.');
bullet('Owner is read-only on construction data (except complaints + feedback).');

// ── 6 Troubleshooting ──────────────────────────────────
h1('6. Troubleshooting');
table(
  ['Problem', 'What to try'],
  [
    ['Cannot login', 'Check email/password; use demo accounts'],
    ['Empty project/stages', 'Use correct role; demo project is ACAG-1'],
    ['No notifications', 'Bell → refresh; engineer must be assigned'],
    ['Document has no image', 'Refresh; ensure docs seeded for project'],
    ['App feels slow', 'Use Wi-Fi; refresh once; avoid huge photo loops'],
    ['Back button missing', 'Use system back, or open via shortcut'],
  ],
);

// ── 7 Role summary ─────────────────────────────────────
h1('7. Role Summary');
h2('Engineer can');
bullet('Manage assigned projects and complete Modules 01–05');
bullet('Upload site photos (auto visit log)');
bullet('View reports/certificates and project documents');
bullet('Receive owner complaints & feedback');

h2('Owner can');
bullet('View profile, house info, progress, photos, visits, documents');
bullet('Submit complaints & feedback');
bullet('Read in-app notifications');

h2('Owner cannot');
bullet('Edit project meta (start date, district, covered area)');
bullet('Complete engineer modules or change visit schedule directly');

h1('8. Support');
p('For FYP / demo support, contact your project team or Urban Unit coordinator.');
p('App: ACAG — Apni Chhat Apna Ghar');
p('Stack: Flutter + Supabase');
doc.moveDown(1);
doc
  .font('Helvetica-Oblique')
  .fontSize(9)
  .fillColor(MUTED)
  .text('— End of User Manual —', { align: 'center' });

footer();
doc.end();

stream.on('finish', () => {
  console.log('PDF written:', outPath);
});
stream.on('error', (err) => {
  console.error(err);
  process.exit(1);
});
