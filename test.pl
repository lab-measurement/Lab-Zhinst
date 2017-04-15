#!/usr/bin/env perl
use 5.020;
use warnings;
use strict;

use blib;

use Lab::Zhinst;
use Devel::Peek;

say  Lab::Zhinst::ListImplementations();

{
    my $conn = Lab::Zhinst->new('localhost', 8004);
    say "API Version: ", $conn->GetConnectionAPILevel();
    say "nodes:\n",
    $conn->ListNodes("/", ZI_LIST_NODES_ABSOLUTE | ZI_LIST_NODES_RECURSIVE);

    say "PORT: ", $conn->GetValueD("/ZI/CONFIG/PORT");
    say "PORT: ", $conn->GetValueI("/ZI/CONFIG/PORT");
}

