#!/usr/bin/env perl
use 5.020;
use warnings;
use strict;

use blib;

use Lab::Zhinst;
use Devel::Peek;

# say  Lab::Zhinst::ListImplementations();

# Lab::Zhinst::SetDebugLevel(0);
# Lab::Zhinst::WriteDebugLog(0, "lala lala");
# Lab::Zhinst::WriteDebugLog(5, "wo bin ich?");

my $conn = Lab::Zhinst->new('localhost', 8004);
say "API Version: ", $conn->GetConnectionAPILevel();
say "Nodes: \n",  $conn->ListNodes("/", ZI_LIST_NODES_ABSOLUTE
                                   | ZI_LIST_NODES_RECURSIVE);

$conn->DiscoveryFind("localhost");

# my $i = 0;
# while (1) {
#     say $conn->GetValueB("/zi/about/copyright");
#     say ++$i;
# };
