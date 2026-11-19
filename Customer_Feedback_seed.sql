-- 1. SEED: pharmacy_reviews

INSERT INTO pharmacy_reviews (
    review_id,
    order_id,
    rating,
    comment,
    status,
    merchant_reply,
    replied_at,
    moderation_reason,
    created_at,
    updated_at
)
VALUES (
    value1, value2, value3, value4,
    value5, value6, value7, value8,
    value9, value10
);


-- 2. SEED: problem_reports

INSERT INTO problem_reports (
    report_id,
    user_id,
    order_id,
    merchant_id,
    category,
    description,
    status,
    admin_notes,
    resolution_note,
    created_at,
    updated_at
)
VALUES (
    value1, value2, value3, value4,
    value5, value6, value7, value8,
    value9, value10, value11
);
