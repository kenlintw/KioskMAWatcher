#!/usr/bin/perl
# =============================================================================
# kioskMA.pl -- Kiosk Maintenance Page automation (Perl port of the .bat set)
# =============================================================================
#
# Subcommands:
#   watch    Poll for show_maintenance.flag and run launch when it appears.
#   launch   Stop the kiosk app and start Edge in kiosk mode.
#   trigger  Create the show_maintenance.flag (manual / test).
#   show-cfg Print the effective configuration and exit.
#
# Configuration is loaded from --config=<file> (a simple key=value file),
# with built-in defaults below. Run with no args to see usage.
#
# Exit codes:
#   0   success
#   1   bad CLI / missing dependency / I/O failure
#   2   launch sequence hit a non-fatal error (caller may want to log it)
# =============================================================================

use strict;
use warnings;
use feature 'say';

use Getopt::Long qw(GetOptions);
use File::Basename qw(dirname);
use Time::HiRes  qw(sleep);
use POSIX        qw(strftime);
use Win32::OLE;

# -----------------------------------------------------------------------------
# Built-in defaults -- override via --config=<file>
# -----------------------------------------------------------------------------
my %CFG = (
    scripts_dir   => 'C:/Users/Miramar/Documents/scripts',
    kill_tool     => 'C:/ITKiosk/Tool/KillMainApModule.exe',
    edge_exe      => 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
    ma_page       => 'file:///C:/MAPage/KioskMA.html',
    log_file      => '',                    # empty => scripts_dir/launchMAPage.log
    poll_seconds  => 5,
    kill_wait     => 2,                     # pause after killing the kiosk app
    edge_wait     => 1,                     # pause after killing old Edge
    activate_wait => 3,                     # pause before AppActivate('Edge')
    window_title  => 'Edge',                # AppActivate target
);

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
sub now_stamp { strftime('%Y-%m-%dT%H:%M:%S', localtime) }

sub effective_log_path {
    my $p = $CFG{log_file};
    $p = "$CFG{scripts_dir}/launchMAPage.log" if $p eq '';
    return $p;
}

sub log_line {
    my ($msg) = @_;
    my $line = '[' . now_stamp() . "] $msg\n";
    print {*STDOUT} $line;
    my $log = effective_log_path();
    if (open my $fh, '>>', $log) {
        print {$fh} $line;
        close $fh;
    }
}

sub load_config {
    my ($path) = @_;
    return unless defined $path && $path ne '';
    open my $fh, '<', $path
        or die "Cannot read config $path: $!\n";
    while (my $raw = <$fh>) {
        chomp $raw;
        $raw =~ s/^\s+//; $raw =~ s/\s+$//;
        next if $raw eq '' || $raw =~ /^#/;
        if ($raw =~ /^([A-Za-z_]\w*)\s*=\s*(.*)$/) {
            my ($k, $v) = ($1, $2);
            $v =~ s/^['"]//; $v =~ s/['"]$//;   # strip a single matched pair
            $CFG{$k} = $v;
        }
        else {
            warn "Ignored bad line in $path: $raw\n";
        }
    }
    close $fh;
}

sub run_and_log {
    my ($cmd, $desc) = @_;
    my $log = effective_log_path();
    log_line("$desc: $cmd");
    my $rc = system("$cmd >> \"$log\" 2>&1");
    my $code = $rc >> 8;
    log_line(sprintf('%s exited %d', $desc, $code)) if $code != 0;
    return $code;
}

# -----------------------------------------------------------------------------
# Subcommand: watch
# -----------------------------------------------------------------------------
sub cmd_watch {
    my %opt = (interval => $CFG{poll_seconds}, once => 0);
    GetOptions(
        'interval=i' => \$opt{interval},
        'once'       => \$opt{once},
        'config=s'   => \(my $cfg),
    ) or die "Bad options for 'watch'\n";
    load_config($cfg);

    log_line(sprintf('Watcher started (pid=%d, interval=%ds)',
                     $$,
                     $opt{interval}));

    while (1) {
        my $flag = "$CFG{scripts_dir}/show_maintenance.flag";
        if (-e $flag) {
            log_line("Flag detected: $flag");
            if (!unlink $flag) {
                log_line("WARN: could not delete $flag: $!");
            }
            cmd_launch();
        }
        last if $opt{once};
        sleep $opt{interval};
    }
    log_line('Watcher exiting (--once).');
}

# -----------------------------------------------------------------------------
# Subcommand: launch
# -----------------------------------------------------------------------------
sub cmd_launch {
    GetOptions('config=s' => \(my $cfg)) or die "Bad options for 'launch'\n";
    load_config($cfg);

    log_line('Maintenance launch started.');

    # 1. Stop the Kiosk application.
    my $rc = run_and_log(qq{"$CFG{kill_tool}"}, 'Kill kiosk app');
    log_line("WARN: kill tool returned $rc") if $rc != 0;
    sleep $CFG{kill_wait};

    # 2. Force-close any lingering msedge.exe so the kiosk page starts clean.
    run_and_log('taskkill /IM msedge.exe /F', 'Kill existing Edge');
    sleep $CFG{edge_wait};

    # 3. Launch Edge in kiosk mode, detached, no shell quoting issues.
    my @edge_args = (
        '--kiosk', $CFG{ma_page},
        '--edge-kiosk-type=fullscreen',
        '--no-first-run',
    );
    log_line("Launch Edge: \"$CFG{edge_exe}\" @edge_args");
    my $edge_rc = system(1, $CFG{edge_exe}, @edge_args);
    log_line("WARN: Edge launch returned $edge_rc") if $edge_rc != 0;

    # 4. Wait, then bring Edge above the taskbar / monitoring console.
    sleep $CFG{activate_wait};
    my $shell = Win32::OLE->new('WScript.Shell');
    if ($shell) {
        $shell->AppActivate($CFG{window_title});
        log_line("AppActivate('$CFG{window_title}') issued.");
    }
    else {
        log_line('ERROR: could not create WScript.Shell COM object.');
    }

    log_line('Maintenance launch completed.');
}

# -----------------------------------------------------------------------------
# Subcommand: trigger  (create the flag file manually -- testing / on-demand)
# -----------------------------------------------------------------------------
sub cmd_trigger {
    GetOptions('config=s' => \(my $cfg)) or die "Bad options for 'trigger'\n";
    load_config($cfg);

    my $flag = "$CFG{scripts_dir}/show_maintenance.flag";
    open my $fh, '>', $flag or die "Cannot create $flag: $!\n";
    close $fh;
    say "Trigger created: $flag";
}

# -----------------------------------------------------------------------------
# Subcommand: show-cfg
# -----------------------------------------------------------------------------
sub cmd_show_cfg {
    GetOptions('config=s' => \(my $cfg)) or die "Bad options for 'show-cfg'\n";
    load_config($cfg);
    for my $k (sort keys %CFG) {
        printf "%-15s = %s\n", $k, $CFG{$k};
    }
    say 'log_file (effective) = ' . effective_log_path();
    say 'flag_file (effective) = ' . "$CFG{scripts_dir}/show_maintenance.flag";
}

# -----------------------------------------------------------------------------
# Entry point
# -----------------------------------------------------------------------------
my $action = shift @ARGV;
unless (defined $action && $action =~ /^(watch|launch|trigger|show-cfg)$/) {
    die <<"EOF";
Usage: perl kioskMA.pl <watch|launch|trigger|show-cfg> [options]

  watch     Poll for the trigger file and run launch when seen.
            --interval=N   poll every N seconds (default: $CFG{poll_seconds})
            --once         check once and exit (useful in tests)
            --config=FILE  load a key=value config file

  launch    Kill the kiosk app and start Edge in kiosk mode.
            --config=FILE

  trigger   Create the trigger file (same as ShowMaintenanceNow.bat).
            --config=FILE

  show-cfg  Print the effective configuration and exit.
            --config=FILE
EOF
}

my %DISPATCH = (
    'watch'    => \&cmd_watch,
    'launch'   => \&cmd_launch,
    'trigger'  => \&cmd_trigger,
    'show-cfg' => \&cmd_show_cfg,
);
exit $DISPATCH{$action}->() // 0;
