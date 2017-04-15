#!/usr/bin/env perl
use 5.020;
use warnings;
use strict;

use blib;

use Lab::Zhinst;
use Devel::Peek;

say  Lab::Zhinst::ListImplementations();

{
    my $x = Lab::Zhinst->new('localhost', 8004);

    say "API Version: ", $x->GetConnectionAPILevel();
    say "nodes: ", $x->ListNodes("/", ZI_LIST_NODES_ABSOLUTE
                                 | ZI_LIST_NODES_RECURSIVE);
}

