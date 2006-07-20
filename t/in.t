# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl CapWiz-Object-Recipient-Legislator.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

package Class::Inflate::Test;

use Class::Inflate (
    person => {                       # name of table
        key => ['id'],                # primary key of table
	methods => {                  # object accessor => database field
	    id         => 'id',
	    first_name => 'first',
	    last_name  => 'last',
	},
    },
    staff => {
        key => ['org_id', 'dept_id', 'id'],
	join => {
	    person => {              # table to join against
	        'id' => 'id',        # person field => staff field
	    }
	},
	methods => {
	    title => 'title',
	},
    },
    organization => {
        key => ['org_id'],
	join => {
	    staff => {
	        org_id => 'org_id',
	    },
	},
	methods => {
	    org_name => 'org_name',
	},
    },
    department => {
        key => ['org_id', 'dept_id', 'id'],
	join => {
	    staff => {
	        org_id  => 'org_id',
		dept_id => 'dept_id',
	    },
	},
	methods => {
	    dept_name => 'dept_name',
	},
    },
);

sub new {
    my $class = shift;
    bless {}, $class;
}

#--- accessors ---#

sub id {
    my $self = shift;
    @_ ? $self->{id} = shift : $self->{id};
}

sub first_name {
    my $self = shift;
    @_ ? $self->{first_name} = shift : $self->{first_name};
}

sub last_name {
    my $self = shift;
    @_ ? $self->{last_name} = shift : $self->{last_name};
}

sub title {
    my $self = shift;
    @_ ? $self->{title} = shift : $self->{title};
}

sub org_name {
    my $self = shift;
    @_ ? $self->{org_name} = shift : $self->{org_name};
}

sub dept_name {
    my $self = shift;
    @_ ? $self->{dept_name} = shift : $self->{dept_name};
}

package main;

use Test::Debugger;
use Devel::Messenger qw(note);

my $note = note { 'output' => 'debug.txt', 'level' => 7 };
#my $explain = note { 'output' => 'print', 'level' => 1 };
no warnings 'redefine';
local *note = $note;
local *Test::Debugger::note = $note;
local *Class::Inflate::note = $note;
use warnings;

my $t = Test::Debugger->new(
    'tests'    => 3,
    'start'    => 1,
    'log_file' => 'test.log',
);
$t->param_order('ok' => [qw(self expected actual message error)]);

#########################

# Insert your test code below.

use Data::Dumper;
use DBI;
use Module::Build;
my $build = Module::Build->current;
my $dsn = $build->notes('dsn');
my $dbh = DBI->connect($dsn, '', '');

my @objects = Class::Inflate::Test->inflate($dbh, { id => [10, 11] });

use Data::Dumper;
my $c = 0;
foreach my $object (@objects) {
    note "object " . ++$c . ":\n";
    note Dumper($object) . "\n";
}

$t->ok(2, scalar(@objects), 'people matching id 10|11');

@objects = Class::Inflate::Test->inflate($dbh, { id => [10] });
$t->ok(1, scalar(@objects), 'people matching id 10');

@objects = Class::Inflate::Test->inflate($dbh, { id => [] });
$t->ok(0, scalar(@objects), 'people matching id ""');

