<?php
require_once 'includes/funciones.php';
requiere_turno();

$fecha = leer_fecha();
$dia   = llamar_funcion('fn_dia_semana', [$fecha]);
$citas = llamar_procedimiento('sp_agenda_dia', [$dia]);

cabecera('Agenda del día', 'agenda.php');
?>
<h1>Agenda del <?= e(mb_strtolower($dia)) ?> <?= fecha_corta($fecha) ?></h1>
<?php filtro_fecha($fecha); ?>
<?php if ($citas): ?>
<table class="lista">
  <thead><tr><th>Bloque</th><th>Cita</th><th>DNI</th><th>Paciente</th><th>Condición</th><th>Sillón</th><th>Piso</th><th>Asistencia</th></tr></thead>
  <tbody>
  <?php foreach ($citas as $c): ?>
    <tr>
      <td><?= e($c['bloque_horario']) ?></td><td><?= e($c['codigo_programacion']) ?></td>
      <td><?= e($c['dni']) ?></td><td><?= e($c['paciente']) ?></td><td><?= e($c['condicion']) ?></td>
      <td><?= e($c['codigo_sillon'] ?? 'Sala') ?></td><td><?= e($c['piso'] ?? '-') ?></td>
      <td><?= e($c['asistencia'] ?? 'Pendiente') ?></td>
    </tr>
  <?php endforeach; ?>
  </tbody>
</table>
<p class="nota"><?= count($citas) ?> citas. Las citas sin sillón corresponden a procedimientos en sala.</p>
<?php else: ?>
<p class="vacio">No hay citas programadas para el <?= e(mb_strtolower($dia)) ?>.</p>
<?php endif; ?>
<?php pie();
