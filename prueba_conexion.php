<?php
require_once 'includes/funciones.php';

// Se pasa el nombre de la base de datos a probar
$info = probar_conexion(DB_NAME);

cabecera('Prueba de conexión', 'prueba_conexion.php');
?>
<h1>Prueba de conexión</h1>
<p class="nota">Esta pantalla abre una conexión nueva a MySQL con los datos de <code>config.php</code>
y consulta la base llamando a sus procedimientos y funciones.</p>

<?php if ($info['ok']): ?>
  <div class="estado ok">Conexión exitosa &middot; respondió en <?= e($info['ms']) ?> ms</div>
<?php else: ?>
  <div class="estado mal">No se pudo conectar &middot; error <?= e($info['error_codigo']) ?></div>
  <p><strong>Mensaje de MySQL:</strong> <?= e($info['error']) ?></p>
  <ul class="nota">
    <li>Revise que el servicio MySQL80 esté iniciado.</li>
    <li>Revise host, puerto, usuario y contraseña en <code>config.php</code>.</li>
    <li>Revise que exista la base <code><?= e($info['base']) ?></code> (scripts 01 y 02).</li>
    <li>Si faltan las rutinas o el usuario, ejecute <code>sql/09</code> y <code>sql/08</code>.</li>
  </ul>
<?php endif; ?>

<table class="ficha">
  <tr><th>Servidor</th><td><?= e($info['host']) ?>:<?= e($info['puerto']) ?></td></tr>
  <tr><th>Usuario configurado</th><td><?= e($info['usuario']) ?></td></tr>
  <tr><th>Base de datos</th><td><?= e($info['base']) ?></td></tr>
  <?php if ($info['ok']): $s = $info['servidor']; ?>
  <tr><th>Usuario conectado</th><td><?= e($s['usuario_conectado']) ?></td></tr>
  <tr><th>Versión de MySQL</th><td><?= e($s['version']) ?></td></tr>
  <tr><th>Juego de caracteres</th><td><?= e($s['charset']) ?> / <?= e($s['collation']) ?></td></tr>
  <tr><th>Hora del servidor</th><td><?= e($s['hora_servidor']) ?> (<?= e($info['dia_hoy']) ?>)</td></tr>
  <tr><th>Acceso directo a tablas</th><td><?= e($info['acceso_directo']) ?></td></tr>
  <?php endif; ?>
</table>

<?php if ($info['ok']): ?>
<div class="dos">
  <section>
    <h2>Tablas (<?= count($info['tablas']) ?>) &middot; <code>CALL sp_conteo_tablas()</code></h2>
    <table class="lista">
      <thead><tr><th>Tabla</th><th class="num">Filas</th></tr></thead>
      <tbody>
      <?php foreach ($info['tablas'] as $t): ?>
        <tr><td><?= e($t['tabla']) ?></td><td class="num"><?= e($t['filas']) ?></td></tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </section>
  <section>
    <h2>Objetos de la base &middot; <code>CALL sp_objetos_base()</code></h2>
    <table class="lista">
      <thead><tr><th>Objeto</th><th class="num">Cantidad</th></tr></thead>
      <tbody>
      <?php foreach ($info['objetos'] as $o): ?>
        <tr><td><?= e($o['objeto']) ?></td><td class="num"><?= e($o['cantidad']) ?></td></tr>
      <?php endforeach; ?>
      </tbody>
    </table>
  </section>
</div>
<?php endif; ?>

<p><a class="boton" href="prueba_conexion.php">Probar de nuevo</a>
<?php if ($info['ok'] && empty($_SESSION['personal'])): ?><a class="boton sec" href="turno.php">Ir al inicio de turno</a><?php endif; ?></p>
<?php pie();
