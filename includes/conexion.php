<?php

require_once __DIR__ . '/../config.php';

/**
 * Abre una conexión a la base de datos cuyo nombre se recibe como parámetro.
 */
function conectar(string $baseDatos): PDO
{
    $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . $baseDatos . ';charset=utf8mb4';
    return new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
        PDO::ATTR_TIMEOUT            => 5,
    ]);
}

/**
 * Conexión única por petición a la base configurada en config.php.
 */
function db(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $pdo = conectar(DB_NAME);
    }
    return $pdo;
}

/**
 * Llama a un procedimiento almacenado y devuelve sus filas.
 * Ejemplo: llamar_procedimiento('sp_agenda_dia', ['Martes'])  ->  CALL sp_agenda_dia(?)
 */
function llamar_procedimiento(string $nombre, array $parametros = [], ?PDO $pdo = null): array
{
    if (!preg_match('/^sp_[a-z_]+$/', $nombre)) {
        throw new InvalidArgumentException("Nombre de procedimiento no válido: $nombre");
    }
    $pdo = $pdo ?? db();
    $marcas = implode(', ', array_fill(0, count($parametros), '?'));
    $stmt = $pdo->prepare("CALL $nombre($marcas)");
    $stmt->execute(array_values($parametros));
    $filas = $stmt->fetchAll();
    while ($stmt->nextRowset()) {
        // descarta el resultado de estado que MySQL agrega al final de cada CALL
    }
    $stmt->closeCursor();
    return $filas;
}

/**
 * Llama a una función almacenada y devuelve su valor.
 */
function llamar_funcion(string $nombre, array $parametros = [], ?PDO $pdo = null)
{
    if (!preg_match('/^fn_[a-z_]+$/', $nombre)) {
        throw new InvalidArgumentException("Nombre de función no válido: $nombre");
    }
    $pdo = $pdo ?? db();
    $marcas = implode(', ', array_fill(0, count($parametros), '?'));
    $stmt = $pdo->prepare("SELECT $nombre($marcas) AS valor");
    $stmt->execute(array_values($parametros));
    $valor = $stmt->fetchColumn();
    $stmt->closeCursor();
    return $valor;
}

/**
 * Prueba la conexión a una base de datos y reúne información con sus procedimientos.
 */
function probar_conexion(string $baseDatos): array
{
    $info = [
        'ok' => false, 'host' => DB_HOST, 'puerto' => DB_PORT,
        'usuario' => DB_USER, 'base' => $baseDatos,
    ];
    $inicio = microtime(true);
    try {
        $pdo = conectar($baseDatos);
        $info['ms'] = round((microtime(true) - $inicio) * 1000, 1);

        $info['servidor'] = llamar_procedimiento('sp_info_servidor', [], $pdo)[0];
        $info['tablas']   = llamar_procedimiento('sp_conteo_tablas', [], $pdo);
        $info['objetos']  = llamar_procedimiento('sp_objetos_base', [], $pdo);
        $info['dia_hoy']  = llamar_funcion('fn_dia_semana', [date('Y-m-d')], $pdo);

        // Prueba de seguridad: el usuario del aplicativo NO debe poder leer tablas directamente
        try {
            $pdo->query('SELECT COUNT(*) FROM paciente');
            $info['acceso_directo'] = 'Permitido (revisar permisos del usuario)';
        } catch (PDOException $e) {
            $info['acceso_directo'] = 'Bloqueado: ' . $e->errorInfo[2];
        }
        $info['ok'] = true;
    } catch (PDOException $e) {
        $info['ms'] = $info['ms'] ?? round((microtime(true) - $inicio) * 1000, 1);
        $info['error_codigo'] = $e->errorInfo[1] ?? $e->getCode();
        $info['error'] = $e->getMessage();
    }
    return $info;
}
