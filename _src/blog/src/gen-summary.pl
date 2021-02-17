#!/usr/bin/perl -w

die unless open OUT, ">SUMMARY.md";

print OUT "# Summary\n";
print OUT "\n";

for $fn (sort <20*.md>) {
    die unless open IN, "<$fn";
    my $head = <IN>;
    chomp $head;
    $head =~ s/^#+ //;
    print OUT "[$head]($fn)\n";
}

die unless close OUT;
