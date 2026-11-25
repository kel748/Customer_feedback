# FEEDBACK MODULE DATABASE
## PostgreSQL Database Structure and Connectivity

*Database Module:* feedback_module (M9)
*Database Platform:* PostgreSQL (Supabase)

**Files:** `Customer_Feedback.psql` (tables), `Customer_Feedback_seed.sql` (sample data), `Customer_Feedback_database.md` (this document)

**Run order:** `Customer_Feedback.psql`, then `Customer_Feedback_seed.sql`.

---

# 1. TABLE: pharmacy_reviews

## Table Structure

| Column Name | Data Type | Constraint |
|---|---|---|
| review_id | UUID | PRIMARY KEY, DEFAULT gen_random_uuid() |
| order_id | UUID | NOT NULL, UNIQUE, FOREIGN KEY (Pending) |
| rating | SMALLINT | NOT NULL, CHECK (1-5) |
| comment | TEXT | NULL |
| tags | TEXT[] | NULL |
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

**Quick tags:** the tags column stores the quick tags the resident picks when rating (for example: Fast delivery, Friendly staff). It is a single TEXT[] column because the tags are a fixed list that is not queried separately. It can be NULL when no tag is picked.

## SQL Code

```sql
CREATE TABLE pharmacy_reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE,
    rating SMALLINT NOT NULL
        CHECK (rating BETWEEN 1 AND 5),
    comment TEXT NULL,
    tags TEXT[] NULL,
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
| search_id | UUID | NULL, FOREIGN KEY (Pending) |
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

## Connectivity 4: search_id

- Foreign Key: search_id
- Reference Database: locator (Module 8)
- Reference Table: to be confirmed with Module 8
- Reference Column: to be confirmed with Module 8
- Cardinality: Many-to-One (M:1)
- This Table: Many
- Reference Table: One
- Status: Pending connection (no foreign key constraint yet)
- Note: NULL when the report is not made from the Locator. It lets Module 8 trace a report back to the search that showed the wrong information.

## SQL Code

```sql
CREATE TABLE problem_reports (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    order_id UUID NULL,
    merchant_id UUID NULL,
    search_id UUID NULL,
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
| problem_reports | search_id | Module 8 search table (to be confirmed) | to be confirmed | Many-to-One (pending) |

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
   - The tags column in pharmacy_reviews stores the quick tags as a list. It is a column and not a separate table because the tags are a fixed list.
   - The search_id column in problem_reports is optional. It is only filled when the report is made from the Locator (Module 8). Its foreign key is pending because the Module 8 table is not in this database yet.
10. moderation_reason, admin_notes and resolution_note are not in the column tables of the database design, but its rules mention them. They must be confirmed with M7.
11. Customer_Feedback.psql creates simple versions of users, merchant_profiles and orders (with create table if not exists) so the foreign keys work. Delete that part if these tables already exist from the other modules.
12. The seed uses sample IDs for the pending connections (user_id, order_id, merchant_id, search_id). Replace them with real IDs from the other modules after the foreign keys are added.
13. The rules that only the resident who placed a delivered order can review it, and that a merchant can only reply to their own pharmacy's reviews, are handled by the backend.
