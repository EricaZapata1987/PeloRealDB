USE pelorealdb;

-- Ver todos los productos
SELECT * FROM Productos;

-- Ver todos los proveedores
SELECT * FROM Proveedores;

-- Productos con stock mayor a 10
SELECT nombre, categoria, stock 
FROM Productos
WHERE stock > 10;

-- Productos de la marca Mary Bosques
SELECT p.nombre, p.categoria, p.precio, pr.nombre AS proveedor
FROM Productos p
JOIN Proveedores pr ON p.proveedor_id = pr.proveedor_id
WHERE pr.nombre = 'Mary Bosques';

-- Producto más caro
SELECT nombre, precio 
FROM Productos
ORDER BY precio DESC
LIMIT 1;

-- Producto más barato
SELECT nombre, precio 
FROM Productos
ORDER BY precio ASC
LIMIT 1;

-- Cantidad de productos por categoría
SELECT categoria, COUNT(*) AS cantidad
FROM Productos
GROUP BY categoria;

-- Precio promedio por proveedor
SELECT pr.nombre AS proveedor, AVG(p.precio) AS precio_promedio
FROM Productos p
JOIN Proveedores pr ON p.proveedor_id = pr.proveedor_id
GROUP BY pr.nombre;
