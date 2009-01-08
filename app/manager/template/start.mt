<?= $app->render('system/header') ?>

<h2>アプリケーション管理ツール</h2>

? if (my $target = $app->query->param('app')) {
<h3><?= $target ?> アプリケーション</h3>
<?= $app->render_form ?>

?   if ($app->query->param('status') eq 'stop') {
<h3>ダウンロード</h3>
<ul>
<li><a href="<?= $app->uri_for('manager/download', {app => $target}) ?>">ダウンロード</a></li>
</ul>
?   }
? } else {
<h3>アクティブ</h3>
<ul>
?   for my $dir (<app/*/>) {
?      $dir =~ s|app/(.*)/$|$1|;
<li><a href="<?= $app->uri_for('manager/', {app => $dir}) ?>"><?= $dir ?></a></li>
?   }
</ul>
<h3>停止</h3>
<ul>
?   for my $dir (<var/manager/*/>) {
?      $dir =~ s|var/manager/(.*)/$|$1|;
<li><a href="<?= $app->uri_for('manager/', {app => $dir}) ?>"><?= $dir ?></a></li>
?   }
</ul>
<h3>追加</h3>
<ul>
<li><a href="<?= $app->uri_for('manager/upload') ?>">アップロード</a></li>
</ul>
? }

<hr>
<a href="<?= $app->uri_for('manager/') ?>">管理ツールトップ</a> | 
<a href="<?= $app->admin_logout_uri($app->nanoa_uri) ?>">ログアウト</a>

<?= $app->render('system/footer') ?>
