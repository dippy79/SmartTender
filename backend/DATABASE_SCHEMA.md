# Smart Tender Engine - Database Schema Design

This document outlines the PostgreSQL database design for the Smart Tender Engine application.

## 1. Users

The users table stores authentication and profile information for system users.

**Fields:**
- `id` - Primary key, unique identifier for each user
- `email` - Unique email address for login
- `password_hash` - Hashed password for authentication
- `full_name` - User's full name
- `role` - User role (e.g., admin, manager, user)
- `created_at` - Timestamp when user was created
- `updated_at` - Timestamp when user was last updated

**Relationships:**
- One user can create multiple saved quotations (one-to-many)
- One user can be the owner of multiple BOQ items through quotations (one-to-many)

---

## 2. Business Types

The business_types table stores different categories or types of businesses that can be used for tender classification.

**Fields:**
- `id` - Primary key, unique identifier
- `name` - Name of the business type (e.g., Construction, IT Services, Manufacturing)
- `description` - Optional description of the business type
- `is_active` - Boolean flag to indicate if the business type is active
- `created_at` - Timestamp when record was created
- `updated_at` - Timestamp when record was last updated

**Relationships:**
- One business type can have multiple rates in the rate master (one-to-many)
- One business type can be associated with multiple BOQ items (one-to-many)

---

## 3. Rate Master

The rate_master table stores standard rates/pricing information that can be applied to BOQ items.

**Fields:**
- `id` - Primary key, unique identifier
- `business_type_id` - Foreign key referencing business_types
- `item_code` - Unique code for the item/service
- `item_name` - Name of the item or service
- `unit` - Unit of measurement (e.g., sqft, kg, hour)
- `base_rate` - Standard base rate for the item
- `markup_percentage` - Default markup percentage
- `tax_percentage` - Applicable tax percentage
- `effective_from` - Date from which the rate is effective
- `effective_to` - Date until which the rate is valid (nullable for indefinite)
- `is_active` - Boolean flag to indicate if rate is currently active
- `created_at` - Timestamp when record was created
- `updated_at` - Timestamp when record was last updated

**Relationships:**
- Many rates belong to one business type (many-to-one)
- One rate can be referenced by multiple BOQ items (one-to-many)

---

## 4. BOQ Items

The boq_items table stores individual line items within a Bill of Quantities for a quotation.

**Fields:**
- `id` - Primary key, unique identifier
- `quotation_id` - Foreign key referencing saved_quotations
- `business_type_id` - Foreign key referencing business_types
- `rate_id` - Foreign key referencing rate_master (nullable, for manual entries)
- `item_code` - Code for the item
- `item_name` - Description/name of the item
- `quantity` - Amount/quantity of the item
- `unit` - Unit of measurement
- `base_rate` - Rate per unit (can be from rate_master or manually entered)
- `markup_percentage` - Markup applied to base rate
- `tax_percentage` - Tax percentage applied
- `total_amount` - Calculated total (quantity × base_rate × markup × tax)
- `remarks` - Optional notes for the item
- `created_at` - Timestamp when item was created
- `updated_at` - Timestamp when item was last updated

**Relationships:**
- Many BOQ items belong to one quotation (many-to-one)
- Many BOQ items can reference one business type (many-to-one)
- Many BOQ items can reference one rate from rate master (many-to-one, optional)

---

## 5. Saved Quotations

The saved_quotations table stores the main quotation/tender documents created by users.

**Fields:**
- `id` - Primary key, unique identifier
- `user_id` - Foreign key referencing users (owner of the quotation)
- `quotation_number` - Unique quotation reference number
- `title` - Title/name of the quotation
- `client_name` - Name of the client/customer
- `client_details` - Additional client information (JSON or text)
- `business_type_id` - Foreign key referencing business_types
- `subtotal` - Sum of all items before tax and markup
- `total_markup_amount` - Total markup applied across all items
- `total_tax_amount` - Total tax amount
- `grand_total` - Final calculated total
- `status` - Status of quotation (draft, submitted, accepted, rejected)
- `valid_until` - Date until which the quotation is valid
- `notes` - Additional notes or terms
- `created_at` - Timestamp when quotation was created
- `updated_at` - Timestamp when quotation was last updated

**Relationships:**
- One user can have multiple saved quotations (one-to-many)
- One business type can be associated with multiple quotations (one-to-many)
- One quotation can have multiple BOQ items (one-to-many)

---

## Entity Relationship Summary

```
Users (1) ──────< (N) Saved Quotations (1) ──────< (N) BOQ Items
  │                                            │
  │                                            └── (N) Business Types
  │                                                 │
  │                                                 └── (N) Rate Master
  │
  └── (1) Business Types
```

### Key Relationships:
1. **Users → Saved Quotations**: One user can create multiple quotations
2. **Business Types → Rate Master**: One business type has multiple rate entries
3. **Business Types → BOQ Items**: One business type can have multiple line items
4. **Rate Master → BOQ Items**: One rate can be used in multiple BOQ items (optional)
5. **Saved Quotations → BOQ Items**: One quotation contains multiple line items

### Notes:
- All tables include `created_at` and `updated_at` timestamps for audit purposes
- Foreign key constraints should be used to maintain data integrity
- Indexes should be created on frequently queried fields (e.g., user_id, quotation_id, business_type_id)
- The `is_active` flag in business_types and rate_master allows for soft deletion and historical rate tracking
