#!/usr/bin/perl -w

my $fnam = shift;
die "Usage: extract-contents.pl <md-filename>\n" unless defined $fnam;

$fnam =~ s|^.*/||;
$fnam =~ s|\.md$||;
$fnam = "../../../blog/$fnam.html";

die unless open IN, "<$fnam";
while (<IN>) {
    chomp;
    next unless m|<a class="header" href="(.*?)" id=".*?">(.*?)</a>|;

    print "- [$2]($1)\n";
}
die unless close IN;
