<?= $app->render('system/header') ?>

<h2>アプリケーション管理ツール</h2>

<h3>追加</h3>
? if ($c->{error}) {
<div style="color:#c00">※ <?= $c->{error} ?></div>
? }
<?= $app->render_form ?>
<hr>
<a href="<?= $app->uri_for('manager/') ?>">管理ツールトップ</a> | 
<a href="<?= $app->admin_logout_uri($app->nanoa_uri) ?>">ログアウト</a>

<?= $app->render('system/footer') ?>
