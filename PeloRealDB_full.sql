-- ================================
-- PeloRealDB - Full SQL (schema + seed + queries)
-- Autor: Erica Zapata (PeloReal)
-- ================================

/* 1) SCHEMA */
-- PeloRealDB (MySQL)
DROP DATABASE IF EXISTS PeloRealDB;
CREATE DATABASE PeloRealDB;
USE PeloRealDB;

CREATE TABLE Proveedores (
  proveedor_id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE Productos (
  producto_id INT PRIMARY KEY AUTO_INCREMENT,
  proveedor_id INT NOT NULL,
  nombre VARCHAR(150) NOT NULL,
  categoria VARCHAR(60) NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  punto_reposicion INT NOT NULL DEFAULT 10,
  CONSTRAINT fk_prod_prov FOREIGN KEY (proveedor_id) REFERENCES Proveedores(proveedor_id)
);

CREATE TABLE Clientes (
  cliente_id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(120),
  ciudad VARCHAR(80)
);

CREATE TABLE Pedidos (
  pedido_id INT PRIMARY KEY AUTO_INCREMENT,
  cliente_id INT NOT NULL,
  fecha DATE NOT NULL,
  metodo_pago VARCHAR(30) NOT NULL,
  total DECIMAL(12,2) DEFAULT 0,
  CONSTRAINT fk_ped_cli FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

CREATE TABLE DetallePedidos (
  detalle_id INT PRIMARY KEY AUTO_INCREMENT,
  pedido_id INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_det_ped FOREIGN KEY (pedido_id) REFERENCES Pedidos(pedido_id),
  CONSTRAINT fk_det_prod FOREIGN KEY (producto_id) REFERENCES Productos(producto_id)
);


/* 2) SEED (DATOS) */
USE PeloRealDB;

INSERT INTO Proveedores (nombre) VALUES
 ('Fidelité'), ('Mary Bosques'), ('Primont'), ('Issue'), ('Skala'), ('L’Oréal'), ('Kerastase');

INSERT INTO Productos (proveedor_id, nombre, categoria, precio, stock, punto_reposicion) VALUES
 (1,'Shampoo Nutritivo Fidelité','Shampoo',7800.00,50,12),
 (1,'Serum Ultra Violet Fidelité','Serum',11000.00,25,6),
 (2,'Máscara Argán Mary Bosques','Máscara',8500.00,40,10),
 (2,'Crema Regeneración Mary Bosques','Tratamiento',9200.00,30,8),
 (3,'Shampoo Reparador Primont','Shampoo',7200.00,45,12),
 (3,'Acondicionador Reparador Primont','Acondicionador',6800.00,45,12),
 (4,'Shampoo Matizador Issue','Shampoo',7600.00,35,10),
 (4,'Máscara Matizadora Issue','Máscara',8900.00,28,8),
 (5,'Skala Bomba Crema Tratamiento','Tratamiento',5400.00,60,15),
 (5,'Skala Babosa Shampoo','Shampoo',4800.00,55,15),
 (6,'Crema Hidratante Facial L’Oréal','Facial',8700.00,35,10),
 (6,'Shampoo L’Oréal Professionnel','Shampoo',9900.00,20,8),
 (7,'Elixir Ultime Kerastase','Aceite',15000.00,15,5),
 (7,'Máscara Nutritiva Kerastase','Máscara',16500.00,12,5);

INSERT INTO Clientes (nombre,email,ciudad) VALUES
 ('Ana Gómez','ana@mail.com','Avellaneda'),
 ('Luis Pérez','luis@mail.com','Lanús'),
 ('María López','maria@mail.com','Quilmes'),
 ('Jorge Díaz','jorge@mail.com','Avellaneda'),
 ('Sofía Torres','sofia@mail.com','CABA'),
 ('Valentina Romero','valen@mail.com','CABA');

INSERT INTO Pedidos (cliente_id, fecha, metodo_pago, total) VALUES
 (1,'2025-09-01','Tarjeta',0),
 (2,'2025-09-02','Efectivo',0),
 (3,'2025-09-05','Transferencia',0),
 (1,'2025-09-10','Tarjeta',0),
 (4,'2025-09-12','Tarjeta',0),
 (5,'2025-10-01','Efectivo',0),
 (6,'2025-10-03','Transferencia',0);

INSERT INTO DetallePedidos (pedido_id, producto_id, cantidad, precio_unitario) VALUES
 (1,1,1,7800.00),(1,12,1,9900.00),
 (2,2,1,11000.00),(2,11,1,8700.00),
 (3,7,1,7600.00),(3,8,1,8900.00),
 (4,3,1,8500.00),(4,4,1,9200.00),
 (5,13,1,15000.00),(5,14,1,16500.00),
 (6,9,1,5400.00),(6,10,1,4800.00),
 (7,5,1,7200.00),(7,6,1,6800.00);


/* 3) QUERIES (ANÁLISIS) */
-- 1) Detalle de ventas con cliente y subtotal
SELECT p.pedido_id, p.fecha, c.nombre AS cliente,
       pr.nombre AS producto, d.cantidad, d.precio_unitario,
       (d.cantidad * d.precio_unitario) AS subtotal
FROM Pedidos p
JOIN Clientes c ON c.cliente_id = p.cliente_id
JOIN DetallePedidos d ON d.pedido_id = p.pedido_id
JOIN Productos pr ON pr.producto_id = d.producto_id
ORDER BY p.fecha, p.pedido_id;

-- 2) Total por pedido
SELECT p.pedido_id, SUM(d.cantidad * d.precio_unitario) AS total_calculado
FROM Pedidos p
JOIN DetallePedidos d ON d.pedido_id = p.pedido_id
GROUP BY p.pedido_id
ORDER BY p.pedido_id;

-- 3) Top 5 productos por unidades
SELECT pr.nombre, SUM(d.cantidad) AS unidades
FROM DetallePedidos d
JOIN Productos pr ON pr.producto_id = d.producto_id
GROUP BY pr.nombre
ORDER BY unidades DESC
LIMIT 5;

-- 4) Ventas por marca
SELECT prov.nombre AS marca, SUM(d.cantidad * d.precio_unitario) AS ventas
FROM DetallePedidos d
JOIN Productos pr ON pr.producto_id = d.producto_id
JOIN Proveedores prov ON prov.proveedor_id = pr.proveedor_id
GROUP BY prov.nombre
ORDER BY ventas DESC;

-- 5) Clientes top por gasto
SELECT c.nombre, SUM(d.cantidad * d.precio_unitario) AS gasto_total
FROM Clientes c
JOIN Pedidos p ON p.cliente_id = c.cliente_id
JOIN DetallePedidos d ON d.pedido_id = p.pedido_id
GROUP BY c.nombre
ORDER BY gasto_total DESC;

-- 6) Stock bajo
SELECT producto_id, nombre, stock, punto_reposicion
FROM Productos
WHERE stock < punto_reposicion
ORDER BY (punto_reposicion - stock) DESC;

-- 7) Productos sin ventas
SELECT pr.producto_id, pr.nombre
FROM Productos pr
LEFT JOIN DetallePedidos d ON d.producto_id = pr.producto_id
WHERE d.producto_id IS NULL;

-- 8) Ventas por mes
SELECT DATE_FORMAT(p.fecha, '%Y-%m') AS mes,
       SUM(d.cantidad * d.precio_unitario) AS ventas_mes
FROM Pedidos p
JOIN DetallePedidos d ON d.pedido_id = p.pedido_id
GROUP BY DATE_FORMAT(p.fecha, '%Y-%m')
ORDER BY mes;

-- 9) Ingresos por categoría
SELECT pr.categoria, SUM(d.cantidad * d.precio_unitario) AS ingresos
FROM DetallePedidos d
JOIN Productos pr ON pr.producto_id = d.producto_id
GROUP BY pr.categoria
ORDER BY ingresos DESC;

-- 10) Ticket promedio por cliente
SELECT c.nombre, AVG(t.total_por_pedido) AS ticket_promedio
FROM (
  SELECT p.pedido_id, p.cliente_id, SUM(d.cantidad * d.precio_unitario) AS total_por_pedido
  FROM Pedidos p
  JOIN DetallePedidos d ON d.pedido_id = p.pedido_id
  GROUP BY p.pedido_id, p.cliente_id
) t
JOIN Clientes c ON c.cliente_id = t.cliente_id
GROUP BY c.nombre
ORDER BY ticket_promedio DESC;

DROP DATABASE IF EXISTS PeloRealDB;
CREATE DATABASE PeloRealDB;
USE PeloRealDB;
