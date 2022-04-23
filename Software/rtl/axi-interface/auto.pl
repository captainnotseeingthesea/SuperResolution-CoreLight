#!/usr/bin/perl

use warnings;
use v5.10;
use File::Basename;
use File::Spec;
use File::Copy;


$tmp = "autotmp";
if(-d $tmp) {
    system "rm $tmp -r";
}
mkdir $tmp, 0755 or die "cannot mkdir $tmp:$!";


@srcfiles = glob 
"src/*.v ".
"env/dut/*.svh ".
"env/testbench/*.sv ".
"../bicubic/bicubic_top.v ".
"../IP/bcci/*.v"
;


foreach $src (@srcfiles) {
    $dst = File::Spec->catfile($tmp, basename $src);
    substr($dst, -1, 1) = "" if substr($dst, -1, 1) eq "h";
    copy $src, $dst or die "cannot copy $src:$!";
}

@autofiles = glob "$tmp/*.v $tmp/*.sv";
system "emacs --batch  $_  -f verilog-batch-auto" foreach @autofiles;

foreach $src (@srcfiles) {
    $dst = File::Spec->catfile($tmp, basename $src);
    substr($dst, -1, 1) = "" if substr($dst, -1, 1) eq "h";

    next if basename($src) eq "bicubic_top.v";

    next if basename($src) eq "bcci_ip.v";

    copy $dst, $src or die "cannot copy $dst:$!";
}

system "rm $tmp -r";