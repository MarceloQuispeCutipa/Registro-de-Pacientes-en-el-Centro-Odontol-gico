<?php
require_once 'includes/funciones.php';
requiere_turno();

$codigo = strtoupper(trim($_GET['codigo'] ?? ''));
$alumno = null;
$atenciones = [];
if ($codigo !== '') {
    $fila = llamar_procedimiento('sp_buscar_alumno_qr', [$codigo]);
    if ($fila) {
        $alumno = $fila[0];
        $atenciones = llamar_procedimiento('sp_atenciones_alumno', [$alumno['codigo_alumno']]);
    }
}

cabecera('Validar alumno', 'qr.php');
?>
<h1>Validar alumno por código QR</h1>
<form class="filtro" method="get">
  <label>Código QR <input name="codigo" value="<?= e($codigo) ?>" placeholder="Ej. QR72623725" autofocus></label>
  <button class="boton">Validar</button>
</form>
<?php if ($codigo !== ''): ?>
  <?php if ($alumno): ?>
    <div class="estado ok">Alumno registrado</div>
    <table class="ficha">
      <tr><th>Código de alumno</th><td><?= e($alumno['codigo_alumno']) ?></td></tr>
      <tr><th>Código QR</th><td><?= e($alumno['codigo_qr']) ?></td></tr>
      <tr><th>Nombre</th><td><?= e($alumno['nombre']) ?></td></tr>
      <tr><th>Atenciones registradas</th><td><?= count($atenciones) ?></td></tr>
    </table>
    <?php if ($atenciones): ?>
    <h2>Historial de atenciones</h2>
    <table class="lista">
      <thead><tr><th>Fecha</th><th>Hora</th><th>Turno</th><th>Paciente</th><th>Ubicación</th></tr></thead>
      <tbody>
      <?php foreach ($atenciones as $a): ?>
        <tr><td><?= fecha_corta($a['fecha']) ?></td><td><?= hora($a['hora_ingreso']) ?></td>
            <td><?= e($a['turno']) ?></td><td><?= e($a['paciente']) ?></td><td><?= e($a['ubicacion']) ?></td></tr>
      <?php endforeach; ?>
      </tbody>
    </table>
    <?php endif; ?>
  <?php else: ?>
    <div class="estado mal">El código <?= e($codigo) ?> no corresponde a ningún alumno registrado</div>
  <?php endif; ?>
<?php endif; ?>
<?php pie();
