<?php
require_once 'includes/funciones.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $codigo = (int)($_POST['codigo_personal'] ?? 0);
    $turno  = $_POST['turno'] ?? '';
    $fila   = llamar_procedimiento('sp_obtener_personal', [$codigo]);
    if (!$fila || !in_array($turno, TURNOS, true)) {
        $_SESSION['aviso'] = 'Seleccione su nombre y el turno.';
    } else {
        $_SESSION['personal'] = $fila[0];
        $_SESSION['turno'] = $turno;
        header('Location: index.php');
        exit;
    }
}
$lista = llamar_procedimiento('sp_listar_personal');

cabecera('Inicio de turno', 'turno.php');
?>
<div class="caja-turno">
  <h1>Inicio de turno</h1>
  <p class="nota">Seleccione su nombre y el turno. Los ingresos que se validen quedarán a su nombre.</p>
  <form method="post">
    <label>Personal de recepción
      <select name="codigo_personal" required>
        <option value="">Seleccione...</option>
        <?php foreach ($lista as $p): ?>
          <option value="<?= e($p['codigo_personal']) ?>"><?= e($p['nombre']) ?></option>
        <?php endforeach; ?>
      </select>
    </label>
    <label>Turno
      <select name="turno" required>
        <?php foreach (TURNOS as $t): ?><option><?= e($t) ?></option><?php endforeach; ?>
      </select>
    </label>
    <button class="boton">Iniciar turno</button>
  </form>
  <p class="nota"><a href="prueba_conexion.php">Probar la conexión a la base de datos</a></p>
</div>
<?php pie();
