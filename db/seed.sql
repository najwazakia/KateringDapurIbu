USE katering_dapur_ibu;

INSERT IGNORE INTO units (name, symbol, dimension, to_base_factor)
VALUES
    ('Gram', 'g', 'mass', 1),
    ('Kilogram', 'kg', 'mass', 1000),
    ('Mililiter', 'ml', 'volume', 1),
    ('Liter', 'l', 'volume', 1000),
    ('Buah', 'pcs', 'count', 1),
    ('Porsi', 'portion', 'portion', 1);
