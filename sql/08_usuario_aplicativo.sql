-- =====================================================================
--  Script 8 - Usuario de MySQL para el aplicativo
--  Ejecutar con root en Workbench, después de 01, 02 y 09
--  El aplicativo solo puede EJECUTAR las funciones y procedimientos;
--  no puede leer ni modificar las tablas directamente.
-- =====================================================================
DROP USER IF EXISTS 'app_ingreso'@'localhost';
CREATE USER 'app_ingreso'@'localhost' IDENTIFIED BY 'Ingreso2026!';

GRANT EXECUTE ON bd_ingreso_odontologico.* TO 'app_ingreso'@'localhost';

FLUSH PRIVILEGES;
SHOW GRANTS FOR 'app_ingreso'@'localhost';
