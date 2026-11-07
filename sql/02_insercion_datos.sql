-- =====================================================================
--  Script 2 - Inserción de datos de ejemplo
--  Ejecutar después de 01_creacion_bd.sql
--  Semana de atención del 19 al 24 de octubre de 2026
-- =====================================================================
SET NAMES utf8mb4;
USE bd_ingreso_odontologico;

START TRANSACTION;

-- Catálogos
INSERT INTO sala (codigo_sala, nombre_sala) VALUES
    (1, 'Sala de Cirugía'),
    (2, 'Sala de Diagnóstico/Radiología');

INSERT INTO sillon (codigo_sillon, piso) VALUES
    ('A1', 1),
    ('A2', 1),
    ('B1', 1),
    ('B2', 1),
    ('C1', 2),
    ('C2', 2),
    ('D1', 2),
    ('D2', 2),
    ('E1', 2),
    ('E2', 2),
    ('F1', 3),
    ('F2', 3),
    ('G1', 3),
    ('G2', 3),
    ('H1', 3),
    ('H2', 3);

INSERT INTO personal (codigo_personal, nombre) VALUES
    (1, 'Torres Lima, Juan'),
    (2, 'Quispe Mamani, Rosa'),
    (3, 'Flores Apaza, Carmen'),
    (4, 'Huamán Ccori, Luis');

INSERT INTO doctor (codigo_doctor, nombre) VALUES
    (1, 'Dr. Fernández Rivera, Carlos'),
    (2, 'Dra. Salas Cornejo, Patricia'),
    (3, 'Dr. Medina Paredes, Jorge'),
    (4, 'Dra. Villena Rojas, Lucía'),
    (5, 'Dr. Chávez Núñez, Ricardo'),
    (6, 'Dra. Zegarra Pinto, Mónica');

INSERT INTO alumno (codigo_alumno, codigo_qr, nombre) VALUES
    ('2021248861', 'QR72623725', 'Pérez Rojas, Ana'),
    ('2021248902', 'QR72623801', 'Gutiérrez Lazo, Diego'),
    ('2021249013', 'QR72623877', 'Mendoza Arias, Valeria'),
    ('2021249145', 'QR72623954', 'Ramos Tito, Sebastián'),
    ('2022110236', 'QR72624030', 'Cáceres Vera, Daniela'),
    ('2022110378', 'QR72624107', 'Ortiz Benavente, Marco'),
    ('2022110419', 'QR72624183', 'Alvarado Puma, Camila'),
    ('2022110582', 'QR72624260', 'Núñez Herrera, Joaquín'),
    ('2022110647', 'QR72624336', 'Delgado Soto, Fernanda'),
    ('2022110793', 'QR72624412', 'Cornejo Ugarte, Renato');

INSERT INTO paciente (dni, nombre, condicion) VALUES
    ('71928723', 'García López, Luis', 'Adulto'),
    ('72015448', 'Mamani Condori, Elena', 'Adulto'),
    ('70833192', 'Huanca Ríos, Pedro', 'Adulto'),
    ('78450216', 'Vargas Peña, Sofía', 'Niño'),
    ('76129034', 'Lazo Gómez, Mateo', 'Niño'),
    ('73374581', 'Torres Ccama, María', 'Prenatal'),
    ('74480127', 'Chávez Lima, Rosa', 'Adulto'),
    ('71102938', 'Paredes Arce, Jorge', 'Adulto'),
    ('79210345', 'Apaza Quispe, Lucía', 'Niño'),
    ('70456721', 'Salinas Vera, Carmen', 'Prenatal'),
    ('72893014', 'Rojas Medina, Alberto', 'Adulto'),
    ('75610982', 'Flores Tapia, Daniel', 'Adulto'),
    ('77345120', 'Ccori Huamán, Andrea', 'Niño'),
    ('70981236', 'Benavides Soto, Raúl', 'Adulto'),
    ('73012457', 'Montes Ugarte, Gabriela', 'Prenatal');

-- Citas de la semana
INSERT INTO programacion (codigo_programacion, dia_semana, bloque_horario, asistencia, dni, codigo_sillon) VALUES
    ('10001001', 'Lunes', '08:00-10:00', 'Asistió', '71102938', 'C2'),
    ('10001002', 'Lunes', '10:00-12:00', 'Asistió', '73012457', 'F1'),
    ('10001003', 'Lunes', '14:00-16:00', 'Asistió', '74480127', NULL),
    ('10001004', 'Lunes', '16:00-18:00', 'Asistió', '70981236', 'C1'),
    ('10001005', 'Martes', '08:00-10:00', 'No asistió', '73374581', 'E2'),
    ('10001006', 'Martes', '10:00-12:00', 'Asistió', '77345120', 'H1'),
    ('10001007', 'Martes', '14:00-16:00', 'Asistió', '76129034', 'B2'),
    ('10001008', 'Martes', '16:00-18:00', 'Asistió', '75610982', 'E1'),
    ('10001009', 'Miércoles', '08:00-10:00', 'Asistió', '78450216', 'G2'),
    ('10001010', 'Miércoles', '10:00-12:00', 'Asistió', '72893014', 'B1'),
    ('10001011', 'Miércoles', '14:00-16:00', 'No asistió', '70833192', 'D2'),
    ('10001012', 'Miércoles', '16:00-18:00', 'Asistió', '70456721', 'G1'),
    ('10001013', 'Jueves', '08:00-10:00', 'Asistió', '72015448', 'A2'),
    ('10001014', 'Jueves', '10:00-12:00', 'Asistió', '79210345', NULL),
    ('10001015', 'Jueves', '14:00-16:00', 'Asistió', '71928723', 'F2'),
    ('10001016', 'Jueves', '16:00-18:00', 'Asistió', '71102938', 'A1'),
    ('10001017', 'Viernes', '08:00-10:00', 'Asistió', '73012457', 'C2'),
    ('10001018', 'Viernes', '10:00-12:00', 'No asistió', '74480127', 'F1'),
    ('10001019', 'Viernes', '14:00-16:00', 'Asistió', '70981236', 'H2'),
    ('10001020', 'Viernes', '16:00-18:00', 'Asistió', '73374581', NULL),
    ('10001021', 'Sábado', '08:00-10:00', 'Asistió', '77345120', 'E2'),
    ('10001022', 'Sábado', '10:00-12:00', 'Asistió', '76129034', 'H1'),
    ('10001023', 'Sábado', '14:00-16:00', 'No asistió', '75610982', 'B2'),
    ('10001024', 'Sábado', '16:00-18:00', NULL, '78450216', 'E1');

-- Ingresos registrados (las citas con 'No asistió' no generan ingreso)
INSERT INTO ingreso (codigo_ingreso, fecha, hora_ingreso, turno, tipo_procedimiento, codigo_programacion, codigo_alumno, codigo_personal, codigo_sala, codigo_doctor) VALUES
    ('50001001', '2026-10-19', '08:08', 'Mañana', NULL, '10001001', '2021249145', 2, NULL, NULL),
    ('50001002', '2026-10-19', '10:11', 'Mañana', NULL, '10001002', '2022110419', 3, NULL, NULL),
    ('50001003', '2026-10-19', '14:14', 'Tarde', 'Exodoncia', '10001003', '2022110793', 4, 1, 2),
    ('50001004', '2026-10-19', '16:17', 'Tarde', NULL, '10001004', '2021249013', 1, NULL, NULL),
    ('50001005', '2026-10-20', '10:23', 'Mañana', NULL, '10001006', '2022110647', 3, NULL, NULL),
    ('50001006', '2026-10-20', '14:06', 'Tarde', NULL, '10001007', '2021248902', 4, NULL, NULL),
    ('50001007', '2026-10-20', '16:09', 'Tarde', NULL, '10001008', '2022110236', 1, NULL, NULL),
    ('50001008', '2026-10-21', '08:12', 'Mañana', NULL, '10001009', '2022110582', 2, NULL, NULL),
    ('50001009', '2026-10-21', '10:15', 'Mañana', NULL, '10001010', '2021248861', 3, NULL, NULL),
    ('50001010', '2026-10-21', '16:21', 'Tarde', NULL, '10001012', '2022110419', 1, NULL, NULL),
    ('50001011', '2026-10-22', '08:24', 'Mañana', NULL, '10001013', '2022110793', 2, NULL, NULL),
    ('50001012', '2026-10-22', '10:07', 'Mañana', 'Radiografía panorámica', '10001014', '2021249013', 3, 2, 4),
    ('50001013', '2026-10-22', '14:10', 'Tarde', NULL, '10001015', '2022110378', 4, NULL, NULL),
    ('50001014', '2026-10-22', '16:13', 'Tarde', NULL, '10001016', '2022110647', 1, NULL, NULL),
    ('50001015', '2026-10-23', '08:16', 'Mañana', NULL, '10001017', '2021248902', 2, NULL, NULL),
    ('50001016', '2026-10-23', '14:22', 'Tarde', NULL, '10001019', '2022110582', 4, NULL, NULL),
    ('50001017', '2026-10-23', '16:05', 'Tarde', 'Cirugía de terceros molares', '10001020', '2021248861', 1, 1, 1),
    ('50001018', '2026-10-24', '08:08', 'Mañana', NULL, '10001021', '2021249145', 2, NULL, NULL),
    ('50001019', '2026-10-24', '10:11', 'Mañana', NULL, '10001022', '2022110419', 3, NULL, NULL);

-- Permisos (los dos últimos siguen abiertos)
INSERT INTO permiso (codigo_ingreso, hora_salida, hora_retorno, motivo) VALUES
    ('50001001', '09:05', '09:20', 'Compra de material'),
    ('50001003', '10:40', '10:55', 'Recojo de instrumental en almacén'),
    ('50001007', '15:10', '15:25', 'Consulta con el docente'),
    ('50001010', '10:30', '10:42', 'Compra de material'),
    ('50001010', '11:15', '11:28', 'Servicios higiénicos'),
    ('50001016', '15:00', NULL, 'Compra de material'),
    ('50001018', '09:10', NULL, 'Recojo de radiografía');

-- Ciclos de esterilización (los dos últimos siguen en curso)
INSERT INTO esterilizacion (codigo_ingreso, hora_inicio, hora_fin, asistencia) VALUES
    ('50001001', '09:08', '09:33', 'Asistió'),
    ('50001002', '11:11', '11:36', 'Asistió'),
    ('50001003', '15:14', '15:39', 'Asistió'),
    ('50001004', '17:17', '17:42', 'Asistió'),
    ('50001005', '11:23', '11:48', 'No asistió'),
    ('50001006', '15:06', '15:31', 'Asistió'),
    ('50001007', '17:09', '17:34', 'Asistió'),
    ('50001008', '09:12', '09:37', 'Asistió'),
    ('50001009', '11:15', '11:40', 'Asistió'),
    ('50001010', '17:21', '17:46', 'Asistió'),
    ('50001011', '09:24', '09:49', 'Asistió'),
    ('50001012', '11:07', '11:32', 'Asistió'),
    ('50001013', '15:10', '15:35', 'No asistió'),
    ('50001014', '17:13', '17:38', 'Asistió'),
    ('50001015', '09:16', '09:41', 'Asistió'),
    ('50001016', '15:22', '15:47', 'Asistió'),
    ('50001017', '17:05', '17:30', 'Asistió'),
    ('50001018', '09:08', NULL, 'Asistió'),
    ('50001019', '11:11', NULL, 'Asistió');

COMMIT;

-- Conteo de filas cargadas
SELECT 'paciente' AS tabla, COUNT(*) AS filas FROM paciente
UNION ALL SELECT 'sillon', COUNT(*) FROM sillon
UNION ALL SELECT 'sala', COUNT(*) FROM sala
UNION ALL SELECT 'alumno', COUNT(*) FROM alumno
UNION ALL SELECT 'personal', COUNT(*) FROM personal
UNION ALL SELECT 'doctor', COUNT(*) FROM doctor
UNION ALL SELECT 'programacion', COUNT(*) FROM programacion
UNION ALL SELECT 'ingreso', COUNT(*) FROM ingreso
UNION ALL SELECT 'permiso', COUNT(*) FROM permiso
UNION ALL SELECT 'esterilizacion', COUNT(*) FROM esterilizacion;
