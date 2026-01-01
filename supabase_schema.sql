-- =====================================================
-- Expense Tracking App - Supabase Schema
-- =====================================================
-- Multi-tenant architecture with organization-based isolation
-- Supports: Owner (app admin), Manager (org admin), Employee roles
-- Features: Offline-first sync, audit trails, receipt storage
-- 
-- IMPORTANT: Run this entire file in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- CLEANUP (Optional - run if recreating schema)
-- =====================================================
-- DROP TABLE IF EXISTS audit_logs CASCADE;
-- DROP TABLE IF EXISTS expenses CASCADE;
-- DROP TABLE IF EXISTS categories CASCADE;
-- DROP TABLE IF EXISTS budgets CASCADE;
-- DROP TABLE IF EXISTS user_profiles CASCADE;
-- DROP TABLE IF EXISTS organizations CASCADE;
-- DROP TYPE IF EXISTS user_role CASCADE;
-- DROP TYPE IF EXISTS organization_status CASCADE;
-- DROP TYPE IF EXISTS audit_action CASCADE;

-- =====================================================
-- ENUMS
-- =====================================================

-- User roles in the system
-- owner: App administrator, approves manager signups
-- manager: Organization admin, can add employees
-- employee: Regular user, can create expenses
CREATE TYPE user_role AS ENUM ('owner', 'manager', 'employee');

-- Organization approval status
CREATE TYPE organization_status AS ENUM ('pending', 'approved', 'rejected');

-- Actions tracked in audit logs
CREATE TYPE audit_action AS ENUM (
  'CREATE', 'UPDATE', 'DELETE',           -- Data operations
  'LOGIN', 'LOGOUT',                       -- Auth operations
  'APPROVE', 'REJECT',                     -- Organization operations
  'ADD_EMPLOYEE', 'REMOVE_EMPLOYEE'        -- Employee operations
);

-- =====================================================
-- ORGANIZATIONS TABLE
-- =====================================================
-- Each manager creates an organization on signup
-- Owner must approve before manager can use the app

CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Basic info
  name TEXT NOT NULL,
  description TEXT,
  
  -- Manager who created this organization
  manager_email TEXT NOT NULL,
  manager_name TEXT,
  
  -- Approval workflow
  status organization_status NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  approved_by UUID,  -- Owner who approved/rejected
  approved_at TIMESTAMP WITH TIME ZONE,
  
  -- Settings
  currency TEXT NOT NULL DEFAULT 'USD',
  timezone TEXT NOT NULL DEFAULT 'UTC',
  fiscal_year_start INTEGER DEFAULT 1, -- Month (1-12)
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_organizations_status ON organizations(status);
CREATE INDEX idx_organizations_manager_email ON organizations(manager_email);
CREATE INDEX idx_organizations_created_at ON organizations(created_at);

-- =====================================================
-- USER PROFILES TABLE
-- =====================================================
-- Extends Supabase auth.users with app-specific data
-- Links users to their organization

CREATE TABLE user_profiles (
  -- Primary key matches auth.users id
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Organization (NULL for owners)
  organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
  
  -- User info
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  
  -- Role and status
  role user_role NOT NULL DEFAULT 'employee',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  
  -- For sync tracking
  last_sync_at TIMESTAMP WITH TIME ZONE,
  
  -- User preferences (JSON)
  settings JSONB NOT NULL DEFAULT '{}',
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT unique_email UNIQUE(email),
  CONSTRAINT valid_owner_no_org CHECK (
    (role = 'owner' AND organization_id IS NULL) OR
    (role != 'owner' AND organization_id IS NOT NULL)
  )
);

-- Indexes
CREATE INDEX idx_user_profiles_org ON user_profiles(organization_id);
CREATE INDEX idx_user_profiles_role ON user_profiles(role);
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_user_profiles_active ON user_profiles(is_active) WHERE is_active = TRUE;

-- =====================================================
-- CATEGORIES TABLE
-- =====================================================
-- Budget categories shared within an organization
-- All org members can view; any member can create/edit

CREATE TABLE categories (
  id BIGSERIAL PRIMARY KEY,
  
  -- Organization ownership
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  
  -- Who created this category
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  
  -- Category info
  name TEXT NOT NULL,
  description TEXT,
  color INTEGER NOT NULL,           -- ARGB color value
  icon_code_point TEXT NOT NULL,    -- Flutter icon code point
  
  -- Budget tracking
  budget REAL NOT NULL DEFAULT 0.0, -- Monthly budget limit
  
  -- For conflict resolution (last-write-wins)
  version INTEGER NOT NULL DEFAULT 1,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT positive_budget CHECK (budget >= 0),
  CONSTRAINT unique_category_name_per_org UNIQUE(organization_id, name)
);

-- Indexes
CREATE INDEX idx_categories_org ON categories(organization_id);
CREATE INDEX idx_categories_created_by ON categories(created_by);
CREATE INDEX idx_categories_updated_at ON categories(updated_at);

-- =====================================================
-- EXPENSES TABLE
-- =====================================================
-- Individual expense records
-- All org members can view; any member can create/edit

CREATE TABLE expenses (
  id BIGSERIAL PRIMARY KEY,
  
  -- Organization ownership
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  
  -- Who created this expense
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  
  -- Category
  category_id BIGINT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  
  -- Expense details
  amount REAL NOT NULL,
  date DATE NOT NULL,
  description TEXT NOT NULL,
  notes TEXT,
  
  -- Receipt attachment (Supabase Storage)
  receipt_url TEXT,
  receipt_file_name TEXT,
  
  -- Reimbursement tracking
  is_reimbursable BOOLEAN NOT NULL DEFAULT FALSE,
  reimbursed_at TIMESTAMP WITH TIME ZONE,
  reimbursed_by UUID REFERENCES auth.users(id),
  
  -- For conflict resolution (last-write-wins)
  version INTEGER NOT NULL DEFAULT 1,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT positive_amount CHECK (amount > 0)
);

-- Indexes for common query patterns
CREATE INDEX idx_expenses_org ON expenses(organization_id);
CREATE INDEX idx_expenses_category ON expenses(category_id);
CREATE INDEX idx_expenses_created_by ON expenses(created_by);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_updated_at ON expenses(updated_at);
CREATE INDEX idx_expenses_date_range ON expenses(organization_id, date);
CREATE INDEX idx_expenses_reimbursable ON expenses(is_reimbursable) WHERE is_reimbursable = TRUE;

-- =====================================================
-- BUDGETS TABLE
-- =====================================================
-- Monthly/yearly budget periods for organization
-- Allows setting overall org budget and tracking spending

CREATE TABLE budgets (
  id BIGSERIAL PRIMARY KEY,
  
  -- Organization ownership
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  
  -- Budget period
  year INTEGER NOT NULL,
  month INTEGER NOT NULL, -- 1-12, or 0 for yearly budget
  
  -- Budget amounts
  total_budget REAL NOT NULL DEFAULT 0.0,
  total_spent REAL NOT NULL DEFAULT 0.0,
  
  -- Who set this budget
  created_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT positive_total_budget CHECK (total_budget >= 0),
  CONSTRAINT valid_month CHECK (month >= 0 AND month <= 12),
  CONSTRAINT unique_budget_period UNIQUE(organization_id, year, month)
);

-- Indexes
CREATE INDEX idx_budgets_org ON budgets(organization_id);
CREATE INDEX idx_budgets_period ON budgets(year, month);

-- =====================================================
-- AUDIT LOGS TABLE
-- =====================================================
-- Tracks all changes for manager dashboard
-- Immutable - no updates or deletes allowed

CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Who and where
  organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  user_email TEXT NOT NULL,
  user_name TEXT,
  
  -- What happened
  action audit_action NOT NULL,
  table_name TEXT,
  record_id BIGINT,
  
  -- Change details
  old_data JSONB,
  new_data JSONB,
  description TEXT, -- Human-readable description
  
  -- Context
  ip_address INET,
  user_agent TEXT,
  
  -- When
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for audit queries
CREATE INDEX idx_audit_logs_org ON audit_logs(organization_id);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_table_record ON audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_org_date ON audit_logs(organization_id, created_at);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create audit log entry
CREATE OR REPLACE FUNCTION create_audit_log(
  p_org_id UUID,
  p_user_id UUID,
  p_action audit_action,
  p_table_name TEXT DEFAULT NULL,
  p_record_id BIGINT DEFAULT NULL,
  p_old_data JSONB DEFAULT NULL,
  p_new_data JSONB DEFAULT NULL,
  p_description TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_user_email TEXT;
  v_user_name TEXT;
  v_log_id UUID;
BEGIN
  -- Get user info
  SELECT email, full_name INTO v_user_email, v_user_name
  FROM user_profiles WHERE id = p_user_id;
  
  -- Insert audit log
  INSERT INTO audit_logs (
    organization_id, user_id, user_email, user_name,
    action, table_name, record_id,
    old_data, new_data, description
  ) VALUES (
    p_org_id, p_user_id, COALESCE(v_user_email, 'unknown'), v_user_name,
    p_action, p_table_name, p_record_id,
    p_old_data, p_new_data, p_description
  )
  RETURNING id INTO v_log_id;
  
  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Auto-create audit log for expenses
CREATE OR REPLACE FUNCTION audit_expense_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_action audit_action;
  v_old_data JSONB;
  v_new_data JSONB;
  v_org_id UUID;
  v_user_id UUID;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_action := 'CREATE';
    v_new_data := to_jsonb(NEW);
    v_org_id := NEW.organization_id;
    v_user_id := NEW.created_by;
  ELSIF TG_OP = 'UPDATE' THEN
    v_action := 'UPDATE';
    v_old_data := to_jsonb(OLD);
    v_new_data := to_jsonb(NEW);
    v_org_id := NEW.organization_id;
    v_user_id := auth.uid();
  ELSIF TG_OP = 'DELETE' THEN
    v_action := 'DELETE';
    v_old_data := to_jsonb(OLD);
    v_org_id := OLD.organization_id;
    v_user_id := auth.uid();
  END IF;
  
  PERFORM create_audit_log(
    v_org_id, v_user_id, v_action,
    'expenses', COALESCE(NEW.id, OLD.id),
    v_old_data, v_new_data, NULL
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Auto-create audit log for categories
CREATE OR REPLACE FUNCTION audit_category_changes()
RETURNS TRIGGER AS $$
DECLARE
  v_action audit_action;
  v_old_data JSONB;
  v_new_data JSONB;
  v_org_id UUID;
  v_user_id UUID;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_action := 'CREATE';
    v_new_data := to_jsonb(NEW);
    v_org_id := NEW.organization_id;
    v_user_id := NEW.created_by;
  ELSIF TG_OP = 'UPDATE' THEN
    v_action := 'UPDATE';
    v_old_data := to_jsonb(OLD);
    v_new_data := to_jsonb(NEW);
    v_org_id := NEW.organization_id;
    v_user_id := auth.uid();
  ELSIF TG_OP = 'DELETE' THEN
    v_action := 'DELETE';
    v_old_data := to_jsonb(OLD);
    v_org_id := OLD.organization_id;
    v_user_id := auth.uid();
  END IF;
  
  PERFORM create_audit_log(
    v_org_id, v_user_id, v_action,
    'categories', COALESCE(NEW.id, OLD.id),
    v_old_data, v_new_data, NULL
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Calculate spent amount for a category in a date range
CREATE OR REPLACE FUNCTION calculate_category_spent(
  p_category_id BIGINT,
  p_start_date DATE DEFAULT NULL,
  p_end_date DATE DEFAULT NULL
)
RETURNS REAL AS $$
DECLARE
  v_spent REAL;
BEGIN
  SELECT COALESCE(SUM(amount), 0) INTO v_spent
  FROM expenses
  WHERE category_id = p_category_id
    AND (p_start_date IS NULL OR date >= p_start_date)
    AND (p_end_date IS NULL OR date <= p_end_date);
  
  RETURN v_spent;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Updated_at triggers
CREATE TRIGGER set_organizations_updated_at
  BEFORE UPDATE ON organizations
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER set_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER set_categories_updated_at
  BEFORE UPDATE ON categories
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER set_expenses_updated_at
  BEFORE UPDATE ON expenses
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER set_budgets_updated_at
  BEFORE UPDATE ON budgets
  FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- Audit triggers
CREATE TRIGGER audit_expenses_trigger
  AFTER INSERT OR UPDATE OR DELETE ON expenses
  FOR EACH ROW EXECUTE FUNCTION audit_expense_changes();

CREATE TRIGGER audit_categories_trigger
  AFTER INSERT OR UPDATE OR DELETE ON categories
  FOR EACH ROW EXECUTE FUNCTION audit_category_changes();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- ORGANIZATIONS POLICIES
-- =====================================================

-- Owner can view all organizations
CREATE POLICY "owner_select_all_orgs"
  ON organizations FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'owner'
    )
  );

-- Members can view their own organization
CREATE POLICY "members_select_own_org"
  ON organizations FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND organization_id = organizations.id
    )
  );

-- Anyone can create organization (for manager signup)
CREATE POLICY "anyone_insert_pending_org"
  ON organizations FOR INSERT
  TO authenticated
  WITH CHECK (status = 'pending');

-- Owner can update any organization (approve/reject)
CREATE POLICY "owner_update_orgs"
  ON organizations FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'owner'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'owner'
    )
  );

-- Manager can update their own organization (settings only)
CREATE POLICY "manager_update_own_org"
  ON organizations FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND role = 'manager'
      AND organization_id = organizations.id
    )
    -- Cannot change status
    AND status = (SELECT status FROM organizations WHERE id = organizations.id)
  );

-- =====================================================
-- USER PROFILES POLICIES
-- =====================================================

-- Users can view own profile
CREATE POLICY "users_select_own_profile"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- Members can view profiles in their organization
CREATE POLICY "members_select_org_profiles"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (
    organization_id IS NOT NULL
    AND organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
  );

-- Owner can view all profiles
CREATE POLICY "owner_select_all_profiles"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'owner'
    )
  );

-- Allow inserting own profile (for signup)
CREATE POLICY "users_insert_own_profile"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

-- Manager can insert employee profiles in their org
CREATE POLICY "manager_insert_employees"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (
    role = 'employee'
    AND organization_id = (
      SELECT organization_id FROM user_profiles
      WHERE id = auth.uid() AND role = 'manager'
    )
  );

-- Users can update own profile
CREATE POLICY "users_update_own_profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Manager can update/deactivate employees in their org
CREATE POLICY "manager_update_employees"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (
    role = 'employee'
    AND organization_id = (
      SELECT organization_id FROM user_profiles
      WHERE id = auth.uid() AND role = 'manager'
    )
  );

-- Owner can update any profile (for activation)
CREATE POLICY "owner_update_profiles"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'owner'
    )
  );

-- =====================================================
-- CATEGORIES POLICIES
-- =====================================================

-- Members can view categories in their organization
CREATE POLICY "members_select_org_categories"
  ON categories FOR SELECT
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
  );

-- Members can create categories in their organization
CREATE POLICY "members_insert_org_categories"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK (
    organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
    AND created_by = auth.uid()
  );

-- Members can update categories in their organization
CREATE POLICY "members_update_org_categories"
  ON categories FOR UPDATE
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
  );

-- Members can delete categories in their organization
CREATE POLICY "members_delete_org_categories"
  ON categories FOR DELETE
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
  );

-- =====================================================
-- EXPENSES POLICIES
-- =====================================================

-- Members can view expenses in their organization
CREATE POLICY "members_select_org_expenses"
  ON expenses FOR SELECT
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
  );

-- Members can create expenses in their organization
CREATE POLICY "members_insert_org_expenses"
  ON expenses FOR INSERT
  TO authenticated
  WITH CHECK (
    organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
    AND created_by = auth.uid()
  );

-- Members can update expenses in their organization
CREATE POLICY "members_update_org_expenses"
  ON expenses FOR UPDATE
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
  );

-- Members can delete expenses in their organization
CREATE POLICY "members_delete_org_expenses"
  ON expenses FOR DELETE
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
  );

-- =====================================================
-- BUDGETS POLICIES
-- =====================================================

-- Members can view budgets in their organization
CREATE POLICY "members_select_org_budgets"
  ON budgets FOR SELECT
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id FROM user_profiles WHERE id = auth.uid()
    )
  );

-- Manager can manage budgets
CREATE POLICY "manager_manage_org_budgets"
  ON budgets FOR ALL
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id FROM user_profiles
      WHERE id = auth.uid() AND role = 'manager'
    )
  );

-- =====================================================
-- AUDIT LOGS POLICIES
-- =====================================================

-- Manager can view audit logs for their organization
CREATE POLICY "manager_select_org_audit_logs"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (
    organization_id = (
      SELECT organization_id FROM user_profiles
      WHERE id = auth.uid() AND role = 'manager'
    )
  );

-- Owner can view all audit logs
CREATE POLICY "owner_select_all_audit_logs"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'owner'
    )
  );

-- System inserts audit logs (via security definer function)
CREATE POLICY "system_insert_audit_logs"
  ON audit_logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- =====================================================
-- STORAGE POLICIES (for receipts bucket)
-- =====================================================
-- Run these AFTER creating the 'receipts' bucket in Supabase Dashboard

-- Storage bucket structure: receipts/{organization_id}/{expense_id}_{filename}

-- Members can upload receipts for their organization
CREATE POLICY "members_upload_org_receipts"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'receipts'
    AND (storage.foldername(name))[1] = (
      SELECT organization_id::TEXT FROM user_profiles WHERE id = auth.uid()
    )
  );

-- Members can view receipts from their organization
CREATE POLICY "members_view_org_receipts"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'receipts'
    AND (storage.foldername(name))[1] = (
      SELECT organization_id::TEXT FROM user_profiles WHERE id = auth.uid()
    )
  );

-- Members can update receipts in their organization
CREATE POLICY "members_update_org_receipts"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'receipts'
    AND (storage.foldername(name))[1] = (
      SELECT organization_id::TEXT FROM user_profiles WHERE id = auth.uid()
    )
  );

-- Members can delete receipts from their organization
CREATE POLICY "members_delete_org_receipts"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'receipts'
    AND (storage.foldername(name))[1] = (
      SELECT organization_id::TEXT FROM user_profiles WHERE id = auth.uid()
    )
  );

-- =====================================================
-- VIEWS (for common queries)
-- =====================================================

-- Category with calculated spent amount (current month)
CREATE OR REPLACE VIEW categories_with_spent AS
SELECT 
  c.*,
  COALESCE(SUM(e.amount), 0) AS spent_this_month,
  COALESCE(SUM(CASE WHEN e.date >= DATE_TRUNC('year', CURRENT_DATE) THEN e.amount ELSE 0 END), 0) AS spent_this_year
FROM categories c
LEFT JOIN expenses e ON e.category_id = c.id 
  AND e.date >= DATE_TRUNC('month', CURRENT_DATE)
  AND e.date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP BY c.id;

-- Organization summary
CREATE OR REPLACE VIEW organization_summary AS
SELECT 
  o.id,
  o.name,
  o.status,
  o.currency,
  COUNT(DISTINCT up.id) AS member_count,
  COUNT(DISTINCT c.id) AS category_count,
  COUNT(DISTINCT e.id) AS expense_count,
  COALESCE(SUM(e.amount), 0) AS total_spent
FROM organizations o
LEFT JOIN user_profiles up ON up.organization_id = o.id
LEFT JOIN categories c ON c.organization_id = o.id
LEFT JOIN expenses e ON e.organization_id = o.id
GROUP BY o.id;

-- =====================================================
-- ENABLE REALTIME
-- =====================================================
-- Run these to enable real-time subscriptions

ALTER PUBLICATION supabase_realtime ADD TABLE expenses;
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
ALTER PUBLICATION supabase_realtime ADD TABLE user_profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE organizations;
ALTER PUBLICATION supabase_realtime ADD TABLE budgets;

-- =====================================================
-- INITIAL SETUP
-- =====================================================

-- Step 1: Create owner account in Supabase Auth Dashboard
-- Step 2: Run this SQL replacing YOUR_OWNER_UUID with actual UUID:

/*
INSERT INTO user_profiles (id, email, full_name, role, organization_id, is_active)
VALUES (
  'YOUR_OWNER_UUID_HERE',
  'owner@yourcompany.com',
  'App Owner',
  'owner',
  NULL,
  TRUE
);
*/

-- =====================================================
-- HELPER QUERIES
-- =====================================================

-- View pending manager signups
-- SELECT * FROM organizations WHERE status = 'pending' ORDER BY created_at DESC;

-- Approve an organization
-- UPDATE organizations SET status = 'approved', approved_by = 'OWNER_UUID', approved_at = NOW() WHERE id = 'ORG_UUID';
-- UPDATE user_profiles SET is_active = TRUE WHERE organization_id = 'ORG_UUID' AND role = 'manager';

-- View organization members
-- SELECT * FROM user_profiles WHERE organization_id = 'ORG_UUID';

-- View expenses for a date range
-- SELECT * FROM expenses WHERE organization_id = 'ORG_UUID' AND date BETWEEN '2026-01-01' AND '2026-01-31';

-- View audit logs for an organization
-- SELECT * FROM audit_logs WHERE organization_id = 'ORG_UUID' ORDER BY created_at DESC LIMIT 100;

-- Calculate category spending
-- SELECT name, budget, calculate_category_spent(id, DATE_TRUNC('month', CURRENT_DATE)::DATE, CURRENT_DATE) as spent
-- FROM categories WHERE organization_id = 'ORG_UUID';
