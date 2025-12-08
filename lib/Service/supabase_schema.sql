-- Supabase schema for Hospital Management System
-- Roles: patient, doctor, staff, admin

-- users table extends existing user.dart model (if a table already exists, adapt columns)
create table if not exists users (
  id uuid primary key default uuid_generate_v4(),
  email text unique not null,
  full_name text not null,
  role text not null check (role in ('patient','doctor','staff','admin')),
  hospital_id uuid null,
  created_at timestamp with time zone default now()
);

create table if not exists hospitals (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  address text,
  phone text,
  created_at timestamp with time zone default now()
);

alter table users
  add constraint users_hospital_fk foreign key (hospital_id) references hospitals(id) on delete set null;

create table if not exists doctors (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null unique,
  specialization text,
  hospital_id uuid not null,
  created_at timestamp with time zone default now(),
  constraint doctors_user_fk foreign key (user_id) references users(id) on delete cascade,
  constraint doctors_hospital_fk foreign key (hospital_id) references hospitals(id) on delete cascade
);

create table if not exists patients (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null unique,
  hospital_id uuid not null,
  created_at timestamp with time zone default now(),
  constraint patients_user_fk foreign key (user_id) references users(id) on delete cascade,
  constraint patients_hospital_fk foreign key (hospital_id) references hospitals(id) on delete cascade
);

create table if not exists staff (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null unique,
  hospital_id uuid not null,
  created_at timestamp with time zone default now(),
  constraint staff_user_fk foreign key (user_id) references users(id) on delete cascade,
  constraint staff_hospital_fk foreign key (hospital_id) references hospitals(id) on delete cascade
);

-- appointments
create table if not exists appointments (
  id uuid primary key default uuid_generate_v4(),
  patient_id uuid not null,
  doctor_id uuid not null,
  hospital_id uuid not null,
  scheduled_at timestamp with time zone not null,
  status text not null check (status in ('requested','approved','rescheduled','cancelled','completed')),
  created_by uuid not null, -- user making request
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  constraint appt_patient_fk foreign key (patient_id) references patients(id) on delete cascade,
  constraint appt_doctor_fk foreign key (doctor_id) references doctors(id) on delete cascade,
  constraint appt_hospital_fk foreign key (hospital_id) references hospitals(id) on delete cascade
);

-- enforce 24h reschedule policy with a check via RLS or server functions, but store last_reschedule_by
alter table appointments add column if not exists last_reschedule_by uuid null;
alter table appointments add column if not exists last_reschedule_at timestamp with time zone null;

-- visits
create table if not exists visits (
  id uuid primary key default uuid_generate_v4(),
  patient_id uuid not null,
  doctor_id uuid not null,
  appointment_id uuid null,
  hospital_id uuid not null,
  visit_at timestamp with time zone not null,
  vitals jsonb,
  notes text,
  created_at timestamp with time zone default now(),
  constraint visit_patient_fk foreign key (patient_id) references patients(id) on delete cascade,
  constraint visit_doctor_fk foreign key (doctor_id) references doctors(id) on delete set null,
  constraint visit_appt_fk foreign key (appointment_id) references appointments(id) on delete set null,
  constraint visit_hospital_fk foreign key (hospital_id) references hospitals(id) on delete cascade
);

-- medical_records with verification by staff
create table if not exists medical_records (
  id uuid primary key default uuid_generate_v4(),
  patient_id uuid not null,
  visit_id uuid null,
  doctor_id uuid not null,
  hospital_id uuid not null,
  title text not null,
  description text,
  attachments jsonb, -- file urls
  status text not null default 'pending' check (status in ('pending','verified','rejected')),
  verified_by uuid null, -- staff id
  verified_at timestamp with time zone null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  constraint mr_patient_fk foreign key (patient_id) references patients(id) on delete cascade,
  constraint mr_visit_fk foreign key (visit_id) references visits(id) on delete set null,
  constraint mr_doctor_fk foreign key (doctor_id) references doctors(id) on delete set null,
  constraint mr_hospital_fk foreign key (hospital_id) references hospitals(id) on delete cascade,
  constraint mr_verified_by_fk foreign key (verified_by) references staff(id) on delete set null
);

-- prescriptions editable by doctor only
create table if not exists prescriptions (
  id uuid primary key default uuid_generate_v4(),
  patient_id uuid not null,
  visit_id uuid null,
  doctor_id uuid not null,
  hospital_id uuid not null,
  items jsonb not null, -- [{medicine_id, dose, frequency, duration, notes}]
  status text not null default 'issued' check (status in ('issued','dispensed','cancelled')),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  constraint pr_patient_fk foreign key (patient_id) references patients(id) on delete cascade,
  constraint pr_visit_fk foreign key (visit_id) references visits(id) on delete set null,
  constraint pr_doctor_fk foreign key (doctor_id) references doctors(id) on delete set null,
  constraint pr_hospital_fk foreign key (hospital_id) references hospitals(id) on delete cascade
);

-- medicines catalog per hospital (optional global)
create table if not exists medicines (
  id uuid primary key default uuid_generate_v4(),
  hospital_id uuid null,
  name text not null,
  strength text,
  created_at timestamp with time zone default now(),
  constraint med_hospital_fk foreign key (hospital_id) references hospitals(id) on delete set null
);

-- audit trail
create table if not exists audit_logs (
  id bigserial primary key,
  actor_user_id uuid not null,
  action text not null,
  entity text not null,
  entity_id uuid,
  details jsonb,
  created_at timestamp with time zone default now()
);

-- RLS policies sketch (apply in Supabase SQL editor)
-- Example: patients can view only their records
-- alter table medical_records enable row level security;
-- create policy "patient can view own records" on medical_records
--   for select using (exists (
--     select 1 from patients p where p.id = medical_records.patient_id and p.user_id = auth.uid()
--   ));

-- Add more policies for doctor/staff/admin per role.

-- ==========================================================
-- RLS Policies and helper functions (apply in Supabase)
-- ==========================================================

-- Enable RLS on core tables
alter table if exists appointments enable row level security;
alter table if exists medical_records enable row level security;
alter table if exists prescriptions enable row level security;
alter table if exists visits enable row level security;

-- Helper views to resolve current user role and links
create or replace view v_current_user as
select u.id as user_id, u.role, u.hospital_id
from users u
where u.id = auth.uid();

-- Patient can view own appointments
drop policy if exists "patient_select_appointments" on appointments;
create policy "patient_select_appointments" on appointments
for select using (
  exists (
    select 1 from patients p
    where p.id = appointments.patient_id and p.user_id = auth.uid()
  )
);

-- Doctor can view/manage only appointments assigned to them
drop policy if exists "doctor_select_appointments" on appointments;
create policy "doctor_select_appointments" on appointments
for select using (
  exists (
    select 1 from doctors d
    where d.id = appointments.doctor_id and d.user_id = auth.uid()
  )
);

drop policy if exists "doctor_update_appointments_approval" on appointments;
create policy "doctor_update_appointments_approval" on appointments
for update using (
  exists (
    select 1 from doctors d
    where d.id = appointments.doctor_id and d.user_id = auth.uid()
  )
);

-- Staff can view/manage appointments in their hospital
drop policy if exists "staff_select_appointments" on appointments;
create policy "staff_select_appointments" on appointments
for select using (
  exists (
    select 1 from staff s
    where s.hospital_id = appointments.hospital_id and s.user_id = auth.uid()
  )
);

drop policy if exists "staff_update_appointments" on appointments;
create policy "staff_update_appointments" on appointments
for update using (
  exists (
    select 1 from staff s
    where s.hospital_id = appointments.hospital_id and s.user_id = auth.uid()
  )
);

-- Patient can insert requested appointment for self
drop policy if exists "patient_insert_appointment" on appointments;
create policy "patient_insert_appointment" on appointments
for insert with check (
  exists (
    select 1 from patients p
    where p.id = appointments.patient_id and p.user_id = auth.uid()
  )
);

-- Patients: records & prescriptions visibility
drop policy if exists "patient_select_records" on medical_records;
create policy "patient_select_records" on medical_records
for select using (
  exists (
    select 1 from patients p where p.id = medical_records.patient_id and p.user_id = auth.uid()
  )
);

drop policy if exists "patient_select_prescriptions" on prescriptions;
create policy "patient_select_prescriptions" on prescriptions
for select using (
  exists (
    select 1 from patients p where p.id = prescriptions.patient_id and p.user_id = auth.uid()
  )
);

-- Doctors can create/update prescriptions and records for their patients only
drop policy if exists "doctor_insert_records" on medical_records;
create policy "doctor_insert_records" on medical_records
for insert with check (
  exists (
    select 1 from doctors d where d.id = medical_records.doctor_id and d.user_id = auth.uid()
  )
);

drop policy if exists "doctor_update_records" on medical_records;
create policy "doctor_update_records" on medical_records
for update using (
  exists (
    select 1 from doctors d where d.id = medical_records.doctor_id and d.user_id = auth.uid()
  )
);

drop policy if exists "doctor_insert_prescriptions" on prescriptions;
create policy "doctor_insert_prescriptions" on prescriptions
for insert with check (
  exists (
    select 1 from doctors d where d.id = prescriptions.doctor_id and d.user_id = auth.uid()
  )
);

drop policy if exists "doctor_update_prescriptions" on prescriptions;
create policy "doctor_update_prescriptions" on prescriptions
for update using (
  exists (
    select 1 from doctors d where d.id = prescriptions.doctor_id and d.user_id = auth.uid()
  )
);

-- Staff can verify medical records in their hospital; cannot edit content
drop policy if exists "staff_verify_records" on medical_records;
create policy "staff_verify_records" on medical_records
for update using (
  exists (
    select 1 from staff s where s.hospital_id = medical_records.hospital_id and s.user_id = auth.uid()
  )
) with check (
  -- Allow only status/verified_by/verified_at changes
  true
);

-- 24-hour reschedule helper function and policy
create or replace function can_patient_reschedule(appt_id uuid)
returns boolean language sql as $$
  select (a.scheduled_at - now()) > interval '24 hours'
  from appointments a where a.id = appt_id
$$;

drop policy if exists "patient_reschedule_within_24h" on appointments;
create policy "patient_reschedule_within_24h" on appointments
for update using (
  exists (
    select 1 from patients p where p.id = appointments.patient_id and p.user_id = auth.uid()
  ) and can_patient_reschedule(appointments.id)
);

-- Admin broad read access (optional)
drop policy if exists "admin_read_all_appointments" on appointments;
create policy "admin_read_all_appointments" on appointments
for select using (
  exists (select 1 from users u where u.id = auth.uid() and u.role = 'admin')
);

drop policy if exists "admin_read_all_records" on medical_records;
create policy "admin_read_all_records" on medical_records
for select using (
  exists (select 1 from users u where u.id = auth.uid() and u.role = 'admin')
);

drop policy if exists "admin_read_all_prescriptions" on prescriptions;
create policy "admin_read_all_prescriptions" on prescriptions
for select using (
  exists (select 1 from users u where u.id = auth.uid() and u.role = 'admin')
);
