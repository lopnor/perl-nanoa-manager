package manager::start;
use strict;
use warnings;
use utf8;

use base qw(NanoA);

use plugin::admin;
use plugin::form;
use File::Copy;
use File::Remove qw(remove);

sub run {
    my $app = shift;
    $app->redirect($app->admin_login_uri) unless $app->is_admin;
    my $q = $app->query;
    my $data_dir = join '/', $app->config->data_dir, $app->config->app_name;
    mkdir $data_dir unless -d $data_dir;
    my $target = $q->param('app');
    my $dirs = {
        active => join('/', NanoA::app_dir, $target),
        stop => join('/', $data_dir, $target),
    };
    my $current;
    for (keys %$dirs) {
        $current = $_ if -d $dirs->{$_};
    }
    $app->redirect($app->uri_for('manager/')) unless $current;
    if ($target) {
        unless ($q->param('status')) {
            $q->param(status => $current);
        }
        define_form(
            fields => [
                status => {
                    type => 'radio',
                    label => '状態',
                    options => [
                        active => {
                            label => 'アクティブ',
                        },
                        stop => {
                            label => '停止',
                            disabled => $target =~ m{^(?:plugin|system|manager)},
                        },
                        delete => {
                            label => '削除',
                            disabled => ($current eq 'active') ? 1 : undef,
                        },
                    ],
                },
                app => {
                    type => 'hidden',
                    value => $target,
                },
            ],
            submit_label => '状態を変更',
        );
    }
    if ($q->request_method eq 'POST' && $app->validate_form) {
        if ($q->param('status') eq 'delete') {
            remove(\1, $dirs->{$current});
        } elsif ($q->param('status') ne $current) {
            move($dirs->{$current}, $dirs->{$q->param('status')});
        }
        $app->redirect($app->uri_for('manager/', {app => $target}));
    }
    $app->render('manager/template/start');
}

1;
