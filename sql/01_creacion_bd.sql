-- =====================================================================
--  Script 1 - Creación de la base de datos
--  Sistema de Ingreso de Pacientes - Centro Odontológico UCSM
--  Gestor: MySQL 8.0 (motor InnoDB). Ejecutar en MySQL Workbench.
-- =====================================================================

SET NAMES utf8mb4;

DROP DATABASE IF EXISTS bd_ingreso_odontologico;
CREATE DATABASE bd_ingreso_odontologico
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE bd_ingreso_odontologico;

-- ---------------------------------------------------------------------
-- Tablas de catálogo
-- ---------------------------------------------------------------------
CREATE TABLE paciente (
    dni        CHAR(8)      NOT NULL,
    nombre     VARCHAR(60)  NOT NULL,
    condicion  VARCHAR(8)   NOT NULL,
    CONSTRAINT pk_paciente PRIMARY KEY (dni),
    CONSTRAINT ck_paciente_dni CHECK (REGEXP_LIKE(dni, '^[0-9]{8}$')),
    CONSTRAINT ck_paciente_condicion CHECK (condicion COLLATE utf8mb4_bin IN ('Adulto', 'Niño', 'Prenatal'))
) ENGINE = InnoDB COMMENT = 'Pacientes atendidos en el Centro Odontológico';

CREATE TABLE sillon (
    codigo_sillon  VARCHAR(3)  NOT NULL,
    piso           SMALLINT    NOT NULL,
    CONSTRAINT pk_sillon PRIMARY KEY (codigo_sillon),
    CONSTRAINT ck_sillon_codigo CHECK (REGEXP_LIKE(codigo_sillon, '^[A-Z][0-9]{1,2}$', 'c')),
    CONSTRAINT ck_sillon_piso CHECK (piso BETWEEN 1 AND 3)
) ENGINE = InnoDB COMMENT = 'Sillones odontológicos por piso';

CREATE TABLE sala (
    codigo_sala  SMALLINT     NOT NULL,
    nombre_sala  VARCHAR(30)  NOT NULL,
    CONSTRAINT pk_sala PRIMARY KEY (codigo_sala),
    CONSTRAINT ck_sala_codigo CHECK (codigo_sala BETWEEN 1 AND 99)
) ENGINE = InnoDB COMMENT = 'Salas especializadas: Cirugía y Diagnóstico/Radiología';

CREATE TABLE alumno (
    codigo_alumno  VARCHAR(10)  NOT NULL,
    codigo_qr      VARCHAR(10)  NOT NULL,
    nombre         VARCHAR(60)  NOT NULL,
    CONSTRAINT pk_alumno PRIMARY KEY (codigo_alumno),
    CONSTRAINT uq_alumno_qr UNIQUE (codigo_qr),
    CONSTRAINT ck_alumno_codigo CHECK (REGEXP_LIKE(codigo_alumno, '^[0-9]{1,10}$'))
) ENGINE = InnoDB COMMENT = 'Alumnos tratantes con su código QR de acceso';

CREATE TABLE personal (
    codigo_personal  SMALLINT     NOT NULL,
    nombre           VARCHAR(60)  NOT NULL,
    CONSTRAINT pk_personal PRIMARY KEY (codigo_personal),
    CONSTRAINT ck_personal_codigo CHECK (codigo_personal BETWEEN 1 AND 9999)
) ENGINE = InnoDB COMMENT = 'Personal de recepción que valida los ingresos';

CREATE TABLE doctor (
    codigo_doctor  SMALLINT     NOT NULL,
    nombre         VARCHAR(60)  NOT NULL,
    CONSTRAINT pk_doctor PRIMARY KEY (codigo_doctor),
    CONSTRAINT ck_doctor_codigo CHECK (codigo_doctor BETWEEN 1 AND 9999)
) ENGINE = InnoDB COMMENT = 'Doctores que supervisan los procedimientos';

-- ---------------------------------------------------------------------
-- Tablas de movimiento
-- ---------------------------------------------------------------------
CREATE TABLE programacion (
    codigo_programacion  VARCHAR(8)   NOT NULL,
    dia_semana           VARCHAR(9)   NOT NULL,
    bloque_horario       VARCHAR(11)  NOT NULL,
    asistencia           VARCHAR(10)  NULL,
    dni                  CHAR(8)      NOT NULL,
    codigo_sillon        VARCHAR(3)   NULL,
    CONSTRAINT pk_programacion PRIMARY KEY (codigo_programacion),
    CONSTRAINT fk_programacion_paciente FOREIGN KEY (dni)
        REFERENCES paciente (dni) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_programacion_sillon FOREIGN KEY (codigo_sillon)
        REFERENCES sillon (codigo_sillon) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT ck_programacion_codigo CHECK (REGEXP_LIKE(codigo_programacion, '^[0-9]{4,8}$')),
    CONSTRAINT ck_programacion_dia CHECK (dia_semana COLLATE utf8mb4_bin IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado')),
    CONSTRAINT ck_programacion_bloque CHECK (
        REGEXP_LIKE(bloque_horario, '^([01][0-9]|2[0-3]):[0-5][0-9]-([01][0-9]|2[0-3]):[0-5][0-9]$')
        AND SUBSTRING(bloque_horario, 1, 5) < SUBSTRING(bloque_horario, 7, 5)),
    CONSTRAINT ck_programacion_asistencia CHECK (asistencia IS NULL OR asistencia COLLATE utf8mb4_bin IN ('Asistió', 'No asistió'))
) ENGINE = InnoDB COMMENT = 'Citas programadas de los pacientes';

CREATE TABLE ingreso (
    codigo_ingreso       VARCHAR(8)   NOT NULL,
    fecha                DATE         NOT NULL,
    hora_ingreso         TIME         NOT NULL,
    turno                VARCHAR(6)   NOT NULL,
    tipo_procedimiento   VARCHAR(30)  NULL,
    codigo_programacion  VARCHAR(8)   NOT NULL,
    codigo_alumno        VARCHAR(10)  NOT NULL,
    codigo_personal      SMALLINT     NOT NULL,
    codigo_sala          SMALLINT     NULL,
    codigo_doctor        SMALLINT     NULL,
    CONSTRAINT pk_ingreso PRIMARY KEY (codigo_ingreso),
    CONSTRAINT uq_ingreso_programacion UNIQUE (codigo_programacion),
    CONSTRAINT fk_ingreso_programacion FOREIGN KEY (codigo_programacion)
        REFERENCES programacion (codigo_programacion) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ingreso_alumno FOREIGN KEY (codigo_alumno)
        REFERENCES alumno (codigo_alumno) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ingreso_personal FOREIGN KEY (codigo_personal)
        REFERENCES personal (codigo_personal) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ingreso_sala FOREIGN KEY (codigo_sala)
        REFERENCES sala (codigo_sala) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ingreso_doctor FOREIGN KEY (codigo_doctor)
        REFERENCES doctor (codigo_doctor) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_ingreso_codigo CHECK (REGEXP_LIKE(codigo_ingreso, '^[0-9]{4,8}$')),
    CONSTRAINT ck_ingreso_turno CHECK (turno COLLATE utf8mb4_bin IN ('Mañana', 'Tarde'))
) ENGINE = InnoDB COMMENT = 'Evento de ingreso generado por una programación (1:1)';

CREATE TABLE permiso (
    codigo_ingreso  VARCHAR(8)   NOT NULL,
    hora_salida     TIME         NOT NULL,
    hora_retorno    TIME         NULL,
    motivo          VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_permiso PRIMARY KEY (codigo_ingreso, hora_salida),
    CONSTRAINT fk_permiso_ingreso FOREIGN KEY (codigo_ingreso)
        REFERENCES ingreso (codigo_ingreso) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_permiso_retorno CHECK (hora_retorno IS NULL OR hora_retorno > hora_salida)
) ENGINE = InnoDB COMMENT = 'Salidas temporales del alumno durante un ingreso (entidad débil)';

CREATE TABLE esterilizacion (
    codigo_ingreso  VARCHAR(8)   NOT NULL,
    hora_inicio     TIME         NOT NULL,
    hora_fin        TIME         NULL,
    asistencia      VARCHAR(10)  NOT NULL,
    CONSTRAINT pk_esterilizacion PRIMARY KEY (codigo_ingreso, hora_inicio),
    CONSTRAINT fk_esterilizacion_ingreso FOREIGN KEY (codigo_ingreso)
        REFERENCES ingreso (codigo_ingreso) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_esterilizacion_fin CHECK (hora_fin IS NULL OR hora_fin > hora_inicio),
    CONSTRAINT ck_esterilizacion_asistencia CHECK (asistencia COLLATE utf8mb4_bin IN ('Asistió', 'No asistió'))
) ENGINE = InnoDB COMMENT = 'Ciclos de esterilización de instrumental por ingreso (entidad débil)';

-- ---------------------------------------------------------------------
-- Índices secundarios
-- ---------------------------------------------------------------------
CREATE INDEX ix_paciente_nombre      ON paciente (nombre);
CREATE INDEX ix_programacion_dni     ON programacion (dni);
CREATE INDEX ix_programacion_sillon  ON programacion (codigo_sillon);
CREATE INDEX ix_programacion_agenda  ON programacion (dia_semana, bloque_horario);
CREATE INDEX ix_ingreso_fecha_turno  ON ingreso (fecha, turno);
CREATE INDEX ix_ingreso_alumno       ON ingreso (codigo_alumno, fecha);
CREATE INDEX ix_ingreso_personal     ON ingreso (codigo_personal);
CREATE INDEX ix_ingreso_sala         ON ingreso (codigo_sala);
CREATE INDEX ix_ingreso_doctor       ON ingreso (codigo_doctor);
CREATE INDEX ix_permiso_abierto      ON permiso (codigo_ingreso, hora_retorno);
CREATE INDEX ix_esterilizacion_curso ON esterilizacion (codigo_ingreso, hora_fin);

-- ---------------------------------------------------------------------
-- Triggers: no se registra un procedimiento sin sala
-- (MySQL no permite un CHECK sobre codigo_sala porque tiene ON UPDATE CASCADE)
-- ---------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER trg_ingreso_bi
BEFORE INSERT ON ingreso
FOR EACH ROW
BEGIN
    IF NEW.tipo_procedimiento IS NOT NULL AND NEW.codigo_sala IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Si existe un tipo de procedimiento, se requiere obligatoriamente un código de sala.';
    END IF;
END$$

CREATE TRIGGER trg_ingreso_bu
BEFORE UPDATE ON ingreso
FOR EACH ROW
BEGIN
    IF NEW.tipo_procedimiento IS NOT NULL AND NEW.codigo_sala IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Si existe un tipo de procedimiento, se requiere obligatoriamente un código de sala.';
    END IF;
END$$

DELIMITER ;
