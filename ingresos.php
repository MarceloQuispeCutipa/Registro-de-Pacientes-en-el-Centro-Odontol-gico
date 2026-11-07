<?php
require_once 'includes/funciones.php';
requiere_turno();

$fecha    = leer_fecha();
$opciones = array_merge(TURNOS, ['Todos']);
$turno    = $_GET['turno'] ?? $_SESSION['turno'];
if (!in_array($turno, $opciones, true)) {
    $turno = $_SESSION['turno'];
}
// NULL en el turno = todo el día (así lo interpreta sp_ingresos_dia)
$filas = llamar_procedimiento('sp_ingresos_dia', [$fecha, $turno === 'Todos' ? null : $turno]);
$todos = $turno === 'Todos';

cabecera('Ingresos del día', 'ingresos.php');
?>
<h1>Ingresos del <?= fecha_corta($fecha) ?><?= $todos ? '' : ' &middot; turno ' . e(mb_strtolower($turno)) ?></h1>
<?php filtro_fecha($fecha, $opciones, $turno); ?>
<?php if ($filas): ?>
<table class="lista">
  <thead><tr><th>Hora</th><th>Ingreso</th><?= $todos ? '<th>Turno</th>' : '' ?><th>Paciente</th><th>Alumno</th><th>Ubicación</th><th>Procedimiento</th><th>Validado por</th></tr></thead>
  <tbody>
  <?php foreach ($filas as $f): ?>
    <tr>
      <td><?= hora($f['hora_ingreso']) ?></td><td><?= e($f['codigo_ingreso']) ?></td>
      <?= $todos ? '<td>' . e($f['turno']) . '</td>' : '' ?>
      <td><?= e($f['paciente']) ?></td><td><?= e($f['alumno']) ?></td><td><?= e($f['ubicacion']) ?></td>
      <td><?php if ($f['tipo_procedimiento']): ?><?= e($f['tipo_procedimiento']) ?><br><small><?= e($f['doctor']) ?></small><?php else: ?>-<?php endif; ?></td>
      <td><?= e($f['validado_por']) ?></td>
    </tr>
  <?php endforeach; ?>
  </tbody>
</table>
<p class="nota"><?= count($filas) ?> ingresos.</p>
<?php else: ?>
<p class="vacio">No hay ingresos registrados para esta fecha y turno.</p>
<?php endif; ?>
<?php pie();
