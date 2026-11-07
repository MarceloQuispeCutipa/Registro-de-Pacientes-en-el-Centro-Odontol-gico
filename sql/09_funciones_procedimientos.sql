-- =====================================================================
--  Script 9 - Funciones y procedimientos almacenados del aplicativo
--  Base de datos: bd_ingreso_odontologico (MySQL 8.0)
--  Ejecutar con root en Workbench, después de 01 y 02.
--  El aplicativo PHP no escribe consultas: solo llama a estas rutinas.
--    - FUNCIONES      : devuelven un solo valor   -> SELECT fn_...(...)
--    - PROCEDIMIENTOS : devuelven filas (listas)  -> CALL sp_...(...)
-- =====================================================================
SET NAMES utf8mb4;
USE bd_ingreso_odontologico;

DROP FUNCTION  IF EXISTS fn_dia_semana;
DROP FUNCTION  IF EXISTS fn_fecha_con_datos;
DROP FUNCTION  IF EXISTS fn_citas_dia;
DROP FUNCTION  IF EXISTS fn_ingresos_dia;
DROP FUNCTION  IF EXISTS fn_permisos_abiertos;
DROP FUNCTION  IF EXISTS fn_esterilizaciones_curso;
DROP FUNCTION  IF EXISTS fn_total_sillones;
DROP PROCEDURE IF EXISTS sp_info_servidor;
DROP PROCEDURE IF EXISTS sp_conteo_tablas;
DROP PROCEDURE IF EXISTS sp_objetos_base;
DROP PROCEDURE IF EXISTS sp_listar_personal;
DROP PROCEDURE IF EXISTS sp_obtener_personal;
DROP PROCEDURE IF EXISTS sp_ocupacion_sillones;
DROP PROCEDURE IF EXISTS sp_agenda_dia;
DROP PROCEDURE IF EXISTS sp_buscar_alumno_qr;
DROP PROCEDURE IF EXISTS sp_atenciones_alumno;
DROP PROCEDURE IF EXISTS sp_ingresos_dia;

DELIMITER $$

-- ---------------------------------------------------------------------
--  FUNCIONES
-- ---------------------------------------------------------------------

-- Nombre del día de la semana de una fecha (Lunes ... Domingo)
CREATE FUNCTION fn_dia_semana(p_fecha DATE)
RETURNS VARCHAR(9)
DETERMINISTIC
BEGIN
    RETURN ELT(WEEKDAY(p_fecha) + 1,
               'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo');
END$$

-- Devuelve la fecha pedida si tiene ingresos; si no, la última fecha con ingresos
CREATE FUNCTION fn_fecha_con_datos(p_fecha DATE)
RETURNS DATE
READS SQL DATA
BEGIN
    IF EXISTS (SELECT 1 FROM ingreso WHERE fecha = p_fecha) THEN
        RETURN p_fecha;
    END IF;
    RETURN COALESCE((SELECT MAX(fecha) FROM ingreso), p_fecha);
END$$

-- Cantidad de citas programadas para un día de la semana
CREATE FUNCTION fn_citas_dia(p_dia VARCHAR(9))
RETURNS INT
READS SQL DATA
BEGIN
    RETURN (SELECT COUNT(*) FROM programacion WHERE dia_semana = p_dia);
END$$

-- Cantidad de ingresos de una fecha; si el turno es NULL cuenta todo el día
CREATE FUNCTION fn_ingresos_dia(p_fecha DATE, p_turno VARCHAR(6))
RETURNS INT
READS SQL DATA
BEGIN
    RETURN (SELECT COUNT(*) FROM ingreso
            WHERE fecha = p_fecha
              AND (p_turno IS NULL OR turno = p_turno));
END$$

-- Alumnos que siguen fuera con permiso (sin hora de retorno) en una fecha
CREATE FUNCTION fn_permisos_abiertos(p_fecha DATE)
RETURNS INT
READS SQL DATA
BEGIN
    RETURN (SELECT COUNT(*)
            FROM permiso pm
            JOIN ingreso i ON i.codigo_ingreso = pm.codigo_ingreso
            WHERE i.fecha = p_fecha AND pm.hora_retorno IS NULL);
END$$

-- Ciclos de esterilización sin hora de fin en una fecha
CREATE FUNCTION fn_esterilizaciones_curso(p_fecha DATE)
RETURNS INT
READS SQL DATA
BEGIN
    RETURN (SELECT COUNT(*)
            FROM esterilizacion e
            JOIN ingreso i ON i.codigo_ingreso = e.codigo_ingreso
            WHERE i.fecha = p_fecha AND e.hora_fin IS NULL);
END$$

-- Total de sillones registrados
CREATE FUNCTION fn_total_sillones()
RETURNS INT
READS SQL DATA
BEGIN
    RETURN (SELECT COUNT(*) FROM sillon);
END$$

-- ---------------------------------------------------------------------
--  PROCEDIMIENTOS: prueba de conexión
-- ---------------------------------------------------------------------

-- Datos del servidor y de la sesión del aplicativo
CREATE PROCEDURE sp_info_servidor()
READS SQL DATA
BEGIN
    SELECT VERSION()                  AS version,
           DATABASE()                 AS base,
           USER()                     AS usuario_conectado,
           @@character_set_database   AS charset,
           @@collation_database       AS collation,
           NOW()                      AS hora_servidor;
END$$

-- Filas de cada tabla de la base
CREATE PROCEDURE sp_conteo_tablas()
READS SQL DATA
BEGIN
    SELECT 'alumno'         AS tabla, COUNT(*) AS filas FROM alumno
    UNION ALL SELECT 'doctor',         COUNT(*) FROM doctor
    UNION ALL SELECT 'esterilizacion', COUNT(*) FROM esterilizacion
    UNION ALL SELECT 'ingreso',        COUNT(*) FROM ingreso
    UNION ALL SELECT 'paciente',       COUNT(*) FROM paciente
    UNION ALL SELECT 'permiso',        COUNT(*) FROM permiso
    UNION ALL SELECT 'personal',       COUNT(*) FROM personal
    UNION ALL SELECT 'programacion',   COUNT(*) FROM programacion
    UNION ALL SELECT 'sala',           COUNT(*) FROM sala
    UNION ALL SELECT 'sillon',         COUNT(*) FROM sillon;
END$$

-- Restricciones, índices, triggers y rutinas de la base
CREATE PROCEDURE sp_objetos_base()
READS SQL DATA
BEGIN
    SELECT constraint_type AS objeto, COUNT(*) AS cantidad
    FROM information_schema.table_constraints
    WHERE table_schema = DATABASE()
    GROUP BY constraint_type
    UNION ALL
    SELECT 'INDEX', COUNT(DISTINCT table_name, index_name)
    FROM information_schema.statistics WHERE table_schema = DATABASE()
    UNION ALL
    SELECT 'TRIGGER', COUNT(*)
    FROM information_schema.triggers WHERE trigger_schema = DATABASE()
    UNION ALL
    SELECT routine_type, COUNT(*)
    FROM information_schema.routines WHERE routine_schema = DATABASE()
    GROUP BY routine_type;
END$$

-- ---------------------------------------------------------------------
--  PROCEDIMIENTOS: recepción
-- ---------------------------------------------------------------------

-- Lista del personal de recepción (para el inicio de turno)
CREATE PROCEDURE sp_listar_personal()
READS SQL DATA
BEGIN
    SELECT codigo_personal, nombre FROM personal ORDER BY nombre;
END$$

-- Un integrante del personal por su código
CREATE PROCEDURE sp_obtener_personal(IN p_codigo SMALLINT)
READS SQL DATA
BEGIN
    SELECT codigo_personal, nombre FROM personal WHERE codigo_personal = p_codigo;
END$$

-- Estado de cada sillón (Ocupado/Libre) en una fecha y turno
CREATE PROCEDURE sp_ocupacion_sillones(IN p_fecha DATE, IN p_turno VARCHAR(6))
READS SQL DATA
BEGIN
    SELECT s.codigo_sillon, s.piso,
           IF(EXISTS (SELECT 1
                      FROM ingreso i
                      JOIN programacion p ON p.codigo_programacion = i.codigo_programacion
                      WHERE i.fecha = p_fecha AND i.turno = p_turno
                        AND p.codigo_sillon = s.codigo_sillon),
              'Ocupado', 'Libre') AS estado
    FROM sillon s
    ORDER BY s.piso, s.codigo_sillon;
END$$

-- Citas programadas para un día de la semana
CREATE PROCEDURE sp_agenda_dia(IN p_dia VARCHAR(9))
READS SQL DATA
BEGIN
    SELECT p.bloque_horario, p.codigo_programacion, pa.dni, pa.nombre AS paciente,
           pa.condicion, p.codigo_sillon, s.piso, p.asistencia
    FROM programacion p
    JOIN paciente pa ON pa.dni = p.dni
    LEFT JOIN sillon s ON s.codigo_sillon = p.codigo_sillon
    WHERE p.dia_semana = p_dia
    ORDER BY p.bloque_horario, p.codigo_programacion;
END$$

-- Busca un alumno por su código QR
CREATE PROCEDURE sp_buscar_alumno_qr(IN p_qr VARCHAR(10))
READS SQL DATA
BEGIN
    SELECT codigo_alumno, codigo_qr, nombre FROM alumno WHERE codigo_qr = p_qr;
END$$

-- Atenciones (ingresos) de un alumno, de la más reciente a la más antigua
CREATE PROCEDURE sp_atenciones_alumno(IN p_codigo_alumno VARCHAR(10))
READS SQL DATA
BEGIN
    SELECT i.fecha, i.hora_ingreso, i.turno, pa.nombre AS paciente,
           COALESCE(p.codigo_sillon, sa.nombre_sala) AS ubicacion
    FROM ingreso i
    JOIN programacion p ON p.codigo_programacion = i.codigo_programacion
    JOIN paciente pa ON pa.dni = p.dni
    LEFT JOIN sala sa ON sa.codigo_sala = i.codigo_sala
    WHERE i.codigo_alumno = p_codigo_alumno
    ORDER BY i.fecha DESC, i.hora_ingreso DESC;
END$$

-- Ingresos de una fecha; si el turno es NULL muestra todo el día
CREATE PROCEDURE sp_ingresos_dia(IN p_fecha DATE, IN p_turno VARCHAR(6))
READS SQL DATA
BEGIN
    SELECT i.codigo_ingreso, i.hora_ingreso, i.turno,
           pa.nombre AS paciente, a.nombre AS alumno, pe.nombre AS validado_por,
           COALESCE(p.codigo_sillon, sa.nombre_sala) AS ubicacion,
           i.tipo_procedimiento, d.nombre AS doctor
    FROM ingreso i
    JOIN programacion p ON p.codigo_programacion = i.codigo_programacion
    JOIN paciente pa    ON pa.dni = p.dni
    JOIN alumno a       ON a.codigo_alumno = i.codigo_alumno
    JOIN personal pe    ON pe.codigo_personal = i.codigo_personal
    LEFT JOIN sala sa   ON sa.codigo_sala = i.codigo_sala
    LEFT JOIN doctor d  ON d.codigo_doctor = i.codigo_doctor
    WHERE i.fecha = p_fecha
      AND (p_turno IS NULL OR i.turno = p_turno)
    ORDER BY i.hora_ingreso;
END$$

DELIMITER ;

-- Verificación: rutinas creadas
SELECT routine_type AS tipo, routine_name AS nombre
FROM information_schema.routines
WHERE routine_schema = 'bd_ingreso_odontologico'
ORDER BY routine_type, routine_name;
