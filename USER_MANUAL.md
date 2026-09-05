# ACAG User Manual  
**Apni Chhat Apna Ghar — Construction Validation App**

Government of Punjab · The Urban Unit  

This manual explains how to use the **ACAG** mobile app for both roles:

1. **Field Engineer**
2. **House Owner (Homeowner)**

---

## 1. Getting Started

### 1.1 Open the app
1. Launch **ACAG** on your phone.
2. Wait for the splash screen.
3. You will see the **Login** screen.

### 1.2 Demo accounts (for testing / FYP demo)

| Role | Email | Password |
|------|-------|----------|
| **Field Engineer** | `shoaibkhilji141@gmail.com` | `12345678` |
| **House Owner** | `ali.raza.owner@gmail.com` | `12345678` |

Demo project linked to both accounts: **ACAG-1**  
Owner: **Ali Raza** · Engineer: **Shoaib Khilji**

### 1.3 Login
1. Enter email and password.
2. Tap **Login**.
3. The app opens the correct home screen based on your role (Engineer or Owner).

### 1.4 Common UI elements
- **Top bar (App Bar):** App branding / screen title, notification bell (with unread count).
- **Back arrow:** Appears on screens opened from another screen (Complaints, Feedback, Progress, Photos, etc.).
- **Pull down to refresh:** On many lists (dashboard, reports, notifications) to reload latest data.
- **Bottom navigation:** Switch main sections without leaving the app.

---

## 2. Field Engineer Guide

### 2.1 Bottom navigation

| Tab | Purpose |
|-----|---------|
| **Dashboard** | Overview of assigned work, quick stats, recent notifications |
| **Projects** | List of assigned house projects |
| **Camera (center FAB)** | Quick site photo capture → saved to project + visit logged |
| **Reports** | Module completion reports / certificates |
| **Profile** | Engineer profile, documents, settings, logout |

### 2.2 Dashboard
- See assigned projects summary.
- Open notifications from the bell icon.
- Use shortcuts to go to Projects or key actions.

### 2.3 Assigned Projects
1. Open **Projects**.
2. Tap a project (e.g. **ACAG-1**) to open **Project Details**.
3. Review:
   - Project ID, address, district / tehsil  
   - Progress % and current phase  
   - Owner details  
   - Module status (Modules 01–05)  
   - Images and materials tabs  

### 2.4 Construction Modules (01–05)
From Project Details, open a module to fill validation data.

| Module | What you do |
|--------|-------------|
| **01 — Plot & Design** | Plot dimensions, rooms, floor plans, elevation |
| **02 — Structure** | Stories, soil analysis, foundation drawing, frame type |
| **03 — Materials** | Material estimation |
| **04 — Construction Tracking** | Stage timeline, photos, quality assessment |
| **05 — Handover** | Handover, HSE compliance, completion certificate |

**Important**
- When you **complete a module**, the owner (and related parties) can get an in-app notification.
- Dates for visits / completions use the device’s current time automatically (no date picker required for those flows).

### 2.5 Site photos & engineer visits
**Option A — Camera button (bottom center)**  
1. Tap the camera FAB.  
2. Choose **Take Photo** or **Gallery**.  
3. Photo is saved to the assigned project.  
4. App logs an **engineer visit** (`visited_at` = now, next visit ≈ +7 days).  

**Option B — From project / module photo upload screens**  
Upload progress photos with captions as part of Module 04 work.

### 2.6 Reports
- Open **Reports** tab.
- View **module completion certificates** for finished modules.
- Tap a report to open / share / download style certificate view.

### 2.7 Notifications (Engineer)
Open the bell icon or Profile → Notifications.

You receive alerts such as:
- Owner **complaint** submitted  
- Owner **feedback / rating** submitted  
- Module / visit related updates (as configured)

Tap a notification to mark it as seen (unread badge updates).

### 2.8 Profile (Engineer)
- View / edit name, phone, location  
- Update profile picture  
- View **Documents** for assigned project (CNIC, plans, NOC, etc.)  
  - Tap a document (e.g. **CNIC**) → opens picture viewer (swipe pages if Front/Back)  
- Logout from the bottom of the screen  

---

## 3. House Owner Guide

### 3.1 Bottom navigation

| Tab | Purpose |
|-----|---------|
| **Dashboard** | Progress overview, shortcuts, recent notifications |
| **My Project** | Full house / project details |
| **Reports** | Module reports + project documents |
| **Profile** | Owner profile, documents, settings, logout |

### 3.2 Dashboard
Shows:
- Overall construction progress %  
- Quick links: Project, Notifications, Visits  
- Shortcuts: **Feedback**, **Complaints**, **Documents**  
- Recent notifications  

### 3.3 My Project (House information)
Open **My Project** to see:

- Project / House ID  
- House address  
- City / District / Tehsil  
- Plot size & covered area  
- Number of floors  
- Construction start date  
- Expected completion date  
- Current phase / progress %  
- Module status (read-only)  
- Images & materials tabs  

**Track Construction actions**
- Construction Progress (stages timeline)  
- Site Photos  
- Engineer Visits  
- Documents  
- Complaints / Issues  
- Feedback & Rating  

### 3.4 Construction Progress
1. From My Project → **Construction Progress**.  
2. See the stage timeline (site prep → foundation → finishing → completion).  
3. Tap a stage for details:
   - Status (Pending / Completed — as recorded by engineer)  
   - Completion date  
   - Engineer remarks  
   - Photos (when uploaded)  

> Stages appear as **Completed** after the engineer records them in Module 04. Until then they show as **Pending**.

### 3.5 Engineer Visits
1. Open **Engineer Visits** from Dashboard or My Project.  
2. Each visit shows:
   - Assigned engineer  
   - Visit date & time  
   - Purpose (e.g. site photo / inspection)  
   - Remarks  
   - Next visit date  
3. Tap a visit for full detail.

> Visits are recorded when the engineer uploads a site photo (auto visit log).

### 3.6 Site Photographs
1. Open **Site Photos**.  
2. Browse photos uploaded by the engineer.  
3. Each item can show caption, date, and uploader name.  
4. Tap to view larger.

### 3.7 Documents
**Where to open**
- **Reports** tab → **Documents** chip, or  
- **Profile** → **Documents**, or  
- Dashboard shortcut **Documents**

**Document types**
- CNIC copy  
- Property ownership documents  
- Approved construction plan  
- NOC / municipal approval  
- Loan / grant documents  
- Engineer inspection reports  
- Completion certificate  

**How to view**
1. Tap a document row (e.g. **CNIC**).  
2. Viewer opens with image(s).  
3. For CNIC, swipe between **Front** and **Back**.  
4. Use pinch-to-zoom where supported.  
5. Back arrow returns to the list.

Status chips (Pending / Submitted / Approved / Rejected) show document review state.

### 3.8 Complaints / Issues
1. Open **Complaints** from Dashboard or My Project.  
2. Tap **+ New Complaint** (FAB).  
3. Fill:
   - Category (Quality, Delay, Materials, etc.)  
   - Priority (Low / Medium / High)  
   - Description  
   - Location (optional text)  
   - Photos (optional)  
4. Tap **Submit**.  

**After submit**
- Complaint appears in your list with status **Submitted**.  
- Status can move: Submitted → Under Review → In Progress → Resolved.  
- Your **assigned engineer** receives an in-app notification.  
- Open a complaint to see response text when available.

### 3.9 Feedback & Rating
1. Open **Feedback** from Dashboard or My Project.  
2. Select star rating (1–5).  
3. Optionally choose category (Engineer, Quality, Timeline, Materials).  
4. Add comments.  
5. Tap **Submit Feedback**.  

Your assigned engineer is notified in-app.

### 3.10 Notifications (Owner)
Open the bell icon.

Typical alerts include:
- Engineer visit completed  
- Module / construction updates  
- Important project messages  

> Owner **does not** receive push notifications outside the app — all alerts are **in-app** only.

### 3.11 Profile (Owner)
View and manage:
- Name  
- CNIC  
- Phone  
- Email  
- Address / location  
- Profile picture  
- Account status (Active / Inactive)  
- Project progress stats  
- **Documents** section (same document viewer as above)  

**Settings**
- Edit Profile  
- Notifications  
- Logout  

---

## 4. Notifications — Quick Reference

| Event | Who gets notified |
|-------|-------------------|
| Owner submits **complaint** | Assigned **Engineer** |
| Owner submits **feedback** | Assigned **Engineer** |
| Engineer completes a **module** | Project parties (incl. Owner, as configured) |
| Engineer site photo → **visit logged** | Project parties (incl. Owner, as configured) |

Open the **bell** anytime to read and clear unread items.

---

## 5. Tips for Smooth Use

1. **Internet required** — data loads from Supabase cloud.  
2. First open of a screen may take a moment; later opens are faster (cache / prefetch).  
3. Use **pull-to-refresh** if data looks outdated.  
4. Prefer **hot restart** after app updates during development/demo.  
5. Engineer should upload photos regularly — this updates visits and evidence for the owner.  
6. Owner is **read-only** on construction data (except complaints + feedback).  

---

## 6. Troubleshooting

| Problem | What to try |
|---------|-------------|
| Cannot login | Check email/password; use demo accounts above |
| Empty project / stages | Confirm you are on the correct role account; ACAG-1 is the demo project |
| No notifications | Open bell → pull to refresh; engineer must be assigned on the project |
| Document has no image | Tap again after refresh; ensure documents are seeded for the project |
| App feels slow | Stay on Wi‑Fi; avoid opening very large photo lists repeatedly; pull-to-refresh once |
| Back button missing | Use Android/iOS system back, or open the screen from a shortcut (pushed screens show back arrow) |

---

## 7. Role Summary

### Engineer can
- Manage assigned projects  
- Complete Modules 01–05  
- Upload site photos (auto visit log)  
- View reports / certificates  
- Receive owner complaints & feedback  
- View project documents  

### Owner can
- View profile & house project info  
- Track construction progress & photos  
- See engineer visits  
- View / open documents  
- Submit complaints & feedback  
- Read in-app notifications  

### Owner cannot
- Edit project meta (start date, district, covered area — admin/DB)  
- Complete engineer modules  
- Change engineer visit schedule directly  

---

## 8. Support

For FYP / demo support, contact your project team or Urban Unit coordinator.

**App:** ACAG — Apni Chhat Apna Ghar  
**Version context:** Flutter + Supabase backend  

---

*End of User Manual*
