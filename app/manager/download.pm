package manager::download;
use strict;
use warnings;
use utf8;

use base qw(NanoA);

use plugin::admin;
use File::Spec;

sub run {
    my $app = shift;
    $app->redirect($app->admin_login_uri) unless $app->is_admin;
    my $target = $app->query->param('app') or $app->redirect($app->uri_for('manager/'));
    my $data_dir = File::Spec->catdir( $app->config->data_dir, $app->config->app_name );
    my $app_dir = File::Spec->catdir($data_dir, $target);
    -d $app_dir or $app->redirect($app->uri_for('manager/'));
    $app->{headers}->{'-type'} = 'application/x-gzip';
    $app->{headers}->{'Content-Disposition'} = "attachment; filename=${target}.tar.gz";
    open my $fh, "tar -C $data_dir -cO $target | gzip |";
    local $/;
    my $archive = raw_string(<$fh>);
    close $fh;
    return $archive;
}

1;
