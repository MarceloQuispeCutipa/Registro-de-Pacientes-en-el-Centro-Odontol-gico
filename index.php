<?php
require_once 'includes/funciones.php';
requiere_turno();

$fecha = leer_fecha();
$turno = $_SESSION['turno'];
$dia   = llamar_funcion('fn_dia_semana', [$fecha]);

$resumen = [
    'Citas programadas (' . $dia . ')' => llamar_funcion('fn_citas_dia', [$dia]),
    'Ingresos del día'                 => llamar_funcion('fn_ingresos_dia', [$fecha, null]),
    'Ingresos turno ' . mb_strtolower($turno) => llamar_funcion('fn_ingresos_dia', [$fecha, $turno]),
    'Alumnos fuera con permiso'        => llamar_funcion('fn_permisos_abiertos', [$fecha]),
    'Esterilizaciones en curso'        => llamar_funcion('fn_esterilizaciones_curso', [$fecha]),
];
$sillones = llamar_procedimiento('sp_ocupacion_sillones', [$fecha, $turno]);
$ocupados = count(array_filter($sillones, fn($s) => $s['estado'] === 'Ocupado'));

cabecera('Inicio', 'index.php');
?>
<h1>Resumen del <?= e(mb_strtolower($dia)) ?> <?= fecha_corta($fecha) ?></h1>
<?php filtro_fecha($fecha); ?>
<div class="tarjetas">
  <?php foreach ($resumen as $texto => $valor): ?>
    <div class="tarjeta"><span><?= e($valor) ?></span><?= e($texto) ?></div>
  <?php endforeach; ?>
</div>
<h2>Sillones en el turno <?= e(mb_strtolower($turno)) ?>
  <small class="nota">(<?= $ocupados ?> ocupados de <?= e(llamar_funcion('fn_total_sillones')) ?>)</small></h2>
<div class="sillones">
  <?php foreach ($sillones as $s): ?>
    <div class="sillon <?= $s['estado'] === 'Ocupado' ? 'ocupado' : '' ?>">
      <b><?= e($s['codigo_sillon']) ?></b><small>Piso <?= e($s['piso']) ?></small><small><?= e($s['estado']) ?></small>
    </div>
  <?php endforeach; ?>
</div>
<?php pie();
