1. Authentication & User Management
   Do you want single user (desktop app for personal use) or multi-user (team/business accounts)?

- the authentication will be as follow:
  - there is signup only for managers that we will contact them by email and when he is accepted he will be able to add employees
    - when he add employee it's account will be created automatically
  - login for all (employee won't signup only login)
- there is 3 types of app users
  - app owner that has access only to owner dashboard
  - manager that has access to all transactions within his organization
  - employee that has access to all transactions within his organization
- each organization has it's own independent transactions accessed only by members
  Should it use email/password, social login (Google), or local auth only?
- all should be email password saved in supabase authentication

2. Data Sync Strategy
   Should all users share the same expenses/budgets (shared workspace) or each user has their own data?

- users from same organization (added from same manager) have all access expenses/budgets (shared workspace)
  What's your conflict resolution strategy when the same record is edited offline on multiple devices?
- sync first, user 1 online we start syncing with his data, then when user 2 online we start syncing it's data even if it overwrite user 1 changes
  Should deleted records be soft-deleted (marked as deleted) for sync tracking?
- no just delete it
  Do you need sync history/audit trails?
- yes for manager dashboard

3. Offline-First Priority
   Should the app work 100% offline (full local-first) or just gracefully degrade when no connection?

- Build a local-first architecture to ensure instant, offline-capable expense entry for users, while using background synchronization to handle server-side validation, conflicts, and approvals.
  What's acceptable sync frequency? (Automatic? Manual? Background?)?
- background
  Should unsynced changes be queued and synced in order?
- yes

4. Additional Features
   Do you need file uploads for receipts to cloud storage (Supabase Storage)?

- yes
  Do you want real-time updates when other devices sync data?
- yes
  Should there be budget sharing/collaboration features?
- for same organization
  Do you need backup/restore capabilities?
- yes
