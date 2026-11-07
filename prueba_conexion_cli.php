<?php
/*
 * Prueba de conexión por consola.
 * Uso:  php prueba_conexion_cli.php  [nombre_base_datos]
 */
require_once __DIR__ . '/includes/conexion.php';

$base = $argv[1] ?? DB_NAME;
$info = probar_conexion($base);

echo str_repeat('=', 60), PHP_EOL, " PRUEBA DE CONEXIÓN A LA BASE DE DATOS", PHP_EOL, str_repeat('=', 60), PHP_EOL;
printf(" Servidor : %s:%s\n Usuario  : %s\n Base     : %s\n Tiempo   : %s ms\n",
       $info['host'], $info['puerto'], $info['usuario'], $info['base'], $info['ms']);

if (!$info['ok']) {
    printf("\n RESULTADO: ERROR %s\n %s\n", $info['error_codigo'], $info['error']);
    exit(1);
}
printf(" MySQL    : %s (%s)\n\n RESULTADO: CONEXIÓN EXITOSA\n\n", $info['servidor']['version'], $info['servidor']['charset']);
foreach ($info['tablas'] as $t) {
    printf(" %-18s%8s\n", $t['tabla'], $t['filas']);
}
echo PHP_EOL;
foreach ($info['objetos'] as $o) {
    printf(" %-18s%8s\n", $o['objeto'], $o['cantidad']);
}
echo PHP_EOL, " Acceso directo a tablas: ", $info['acceso_directo'], PHP_EOL, str_repeat('=', 60), PHP_EOL;
