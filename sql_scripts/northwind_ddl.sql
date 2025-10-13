--
-- PostgreSQL database dump
--
SET
    statement_timeout = 0;

SET
    lock_timeout = 0;

SET
    client_encoding = 'UTF8';

SET
    standard_conforming_strings = on;

SET
    check_function_bodies = false;

SET
    client_min_messages = warning;

SET
    default_tablespace = '';

SET
    default_with_oids = false;

---
--- drop tables
---
DROP TABLE IF EXISTS employee_territories;

DROP TABLE IF EXISTS order_details;

DROP TABLE IF EXISTS orders;

DROP TABLE IF EXISTS customers;

DROP TABLE IF EXISTS products;

DROP TABLE IF EXISTS shippers;

DROP TABLE IF EXISTS suppliers;

DROP TABLE IF EXISTS territories;

DROP TABLE IF EXISTS categories;

DROP TABLE IF EXISTS region;

DROP TABLE IF EXISTS employees;

--
-- Name: categories; Type: TABLE; Schema: public;
--
CREATE TABLE categories (
    category_id SMALLINT,
    category_name VARCHAR(15) NOT NULL,
    category_description TEXT,
    picture BYTEA,
    CONSTRAINT pk_category_id PRIMARY KEY (category_id)
);

--
-- Name: customers; Type: TABLE; Schema: public;
--
CREATE TABLE customers (
    customer_id CHAR(5),
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30),
    contact_title VARCHAR(30),
    customer_address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24),
    CONSTRAINT pk_customer_id PRIMARY KEY (customer_id)
);

--
-- Name: employees; Type: TABLE; Schema: public;
--
CREATE TABLE employees (
    employee_id SMALLINT,
    last_name VARCHAR(20) NOT NULL,
    first_name VARCHAR(10) NOT NULL,
    title VARCHAR(30),
    title_of_courtesy VARCHAR(25),
    birth_date DATE,
    hire_date DATE,
    employee_address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    home_phone VARCHAR(24),
    extension VARCHAR(4),
    photo BYTEA,
    notes TEXT,
    reports_to SMALLINT,
    photo_path VARCHAR(255),
    CONSTRAINT pk_employee_id PRIMARY KEY (employee_id)
);

--
-- Name: suppliers; Type: TABLE; Schema: public;
--
CREATE TABLE suppliers (
    supplier_id SMALLINT,
    company_name VARCHAR(40) NOT NULL,
    contact_name VARCHAR(30),
    contact_title VARCHAR(30),
    supplier_address VARCHAR(60),
    city VARCHAR(15),
    region VARCHAR(15),
    postal_code VARCHAR(10),
    country VARCHAR(15),
    phone VARCHAR(24),
    fax VARCHAR(24),
    homepage TEXT,
    CONSTRAINT pk_supplier_id PRIMARY KEY (supplier_id)
);

--
-- Name: products; Type: TABLE; Schema: public;
--
CREATE TABLE products (
    product_id SMALLINT,
    product_name VARCHAR(40) NOT NULL,
    supplier_id SMALLINT,
    category_id SMALLINT,
    quantity_per_unit VARCHAR(20),
    unit_price NUMERIC(6, 2),
    units_in_stock SMALLINT,
    units_on_order SMALLINT,
    reorder_level SMALLINT,
    discontinued SMALLINT NOT NULL,
    CONSTRAINT pk_product_id PRIMARY KEY (product_id),
    CONSTRAINT fk_category_id FOREIGN KEY (category_id) REFERENCES categories (category_id),
    CONSTRAINT fk_supplier_id FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
);

--
-- Name: region; Type: TABLE; Schema: public;
--
CREATE TABLE region (
    region_id SMALLINT,
    region_description VARCHAR(10) NOT NULL,
    CONSTRAINT pk_region_id PRIMARY KEY (region_id)
);

--
-- Name: shippers; Type: TABLE; Schema: public;
--
CREATE TABLE shippers (
    shipper_id SMALLINT,
    company_name VARCHAR(40) NOT NULL,
    phone VARCHAR(24),
    CONSTRAINT pk_shipper_id PRIMARY KEY (shipper_id)
);

--
-- Name: orders; Type: TABLE; Schema: public;
--
CREATE TABLE orders (
    order_id SMALLINT,
    customer_id CHAR(5),
    employee_id SMALLINT,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via SMALLINT,
    freight NUMERIC(6, 2),
    ship_name VARCHAR(40),
    ship_address VARCHAR(60),
    ship_city VARCHAR(15),
    ship_region VARCHAR(15),
    ship_postal_code VARCHAR(10),
    ship_country VARCHAR(15),
    CONSTRAINT pk_order_id PRIMARY KEY (order_id),
    CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
    CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
    CONSTRAINT fk_shipper_id FOREIGN KEY (ship_via) REFERENCES shippers (shipper_id)
);

--
-- Name: territories; Type: TABLE; Schema: public;
--
CREATE TABLE territories (
    territory_id INTEGER,
    territory_description VARCHAR(20) NOT NULL,
    region_id SMALLINT NOT NULL,
    CONSTRAINT pk_territory_id PRIMARY KEY (territory_id),
    CONSTRAINT fk_region_id FOREIGN KEY (region_id) REFERENCES region (region_id)
);

--
-- Name: employee_territories; Type: TABLE; Schema: public;
--
CREATE TABLE employee_territories (
    employee_id SMALLINT NOT NULL,
    territory_id INTEGER NOT NULL,
    CONSTRAINT pk_employee_territory_key PRIMARY KEY (employee_id, territory_id),
    CONSTRAINT fk_territory_id FOREIGN KEY (territory_id) REFERENCES territories (territory_id),
    CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES employees (employee_id)
);

--
-- Name: order_details; Type: TABLE; Schema: public;
--
CREATE TABLE order_details (
    order_id SMALLINT,
    product_id SMALLINT,
    unit_price NUMERIC(7, 2) NOT NULL,
    quantity SMALLINT NOT NULL,
    discount NUMERIC(6, 2) NOT NULL,
    CONSTRAINT pk_order_product_key PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT fk_order_id FOREIGN KEY (order_id) REFERENCES orders (order_Id)
);