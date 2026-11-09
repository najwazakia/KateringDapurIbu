CREATE DATABASE IF NOT EXISTS katering_dapur_ibu
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE katering_dapur_ibu;

CREATE TABLE IF NOT EXISTS units (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    dimension VARCHAR(20) NOT NULL,
    to_base_factor DECIMAL(15, 6) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_units_name (name),
    UNIQUE KEY uq_units_symbol (symbol),
    CONSTRAINT chk_units_dimension
        CHECK (dimension IN ('mass', 'volume', 'count', 'portion')),
    CONSTRAINT chk_units_to_base_factor
        CHECK (to_base_factor > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ingredients (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(120) NOT NULL,
    base_unit_id BIGINT UNSIGNED NOT NULL,
    stock_unit_name VARCHAR(80) NOT NULL,
    stock_to_base_factor DECIMAL(15, 6) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_ingredients_name (name),
    CONSTRAINT fk_ingredients_base_unit
        FOREIGN KEY (base_unit_id) REFERENCES units (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_ingredients_stock_to_base_factor
        CHECK (stock_to_base_factor > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS recipes (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    yield_quantity DECIMAL(15, 4) NOT NULL,
    yield_unit_id BIGINT UNSIGNED NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_recipes_name (name),
    CONSTRAINT fk_recipes_yield_unit
        FOREIGN KEY (yield_unit_id) REFERENCES units (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_recipes_yield_quantity
        CHECK (yield_quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    recipe_id BIGINT UNSIGNED NOT NULL,
    ingredient_id BIGINT UNSIGNED NOT NULL,
    quantity DECIMAL(15, 4) NOT NULL,
    unit_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    KEY idx_recipe_ingredients_recipe (recipe_id),
    KEY idx_recipe_ingredients_ingredient (ingredient_id),
    CONSTRAINT fk_recipe_ingredients_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipes (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_recipe_ingredients_ingredient
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_recipe_ingredients_unit
        FOREIGN KEY (unit_id) REFERENCES units (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_recipe_ingredients_quantity
        CHECK (quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS recipe_subrecipes (
    parent_recipe_id BIGINT UNSIGNED NOT NULL,
    subrecipe_id BIGINT UNSIGNED NOT NULL,
    quantity DECIMAL(15, 4) NOT NULL,
    unit_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (parent_recipe_id, subrecipe_id),
    CONSTRAINT fk_recipe_subrecipes_parent
        FOREIGN KEY (parent_recipe_id) REFERENCES recipes (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_recipe_subrecipes_subrecipe
        FOREIGN KEY (subrecipe_id) REFERENCES recipes (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_recipe_subrecipes_unit
        FOREIGN KEY (unit_id) REFERENCES units (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_recipe_subrecipes_not_self
        CHECK (parent_recipe_id <> subrecipe_id),
    CONSTRAINT chk_recipe_subrecipes_quantity
        CHECK (quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS menus (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_menus_name (name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS menu_components (
    menu_id BIGINT UNSIGNED NOT NULL,
    recipe_id BIGINT UNSIGNED NOT NULL,
    quantity_per_portion DECIMAL(15, 4) NOT NULL,
    unit_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (menu_id, recipe_id),
    CONSTRAINT fk_menu_components_menu
        FOREIGN KEY (menu_id) REFERENCES menus (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_menu_components_recipe
        FOREIGN KEY (recipe_id) REFERENCES recipes (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_menu_components_unit
        FOREIGN KEY (unit_id) REFERENCES units (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_menu_components_quantity
        CHECK (quantity_per_portion > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customers (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_customers_name (name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    event_date DATE NOT NULL,
    production_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_orders_production_status (production_date, status),
    KEY idx_orders_event_date (event_date),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_orders_status
        CHECK (status IN ('draft', 'confirmed', 'cancelled')),
    CONSTRAINT chk_orders_production_date
        CHECK (production_date <= event_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id BIGINT UNSIGNED NOT NULL,
    menu_id BIGINT UNSIGNED NOT NULL,
    portion_count INT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_order_items_order_menu (order_id, menu_id),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES orders (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_menu
        FOREIGN KEY (menu_id) REFERENCES menus (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_order_items_portion_count
        CHECK (portion_count > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchases (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    purchased_at DATETIME NOT NULL,
    supplier_name VARCHAR(150) NULL,
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_purchases_purchased_at (purchased_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_items (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    purchase_id BIGINT UNSIGNED NOT NULL,
    ingredient_id BIGINT UNSIGNED NOT NULL,
    quantity_stock_unit DECIMAL(15, 4) NOT NULL,
    unit_price_stock DECIMAL(15, 4) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_purchase_items_purchase_ingredient (purchase_id, ingredient_id),
    UNIQUE KEY uq_purchase_items_id_ingredient (id, ingredient_id),
    KEY idx_purchase_items_ingredient (ingredient_id),
    CONSTRAINT fk_purchase_items_purchase
        FOREIGN KEY (purchase_id) REFERENCES purchases (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_purchase_items_ingredient
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_purchase_items_quantity
        CHECK (
            quantity_stock_unit > 0
            AND quantity_stock_unit = FLOOR(quantity_stock_unit)
        ),
    CONSTRAINT chk_purchase_items_unit_price
        CHECK (unit_price_stock >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS production_batches (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    production_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'planned',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_production_batches_date (production_date),
    CONSTRAINT chk_production_batches_status
        CHECK (status IN ('planned', 'in_progress', 'completed', 'cancelled'))
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS production_usages (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    production_batch_id BIGINT UNSIGNED NOT NULL,
    ingredient_id BIGINT UNSIGNED NOT NULL,
    quantity_stock_unit DECIMAL(15, 4) NOT NULL,
    stock_to_base_factor_at_use DECIMAL(15, 6) NOT NULL,
    unit_cost_stock_at_use DECIMAL(15, 4) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_production_usages_batch_ingredient
        (production_batch_id, ingredient_id),
    UNIQUE KEY uq_production_usages_id_ingredient (id, ingredient_id),
    CONSTRAINT fk_production_usages_batch
        FOREIGN KEY (production_batch_id) REFERENCES production_batches (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_production_usages_ingredient
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_production_usages_quantity
        CHECK (quantity_stock_unit > 0),
    CONSTRAINT chk_production_usages_conversion
        CHECK (stock_to_base_factor_at_use > 0),
    CONSTRAINT chk_production_usages_unit_cost
        CHECK (unit_cost_stock_at_use >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS stock_movements (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ingredient_id BIGINT UNSIGNED NOT NULL,
    purchase_item_id BIGINT UNSIGNED NULL,
    production_usage_id BIGINT UNSIGNED NULL,
    movement_type VARCHAR(20) NOT NULL,
    quantity_delta_stock_unit DECIMAL(15, 4) NOT NULL,
    unit_cost_stock DECIMAL(15, 4) NOT NULL,
    occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_stock_movements_purchase_item (purchase_item_id),
    UNIQUE KEY uq_stock_movements_production_usage (production_usage_id),
    KEY idx_stock_movements_ingredient_date (ingredient_id, occurred_at),
    CONSTRAINT fk_stock_movements_ingredient
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_stock_movements_purchase_item
        FOREIGN KEY (purchase_item_id, ingredient_id)
        REFERENCES purchase_items (id, ingredient_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_stock_movements_production_usage
        FOREIGN KEY (production_usage_id, ingredient_id)
        REFERENCES production_usages (id, ingredient_id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_stock_movements_cost
        CHECK (unit_cost_stock >= 0),
    CONSTRAINT chk_stock_movements_source
        CHECK (
            (
                movement_type = 'purchase'
                AND purchase_item_id IS NOT NULL
                AND production_usage_id IS NULL
                AND quantity_delta_stock_unit > 0
            )
            OR (
                movement_type = 'production_usage'
                AND purchase_item_id IS NULL
                AND production_usage_id IS NOT NULL
                AND quantity_delta_stock_unit < 0
            )
            OR (
                movement_type = 'adjustment'
                AND purchase_item_id IS NULL
                AND production_usage_id IS NULL
                AND quantity_delta_stock_unit <> 0
                AND notes IS NOT NULL
                AND CHAR_LENGTH(TRIM(notes)) > 0
            )
        )
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS production_menu_costs (
    production_batch_id BIGINT UNSIGNED NOT NULL,
    menu_id BIGINT UNSIGNED NOT NULL,
    portion_count INT UNSIGNED NOT NULL,
    hpp_per_portion DECIMAL(15, 2) NOT NULL,
    total_hpp DECIMAL(18, 2)
        GENERATED ALWAYS AS (ROUND(hpp_per_portion * portion_count, 2)) STORED,
    calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (production_batch_id, menu_id),
    CONSTRAINT fk_production_menu_costs_batch
        FOREIGN KEY (production_batch_id) REFERENCES production_batches (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT fk_production_menu_costs_menu
        FOREIGN KEY (menu_id) REFERENCES menus (id)
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT chk_production_menu_costs_portions
        CHECK (portion_count > 0),
    CONSTRAINT chk_production_menu_costs_hpp
        CHECK (hpp_per_portion >= 0)
) ENGINE=InnoDB;
