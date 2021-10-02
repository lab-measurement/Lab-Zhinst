#!/usr/bin/env perl
use warnings;
use strict;
use blib;
use Lab::Zhinst;
use Devel::Peek;
my ($rv, $conn) = Lab::Zhinst->Init();
Dump($rv);
Dump($conn);
    
