#!/usr/bin/perl -w

die unless open OUT, ">SUMMARY.md";

print OUT "# Summary\n";
print OUT "\n";
print OUT "[Intro](intro.md)\n";

for $fn (reverse sort <20*.md>) {
    die unless open IN, "<$fn";
    my $head = <IN>;
    chomp $head;
    $head =~ s/^#+ //;
    print OUT "[$head]($fn)\n";
}

die unless close OUT;
