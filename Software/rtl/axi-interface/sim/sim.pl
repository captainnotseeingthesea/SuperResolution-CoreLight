#!/usr/bin/perl

use warnings;
use v5.10;

$incdir = '-incdir ../env -incdir ../env/uvm -incdir ../src';
# $verbo = "+UVM_VERBOSITY=UVM_HIGH";

$xcmd = "xrun -sv -UVM -access rwc -f macros -f filelist -top tb_ac_crf $incdir $verbo";

system $xcmd;