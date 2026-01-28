// PHA Inspection System Database Schema for dbdiagram.io
// Copy this entire code and paste it into dbdiagram.io

Project PHA_Inspection_System {
  database_type: 'PostgreSQL'
  Note: '''
    # PHA (Philadelphia Housing Authority) Inspection System
    
    This database schema supports a comprehensive housing inspection system for:
    - Managing inspection service orders
    - Tracking inspection responses across different areas/rooms
    - Storing PMI checklist data
    - Managing tenant acknowledgments and signatures
    - Handling inspection images and documentation
    
    **Areas covered:**
    - Scattered (SS)
    - Conventional (CS) 
    - AMPB
    - PAPMC
  '''
}

// Areas/Divisions lookup table
Table areas {
  id integer [pk, increment]
  code varchar(10) [unique, not null, note: 'SS=Scattered, CS=Conventional, AMPB, PAPMC']
  name varchar(50) [not null]
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  Note: 'Housing area classifications'
}

// Sites table
Table sites {
  id integer [pk, increment]
  site_code varchar(10) [unique, not null, note: 'e.g., 901, 902, 903']
  site_name varchar(255) [not null, note: 'e.g., Haddington, Mantua']
  area_id integer [ref: > areas.id]
  address text
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  updated_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  Note: 'Individual housing sites within areas'
}

// Units table  
Table units {
  id integer [pk, increment]
  unit_number varchar(50) [not null, note: 'e.g., 041529']
  site_id integer [ref: > sites.id]
  br_size integer [note: 'Number of bedrooms']
  is_hardwired boolean [default: false, note: 'Unit hardwired status']
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  updated_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  indexes {
    (unit_number, site_id) [unique]
  }
  
  Note: 'Individual housing units within sites'
}

// Tenants table
Table tenants {
  id integer [pk, increment]
  name varchar(255) [not null]
  phone varchar(20)
  unit_id integer [ref: > units.id]
  availability boolean [default: true, note: 'Tenant available for inspection']
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  updated_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  Note: 'Tenant information for each unit'
}

// Inspectors table
Table inspectors {
  id integer [pk, increment]
  name varchar(255) [not null, note: 'e.g., CASTOR_USER5']
  vehicle_tag_id varchar(50) [note: 'e.g., Q, R, S']
  active boolean [default: true]
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  Note: 'Housing inspectors conducting inspections'
}

// Inspection Service Orders (Main inspection records)
Table inspection_orders {
  id integer [pk, increment]
  so_number varchar(20) [unique, not null, note: 'e.g., 3184947']
  unit_id integer [ref: > units.id]
  inspector_id integer [ref: > inspectors.id]
  tenant_id integer [ref: > tenants.id]
  status varchar(20) [default: 'New', note: 'New, InProgress, Closed']
  start_date date
  start_time time
  end_date date  
  end_time time
  submit_time timestamp
  smoke_detectors_count integer [default: 0]
  co_detectors_count integer [default: 0]
  completion_date date
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  updated_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  indexes {
    so_number [name: 'idx_so_number']
    unit_id [name: 'idx_unit_id']
    status [name: 'idx_status']
    start_date [name: 'idx_start_date']
  }
  
  Note: 'Main inspection service orders'
}

// PMI Checklist categories
Table pmi_categories {
  id integer [pk, increment]
  name varchar(255) [not null, note: 'HVAC, HOT WATER TANK, SMOKE DETECTORS, etc.']
  sort_order integer [default: 0]
  
  Note: 'Categories for PMI (Property Management Inspection) checklist'
}

// PMI Checklist items
Table pmi_items {
  id integer [pk, increment]
  category_id integer [ref: > pmi_categories.id]
  description text [not null]
  sort_order integer [default: 0]
  is_active boolean [default: true]
  
  Note: 'Individual items within PMI categories'
}

// PMI Checklist responses
Table pmi_responses {
  id integer [pk, increment]
  inspection_order_id integer [ref: > inspection_orders.id]
  pmi_item_id integer [ref: > pmi_items.id]
  response varchar(10) [note: 'OK, NA, Def']
  material_used boolean [default: false]
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  indexes {
    (inspection_order_id, pmi_item_id) [unique]
  }
  
  Note: 'Responses to PMI checklist items'
}

// Inspection areas/rooms
Table inspection_areas {
  id integer [pk, increment]
  name varchar(255) [not null, note: 'Site and Building Exterior, Kitchen, etc.']
  sort_order integer [default: 0]
  is_active boolean [default: true]
  
  Note: 'Different areas/rooms inspected in each unit'
}

// Inspection items within each area
Table inspection_items {
  id integer [pk, increment]
  area_id integer [ref: > inspection_areas.id]
  description text [not null, note: 'Specific items to check in each area']
  sort_order integer [default: 0]
  is_active boolean [default: true]
  
  Note: 'Specific inspection items within each area'
}

// Inspection responses for each area/item
Table inspection_responses {
  id integer [pk, increment]
  inspection_order_id integer [ref: > inspection_orders.id]
  inspection_item_id integer [ref: > inspection_items.id]
  response varchar(10) [note: 'OK, NA, Def (Deficiency)']
  scope_of_work text [note: 'Required when response is Def']
  material_required boolean [default: false]
  material_description text
  service_id varchar(50)
  activity_code varchar(50)
  tenant_charge boolean [default: false, note: 'Tenant responsible for repair cost']
  urgent boolean [default: false, note: 'Requires immediate attention']
  rrp boolean [default: false, note: 'Lead paint related']
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  updated_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  indexes {
    (inspection_order_id, inspection_item_id) [unique]
    inspection_order_id [name: 'idx_responses_order_id']
  }
  
  Note: 'Inspector responses for each inspection item'
}

// Images attached to inspections
Table inspection_images {
  id integer [pk, increment]
  inspection_order_id integer [ref: > inspection_orders.id]
  inspection_area_id integer [ref: > inspection_areas.id, null]
  inspection_item_id integer [ref: > inspection_items.id, null]
  filename varchar(255) [not null]
  file_path text [not null]
  file_size integer
  mime_type varchar(100)
  caption text
  taken_at timestamp
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  Note: 'Images captured during inspections'
}

// Tenant acknowledgment signatures
Table tenant_signatures {
  id integer [pk, increment]
  inspection_order_id integer [ref: - inspection_orders.id, note: 'One-to-one relationship']
  signature_data text [note: 'Base64 encoded signature image']
  signed_at timestamp [default: `CURRENT_TIMESTAMP`]
  tenant_agreed boolean [default: true]
  
  Note: 'Digital signatures from tenants acknowledging inspection results'
}

// Extraordinary circumstances
Table extraordinary_circumstances {
  id integer [pk, increment]
  inspection_order_id integer [ref: > inspection_orders.id]
  circumstance text [not null]
  comment text
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  
  Note: 'Special circumstances noted during inspection'
}

// Open Service Orders tracking
Table open_service_orders {
  id integer [pk, increment]
  unit_id integer [ref: > units.id]
  service_order_number varchar(50) [not null]
  problem_description text
  case_id varchar(50)
  service_type varchar(100) [note: 'PLUMBING, PAINTING, EXTERMINATION, etc.']
  status varchar(50) [default: 'Open']
  created_at timestamp [default: `CURRENT_TIMESTAMP`]
  resolved_at timestamp [null]
  
  Note: 'Outstanding service orders for units'
}