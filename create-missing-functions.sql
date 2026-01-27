-- ============================================
-- CREATE MISSING POSTGRESQL FUNCTIONS
-- ============================================
-- Fungsi yang dibutuhkan aplikasi tapi belum ada
-- ============================================

-- 1. Function: increment_card_balance
-- Purpose: Atomically update card balance
CREATE OR REPLACE FUNCTION increment_card_balance(
    p_card_id UUID,
    p_delta DECIMAL
)
RETURNS VOID AS $$
BEGIN
    -- Update card balance atomically
    UPDATE cards 
    SET 
        balance = balance + p_delta,
        updated_at = NOW()
    WHERE id = p_card_id;
    
    -- Check if card exists
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Card with id % not found', p_card_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION increment_card_balance IS 'Atomically increment/decrement card balance';

-- 2. Function: create_transaction_with_balance_update
-- Purpose: Create transaction and update card balance atomically
CREATE OR REPLACE FUNCTION create_transaction_with_balance_update(
    p_transaction_data JSONB,
    p_card_id UUID,
    p_amount_delta DECIMAL
)
RETURNS JSONB AS $$
DECLARE
    v_transaction_id UUID;
    v_result JSONB;
BEGIN
    -- Insert transaction
    INSERT INTO transactions (
        date,
        description,
        amount,
        type,
        project_id,
        category,
        method,
        pocket_id,
        card_id,
        printing_item_id,
        vendor_signature
    )
    VALUES (
        (p_transaction_data->>'date')::DATE,
        p_transaction_data->>'description',
        (p_transaction_data->>'amount')::DECIMAL,
        p_transaction_data->>'type',
        CASE 
            WHEN p_transaction_data->>'project_id' = 'null' OR p_transaction_data->>'project_id' IS NULL 
            THEN NULL 
            ELSE (p_transaction_data->>'project_id')::UUID 
        END,
        p_transaction_data->>'category',
        p_transaction_data->>'method',
        CASE 
            WHEN p_transaction_data->>'pocket_id' = 'null' OR p_transaction_data->>'pocket_id' IS NULL 
            THEN NULL 
            ELSE (p_transaction_data->>'pocket_id')::UUID 
        END,
        p_card_id,
        CASE 
            WHEN p_transaction_data->>'printing_item_id' = 'null' OR p_transaction_data->>'printing_item_id' IS NULL 
            THEN NULL 
            ELSE (p_transaction_data->>'printing_item_id')::UUID 
        END,
        p_transaction_data->>'vendor_signature'
    )
    RETURNING id INTO v_transaction_id;
    
    -- Update card balance
    PERFORM increment_card_balance(p_card_id, p_amount_delta);
    
    -- Return the created transaction
    SELECT to_jsonb(t.*) INTO v_result
    FROM transactions t
    WHERE t.id = v_transaction_id;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_transaction_with_balance_update IS 'Create transaction and update card balance atomically';

-- 3. Function: validate_promo_code (if not exists)
-- Purpose: Validate and calculate promo code discount
CREATE OR REPLACE FUNCTION validate_promo_code(
    promo_code_text VARCHAR,
    order_amount DECIMAL
)
RETURNS TABLE (
    is_valid BOOLEAN,
    discount_amount DECIMAL,
    message TEXT
) AS $$
DECLARE
    promo RECORD;
    calculated_discount DECIMAL;
BEGIN
    -- Get promo code
    SELECT * INTO promo FROM promo_codes WHERE code = promo_code_text;
    
    -- Check if exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 0::DECIMAL, 'Kode promo tidak ditemukan';
        RETURN;
    END IF;
    
    -- Check if active
    IF NOT promo.is_active THEN
        RETURN QUERY SELECT false, 0::DECIMAL, 'Kode promo tidak aktif';
        RETURN;
    END IF;
    
    -- Check expiry
    IF promo.expiry_date IS NOT NULL AND promo.expiry_date < CURRENT_DATE THEN
        RETURN QUERY SELECT false, 0::DECIMAL, 'Kode promo sudah kadaluarsa';
        RETURN;
    END IF;
    
    -- Check usage limit
    IF promo.max_usage IS NOT NULL AND promo.usage_count >= promo.max_usage THEN
        RETURN QUERY SELECT false, 0::DECIMAL, 'Kode promo sudah mencapai batas penggunaan';
        RETURN;
    END IF;
    
    -- Calculate discount
    IF promo.discount_type = 'percentage' THEN
        calculated_discount := (order_amount * promo.discount_value / 100);
    ELSE
        calculated_discount := promo.discount_value;
    END IF;
    
    -- Ensure discount doesn't exceed order amount
    IF calculated_discount > order_amount THEN
        calculated_discount := order_amount;
    END IF;
    
    RETURN QUERY SELECT true, calculated_discount, 'Kode promo valid';
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION validate_promo_code IS 'Validate promo code and calculate discount amount';

-- 4. Function: calculate_project_total_cost (if not exists)
-- Purpose: Calculate total project cost including all items and discount
CREATE OR REPLACE FUNCTION calculate_project_total_cost(
    package_price DECIMAL,
    add_ons_total DECIMAL,
    printing_cost DECIMAL,
    transport_cost DECIMAL,
    custom_costs_total DECIMAL,
    discount_amount DECIMAL
)
RETURNS DECIMAL AS $$
BEGIN
    RETURN (package_price + add_ons_total + printing_cost + transport_cost + custom_costs_total) - discount_amount;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_project_total_cost IS 'Calculate total project cost including all items and discount';

-- ============================================
-- VERIFY FUNCTIONS CREATED
-- ============================================

SELECT 'PostgreSQL functions verification:' as info;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'increment_card_balance') 
        THEN '✅ increment_card_balance function created' 
        ELSE '❌ increment_card_balance function missing' 
    END as increment_card_balance_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'create_transaction_with_balance_update') 
        THEN '✅ create_transaction_with_balance_update function created' 
        ELSE '❌ create_transaction_with_balance_update function missing' 
    END as create_transaction_function_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'validate_promo_code') 
        THEN '✅ validate_promo_code function created' 
        ELSE '❌ validate_promo_code function missing' 
    END as validate_promo_code_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_project_total_cost') 
        THEN '✅ calculate_project_total_cost function created' 
        ELSE '❌ calculate_project_total_cost function missing' 
    END as calculate_project_total_cost_status;

-- Show function details
SELECT 
    proname as function_name,
    pg_get_function_arguments(oid) as arguments,
    pg_get_function_result(oid) as return_type
FROM pg_proc 
WHERE proname IN (
    'increment_card_balance',
    'create_transaction_with_balance_update', 
    'validate_promo_code',
    'calculate_project_total_cost'
)
ORDER BY proname;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT '🎉 PostgreSQL functions created successfully!' as result;
SELECT 'Transaction creation and card balance updates will now work properly.' as message;