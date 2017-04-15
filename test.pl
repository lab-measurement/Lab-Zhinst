#!/usr/bin/env perl
use 5.020;
use warnings;
use strict;

use blib;

use Lab::Zhinst;
use Devel::Peek;

say  Lab::Zhinst::ListImplementations();

my $conn = Lab::Zhinst->new('localhost', 8004);
say "API Version: ", $conn->GetConnectionAPILevel();
my $nodes = $conn->ListNodes("/", ZI_LIST_NODES_ABSOLUTE | ZI_LIST_NODES_RECURSIVE);
my @nodes = split '\n', $nodes;
say for @nodes;

my $i;

my $x = $conn->SyncSetValueB("/ZI/CONFIG/PORT", "101");

say $x;

