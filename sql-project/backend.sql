-- =========================================
-- CREACION DE TABLA DE AUDITORIA
-- =========================================

CREATE TABLE audit_orders(
    action VARCHAR2(20),
    order_id NUMBER,
    fecha DATE
);

-- =========================================
-- FUNCIONES
-- =========================================

CREATE OR REPLACE FUNCTION fnc_total_pedido(p_order_id NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT SUM(quantity * unit_price)
    INTO v_total
    FROM CO.order_items
    WHERE order_id = p_order_id;

    RETURN NVL(v_total,0);
END;
/

CREATE OR REPLACE FUNCTION fnc_total_cliente(p_customer_id NUMBER)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT SUM(fnc_total_pedido(order_id))
    INTO v_total
    FROM CO.orders
    WHERE customer_id = p_customer_id;

    RETURN NVL(v_total,0);
END;
/

CREATE OR REPLACE FUNCTION fnc_validar_stock(p_product_id NUMBER, p_qty NUMBER)
RETURN NUMBER IS
    v_stock NUMBER;
BEGIN
    SELECT NVL(SUM(product_inventory),0)
    INTO v_stock
    FROM CO.inventory
    WHERE product_id = p_product_id;

    IF v_stock >= p_qty THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
/

CREATE OR REPLACE FUNCTION fnc_desc_pedido(p_order_id NUMBER)
RETURN VARCHAR2 IS
    v_text VARCHAR2(200);
BEGIN
    SELECT 'Pedido #' || order_id || ' Cliente: ' || customer_id
    INTO v_text
    FROM CO.orders
    WHERE order_id = p_order_id;

    RETURN v_text;
END;
/

-- =========================================
-- PROCEDIMIENTOS
-- =========================================

CREATE OR REPLACE PROCEDURE prc_crear_pedido(
    p_order_id NUMBER,
    p_customer_id NUMBER
)
IS
BEGIN
    INSERT INTO CO.orders(
        order_id,
        order_datetime,
        customer_id,
        order_status,
        store_id
    )
    VALUES(
        p_order_id,
        SYSTIMESTAMP,
        p_customer_id,
        'OPEN',
        1
    );
END;
/

CREATE OR REPLACE PROCEDURE prc_insertar_item(
    p_order_id NUMBER,
    p_product_id NUMBER,
    p_qty NUMBER,
    p_price NUMBER
)
IS
BEGIN
    IF fnc_validar_stock(p_product_id, p_qty) = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Sin stock');
    END IF;

    INSERT INTO CO.order_items(
        order_id,
        line_item_id,
        product_id,
        quantity,
        unit_price
    )
    VALUES(
        p_order_id,
        1,
        p_product_id,
        p_qty,
        p_price
    );
END;
/

CREATE OR REPLACE PROCEDURE prc_reporte_pedidos
IS
    CURSOR c IS SELECT order_id FROM CO.orders;
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE('Pedido: ' || r.order_id ||
        ' Total: ' || fnc_total_pedido(r.order_id));
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE prc_reporte_clientes
IS
    CURSOR c IS SELECT customer_id FROM CO.customers;
BEGIN
    FOR r IN c LOOP
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || r.customer_id ||
        ' Total: ' || fnc_total_cliente(r.customer_id));
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE prc_update_precios(p_pct NUMBER)
IS
BEGIN
    UPDATE CO.products
    SET unit_price = unit_price * (1 + p_pct/100);

    DBMS_OUTPUT.PUT_LINE('Filas afectadas: ' || SQL%ROWCOUNT);
END;
/

-- =========================================
-- TRIGGERS
-- =========================================

CREATE OR REPLACE TRIGGER trg_valida_precio
BEFORE INSERT OR UPDATE ON CO.products
FOR EACH ROW
BEGIN
    IF :NEW.unit_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001,'Precio inválido');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_audit_orders
AFTER INSERT OR UPDATE OR DELETE ON CO.orders
FOR EACH ROW
DECLARE
    v_action VARCHAR2(20);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
    ELSIF DELETING THEN
        v_action := 'DELETE';
    END IF;

    INSERT INTO CO.audit_orders(action, order_id, fecha)
    VALUES(
        v_action,
        NVL(:NEW.order_id, :OLD.order_id),
        SYSDATE
    );
END;
/

CREATE OR REPLACE TRIGGER trg_update_inventory
AFTER INSERT ON CO.order_items
FOR EACH ROW
BEGIN
    UPDATE CO.inventory
    SET product_inventory = product_inventory - :NEW.quantity
    WHERE product_id = :NEW.product_id;
END;
/

CREATE OR REPLACE TRIGGER trg_limite_credito
BEFORE INSERT ON CO.orders
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM CO.orders
    WHERE customer_id = :NEW.customer_id;

    IF v_count >= 5 THEN
        RAISE_APPLICATION_ERROR(-20003,'Cliente con demasiados pedidos');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_control_stock
BEFORE INSERT ON CO.order_items
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT NVL(SUM(product_inventory),0) INTO v_stock
    FROM CO.inventory
    WHERE product_id = :NEW.product_id;

    IF v_stock < :NEW.quantity THEN
        RAISE_APPLICATION_ERROR(-20004,'Stock insuficiente');
    END IF;
END;
/

-- =========================================
-- PRUEBAS
-- =========================================

SET SERVEROUTPUT ON;

SELECT fnc_total_pedido(1) FROM dual;
SELECT fnc_total_cliente(1) FROM dual;

EXEC prc_reporte_pedidos;
EXEC prc_reporte_clientes;

INSERT INTO CO.orders(order_id, order_datetime, customer_id, order_status, store_id)
VALUES (999, SYSTIMESTAMP, 1, 'OPEN', 1);

SELECT * FROM CO.audit_orders;

INSERT INTO CO.order_items(order_id, line_item_id, product_id, quantity, unit_price)
VALUES (999, 1, 1, 9999, 100);

INSERT INTO CO.products(product_id, product_name, unit_price)
VALUES (9999, 'TEST', -10);