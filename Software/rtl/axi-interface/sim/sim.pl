#!/usr/bin/perl

use warnings;
use v5.10;

$incdir = 
'-incdir ../env '.
'-incdir ../env/axi_lite '.
'-incdir ../env/axi_stream '.
'-incdir ../env/scoreboard '.
'-incdir ../env/environment '.
'-incdir ../env/sequence_lib '.
'-incdir ../env/up_sampling '.
'-incdir ../env/test_lib '.
'-incdir ../env/dut '.
'-incdir ../env/interface_lib '.
'-incdir ../env/testbench '.
'-incdir ../env/utils '.
'-incdir ../../bicubic ';

$verbo = "+UVM_VERBOSITY=UVM_LOW";
$top = "tb_bcci_ip";

# Multicore simulation support. 
# -mce_top and -top must be specified simultaneously
$mceoption = "-mce -mce_top $top";

$xcmd = 
"xrun -64bit -top $top "
."$mceoption "
."-sv -UVM -access rwc $incdir "
."-f macros -f filelist "
."$verbo ";

system "rm xcelium.d -r";
system $xcmd;