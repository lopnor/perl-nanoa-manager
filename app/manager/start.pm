package manager::start;
use strict;
use warnings;
use utf8;

use base qw(NanoA);

use plugin::admin;
use plugin::form;
use File::Copy;
use File::Remove qw(remove);
use File::Find::Rule;
use File::Slurp qw(slurp);

sub run {
    my $app = shift;
    $app->redirect($app->admin_login_uri) unless $app->is_admin;
    my $q = $app->query;
    my $data_dir = join '/', $app->config->data_dir, $app->config->app_name;
    mkdir $data_dir unless -d $data_dir;
    my $c = {};
    if ( my $target = $q->param('app') ) {
        my $dirs = {
            active => join('/', NanoA::app_dir, $target),
            stop => join('/', $data_dir, $target),
        };
        my $current;
        for (keys %$dirs) {
            $current = $_ if -d $dirs->{$_};
        }
        $app->redirect($app->uri_for('manager/')) unless $current;
        unless ($q->param('status')) {
            $q->param(status => $current);
        }
        if ($current eq 'stop') {
            $c->{error} = &syntax_check($app, $data_dir, $target);
        }
        define_form(
            fields => [
                status => {
                    type => 'radio',
                    label => '状態',
                    options => [
                        active => {
                            label => 'アクティブ',
                            disabled => (defined $c->{error} && scalar @{$c->{error}}) ? 1 : undef,
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
        if ($q->request_method eq 'POST' && $app->validate_form) {
            if ($q->param('status') eq 'delete') {
                remove(\1, $dirs->{$current});
            } elsif ($q->param('status') ne $current) {
                move($dirs->{$current}, $dirs->{$q->param('status')});
            }
            $app->redirect($app->uri_for('manager/', {app => $target}));
        }
    }
    $app->render('manager/template/start', $c);
}

sub syntax_check {
    my ($app, $data_dir, $target) = @_;
    my @error;
    my @files = File::Find::Rule->file()
            ->name('*.pm', '*.mt')
            ->in(File::Spec->catdir($data_dir,$target));
    for my $file (@files) {
        my $module = File::Spec->abs2rel($file, $data_dir);
        $module =~ s{/}{::}g;
        my $result;
        if ($module =~ s{.mt$}{}) {
            $result = eval {NanoA::TemplateLoader::__load($app->config,$module,$file)};
        } elsif ($module =~ s{.pm$}{}) {
            $result = do $file;
        }
        unless ($result) {
            push @error, {$file => $@} if $@;
            push @error, {$file => $!} if $!;
            push @error, {$file => "couldn't do file"};
        }
    }
    return \@error;
}

1;
