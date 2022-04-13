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

$axidir = "../../axi-interface";
$bicubdir = "../../bicubic";
$bcciip = "bcci_ip.v";

@srcfiles = glob "$axidir/src/*.v $bicubdir/*.v $bcciip";
foreach $src (@srcfiles) {
    $dst = File::Spec->catfile($tmp, basename $src);
    copy $src, $dst or die "cannot copy $src:$!";
}

$autofile = "$tmp/$bcciip";

system "emacs --batch  $autofile  -f verilog-batch-auto";

copy $autofile, $bcciip or die "cannot copy $autofile:$!";

system "rm $tmp -r";