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

@srcfiles = glob "src/*.v src/*.sv env/*.v env/*.sv env/uvm/*.v env/uvm/*.sv";
foreach $src (@srcfiles) {
    $dst = File::Spec->catfile($tmp, basename $src);
    copy $src, $dst or die "cannot copy $src:$!";
}

@autofiles = glob "$tmp/*.v $tmp/*.sv";
system "emacs --batch  $_  -f verilog-batch-auto" foreach @autofiles;

foreach $src (@srcfiles) {
    $dst = File::Spec->catfile($tmp, basename $src);
    copy $dst, $src or die "cannot copy $dst:$!";
}

system "rm $tmp -r";