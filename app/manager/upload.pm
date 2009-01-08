package manager::upload;
use strict;
use warnings;
use utf8;

use base qw(NanoA);

use Archive::Tar;
use File::Temp;
use File::Spec;

use plugin::admin;
use plugin::form;

BEGIN {
    $CGI::Simple::POST_MAX = 1_048_576;
    $CGI::Simple::DISABLE_UPLOADS = 0;
};

define_form(
    {
        fields => [
            file => {
                type => 'file',
                label => 'アプリケーション(.tar.gz形式)',
                required => 1,
                mime => 'application/x-gzip',
            },
        ],
        submit_label => 'upload',
    }
);
sub run {
    my $app = shift;
    my $q = $app->query;
    my $c = {};
    if ($q->request_method eq 'POST' && $app->validate_form) {
        my $data_dir = join '/', $app->config->data_dir, $app->config->app_name;
        my $filename = $q->param('file');
        my $tmp = File::Temp->new;
        close $tmp;
        $q->upload($filename, $tmp->filename);
        my $archive = Archive::Tar->new;
        $archive->read($tmp->filename, 1);
        my $found;
        for my $dir (<app/*/>) {
            $dir =~ s{app/([^/]+)/}{$1};
            $archive->contains_file("${dir}/") and $found = $dir and last;
        }
        if ($found) {
            $c->{error} = "同名のアプリケーション ( ${found} ) が現在アクティブです!";
        } else {
            for ($archive->list_files) {
                $archive->extract_file($_,File::Spec->catfile($data_dir, $_))
                    or die $@;
            }
            $app->redirect($app->uri_for('manager/'));
        }
    }
    $app->render('manager/template/upload', $c);
}

1;
