# FEEDBACK MODULE DATABASE
## PostgreSQL Database Structure and Connectivity

*Database Module:* feedback_module (M9)
*Database Platform:* PostgreSQL (Supabase)

**Files:** `FeedbackModule.psql` (tables), `FeedbackModule_seed.sql` (sample data), `FeedbackModule_database.md` (this document)

**Run order:** `FeedbackModule.psql`, then `FeedbackModule_seed.sql`.

---

# 1. TABLE: pharmacy_reviews

## Table Structure

| Column Name | Data Type | Constraint |
|---|---|---|
| review_id | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() |
| order_id | UUID | NOT NULL, UNIQUE, FOREIGN KEY (Pending) |
| rating | SMALLINT | NOT NULL, CHECK (1-5) |
| comment | TEXT | NULL |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'visible', CHECK ('visible', 'hidden') |
| merchant_reply | TEXT | NULL |
| replied_at | TIMESTAMPTZ | NULL |
| moderation_reason | TEXT | NULL |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() |

## Connectivity: order_id

- Foreign Key: order_id
- Reference Database: order_management
- Reference Table: orders
- Reference Column: order_id (PK)
- Cardinality: One-to-One (1:1)
- This Table: One
- Reference Table: One
- Status: Pending connection

The reviewer is found through orders.user_id and the pharmacy through orders.merchant_id, so resident and pharmacy IDs are not duplicated in this table.

## SQL Code

```sql
CREATE TABLE pharmacy_reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE,
    rating SMALLINT NOT NULL
        CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'visible'
        CHECK (status IN ('visible', 'hidden')),
    merchant_reply TEXT NULL,
    replied_at TIMESTAMPTZ NULL,
    moderation_reason TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

# 2. TABLE: problem_reports

## Table Structure

| Column Name | Data Type | Constraint |
|---|---|---|
| report_id | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() |
| user_id | UUID | NOT NULL, FOREIGN KEY (Pending) |
| order_id | UUID | NULL, FOREIGN KEY (Pending) |
| merchant_id | UUID | NULL, FOREIGN KEY (Pending) |
| category | VARCHAR(50) | NOT NULL, CHECK (7 allowed values) |
| description | TEXT | NOT NULL, CHECK (not empty) |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'open', CHECK (4 allowed values) |
| admin_notes | TEXT | NULL |
| resolution_note | TEXT | NULL |
| created_at | TIMESTAMPTZ | DEFAULT NOW() |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() |

**Category values:** order_issue, payment_issue, delivery_issue, pharmacy_issue, product_issue, account_issue, other

**Status values:** open, acknowledged, resolved, dismissed

## Connectivity 1: user_id

- Foreign Key: user_id
- Reference Database: user_address
- Reference Table: users
- Reference Column: user_id (PK)
- Cardinality: Many-to-One (M:1)
- This Table: Many
- Reference Table: One
- Status: Pending connection

## Connectivity 2: order_id

- Foreign Key: order_id
- Reference Database: order_management
- Reference Table: orders
- Reference Column: order_id (PK)
- Cardinality: Many-to-One (M:1)
- This Table: Many
- Reference Table: One
- Status: Pending connection

## Connectivity 3: merchant_id

- Foreign Key: merchant_id
- Reference Database: store_module
- Reference Table: merchant_profiles
- Reference Column: merchant_id (PK)
- Cardinality: Many-to-One (M:1)
- This Table: Many
- Reference Table: One
- Status: Pending connection

## SQL Code

```sql
CREATE TABLE problem_reports (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    order_id UUID NULL,
    merchant_id UUID NULL,
    category VARCHAR(50) NOT NULL
        CHECK (category IN (
            'order_issue', 'payment_issue', 'delivery_issue',
            'pharmacy_issue', 'product_issue', 'account_issue', 'other'
        )),
    description TEXT NOT NULL
        CHECK (LENGTH(TRIM(description)) > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'open'
        CHECK (status IN ('open', 'acknowledged', 'resolved', 'dismissed')),
    admin_notes TEXT NULL,
    resolution_note TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

# 3. RELATIONSHIP SUMMARY

| Child Table | Foreign Key | Parent Table | Referenced Column | Cardinality |
|---|---|---|---|---|
| pharmacy_reviews | order_id | orders | order_id | One-to-One |
| problem_reports | user_id | users | user_id | Many-to-One |
| problem_reports | order_id | orders | order_id | Many-to-One |
| problem_reports | merchant_id | merchant_profiles | merchant_id | Many-to-One |

---

# 4. DATABASE NOTES

1. The database contains two tables.
2. One order can receive only one pharmacy review (order_id is UNIQUE).
3. The rating must be from 1 to 5.
4. The reviewer is found through orders.user_id and the pharmacy through orders.merchant_id.
5. A merchant reply is saved in merchant_reply and replied_at. An administrator hides a review by setting status to hidden and writing moderation_reason.
6. order_id and merchant_id in problem_reports can be NULL when the complaint is not about an order or a pharmacy.
7. For rider-related complaints, the rider is found through the order and delivery relationship.
8. One table is used for all complaint categories.
9. The description cannot be empty.
10. moderation_reason, admin_notes and resolution_note are not in the column tables of the database design, but its rules mention them. They must be confirmed with M7.
11. The foreign keys are pending. They are written at the bottom of FeedbackModule.psql (commented out) and are added once users, orders and merchant_profiles exist in the same database.
12. The seed uses sample IDs for the pending connections (user_id, order_id, merchant_id). Replace them with real IDs from the other modules after the foreign keys are added.
13. The rules that only the resident who placed a delivered order can review it, and that a merchant can only reply to their own pharmacy's reviews, are handled by the backend.
