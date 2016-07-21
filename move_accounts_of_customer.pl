#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;

use Porta;
use Porta::Customer;
use Porta::Admin::WebSessionController;
use Porta::TaskQueue::Client;

use constant TASK => 'admin::close_customer_accounts';

my ( $ph, $i_user, $help, $user, $pass, $cust ) = ( undef, undef, undef, undef, undef, undef );

GetOptions(
    'h|help'   => \$help,
    'u|user=s' => \$user,
    'p|pass=s' => \$pass,
    'c|cust=i' => \$cust,
);

main();    # <--- main entry

# -------------- subroutines begin --------------

sub main {
    check_arguments();
    authenticate_and_load_ph();

    my $c      = Porta::Customer->new($ph);
    my $c_info = $c->get_simple($cust);

    if ( !$c_info ) {
        error( q{Customer with i_customer = %s does not exist}, $cust );
    }
    else {
        if ( $c_info->{i_env} != $ph->{i_env} ) {
            error(
                q{Customer with i_customer = %s (i_env = %s) belongs to different from your user's (i_env = %s) env},
                $cust, $c_info->{i_env}, $ph->{i_env}
            );
        }
    }

    my $task_args = {
        i_customer      => $c_info->{i_customer},
        not_user        => 0,
        i_reseller      => undef,
        i_user          => $ph->{i_user},
        customer_name   => $c_info->{name},
        i_customer_type => $c_info->{i_customer_type},
    };

    my $res = Porta::TaskQueue::Client->new($ph)->do_background_task( TASK, $task_args );

    if ($res) {
        info( q{Background task_queue task "%s" hs been successfully stored}, TASK );
    }
    else {
        error( q{Failed to store task "%s"}, TASK );
    }

    exit 0;
} ## end sub main

sub check_arguments {
    if ($help) {
        print_help();
        exit 0;
    }
    else {
        if ( !$user || !$pass || !$cust ) {
            error(q{Mandatory field is missing. See help...});
        }
    }
}

sub authenticate_and_load_ph {
    $ph = Porta->new();
    $ph->{Porta_Realm} = "admin";
    $ph->set_formats();
    $ph->set_sc( Porta::Admin::WebSessionController->new($ph) );
    $ph->get_sc()->load_realm( $ph->{Porta_Realm} );
    $i_user = $ph->get_sc()->authenticate( $user, $pass );

    if ( !$i_user ) {
        error( q{Authentication failed with user = "%s" and pass = "%s"}, $user, $pass );
    }
    else {
        info( q{Successfully authenticated with user = "%s" and pass = "%s"}, $user, $pass );
    }

    $ph->get_sc()->load_access_config();

    return undef;
}

sub info {
    my ( $msg, @args ) = @_;
    printf( "[info] " . $msg . "\n", @args );
}

sub error {
    my ( $msg, @args ) = @_;
    printf( "[error] " . $msg . "\n", @args );
    exit 2;
}

sub print_help {
    print << "HELP";
Script for all accounts termination by customer. (RT#390644)
Stores background gearman task "admin::close_customer_accounts".

Usage:
    $0 -u porta-support -p b0neynem -c 30

Options list:
    -h, --help          Display this help and exit
    -u, --user          PB admin user; MANDATORY
    -p, --pass          PB admin password; MANDATORY
    -c, --cust          ID of customer record (i_customer); MANDATORY
HELP
}

# -------------- subroutines end --------------
06:29:50 MR45.3 porta-one@dbs.synety.com:~
> cat /home/porta-admin/utils/terminate_accounts_of_customer.pl 
 portaconfig 1.50 1.44 1.84                 0*bash                 21 Thu  6:36 
    else {
        info( q{Successfully authenticated with user = "%s" and pass = "%s"}, $user, $pass );
    }

    $ph->get_sc()->load_access_config();

    return undef;
}

sub info {
    my ( $msg, @args ) = @_;
    printf( "[info] " . $msg . "\n", @args );
}

sub error {
    my ( $msg, @args ) = @_;
    printf( "[error] " . $msg . "\n", @args );
    exit 2;
}

sub print_help {
    print << "HELP";
Script for all accounts termination by customer. (RT#390644)
Stores background gearman task "admin::close_customer_accounts".

Usage:
    $0 -u porta-support -p b0neynem -c 30

Options list:
    -h, --help          Display this help and exit
    -u, --user          PB admin user; MANDATORY
    -p, --pass          PB admin password; MANDATORY
    -c, --cust          ID of customer record (i_customer); MANDATORY
HELP
}

# -------------- subroutines end --------------
