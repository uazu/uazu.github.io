#!/usr/bin/perl -w

# Version: 2021-04-03
#
# This code assumes that it owns all the `[...]: ...` definitions at
# the end of each ".md" file.  It deletes them and rewrites them
# according to the links known to this script.  (Any other links must
# be made inline to avoid being deleted.)

my $CRATES = "https://crates.io/crates";
my $STAKKER = "https://docs.rs/stakker/*/stakker";
my $QCELL = "https://docs.rs/qcell/*/qcell";
my $FUTURES_CORE = "https://docs.rs/futures-core/*/futures-core";
my $STD = "https://doc.rust-lang.org/stable/std";

my $links = <<"EOF";
[**Stakker**]: $CRATES/stakker
[**qcell**]: $CRATES/qcell
[**stakker_mio**]: $CRATES/stakker_mio
[**stakker_log**]: $CRATES/stakker_log
[**stakker_macros**]: $CRATES/stakker_macros
[**stakker_tui**]: $CRATES/stakker_tui
[**unsized_enum**]: $CRATES/unsized_enum
[**stakker_async_await**]: $CRATES/stakker_async_await
[**futures**]: $CRATES/futures
[**futures-lite**]: $CRATES/futures-lite
[**future-core**]: $CRATES/futures-core
[**tokio**]: $CRATES/tokio
[**async_executors**]: $CRATES/async_executors
[**agnostik**]: $CRATES/agnostik
[**qcell**]: $CRATES/qcell
[`RefCell::borrow_mut`]: $STD/cell/struct.RefCell.html#method.borrow_mut
[`Future`]: $STD/future/trait.Future.html
[`std::task::Context`]: $STD/task/struct.Context.html
[`Context`]: $STD/task/struct.Context.html
[`Waker`]: $STD/task/struct.Waker.html
[`Send`]: $STD/marker/trait.Send.html
[`Stream`]: $FUTURES_CORE
[`Fwd`]: $STAKKER/struct.Fwd.html
[`Ret`]: $STAKKER/struct.Ret.html
[`Share`]: $STAKKER/struct.Share.html
[`LCell`]: $QCELL/struct.LCell.html
[`QCell`]: $QCELL/struct.QCell.html
[`TCell`]: $QCELL/struct.TCell.html
[`TLCell`]: $QCELL/struct.TLCell.html
EOF

    ;
my %map = ();
for (split(/\s*\n/, $links)) {
    die "Bad line: $_" unless /^(\[.*?\]):/;
    $map{$1} = $_;
}

sub readfile {
    my $fn = shift;
    die "Can't open file: $fn" unless open READFILE, "<$fn";
    local $/ = undef;
    my $data = <READFILE>;
    die unless close READFILE;
    return $data;
}

my %unknown = ();
my @curr = ();

sub process_file {
    # Drop existing link-defs, and any trailing blank lines
    while (@curr > 0 && $curr[@curr-1] =~ m|^\[.*\]:|) {
        pop @curr;
    }
    while (@curr > 0 && $curr[@curr-1] =~ m|^\s*$|) {
        pop @curr;
    }

    # Make a list of [...] links
    my %links = ();
    my $data = join('', @curr);
    $data =~ s/```.*?```//sg;
    while ($data =~ /(\[[`*][^\]]*[`*]\])[^(]/g) {
        $links{$1} = 1;
    }
    my @linkdefs = ();

    # Generate defs for them
    for my $link (sort keys %links) {
        my $def = $map{$link};
        if (defined $def) {
            push @linkdefs, $def;
        } else {
            $unknown{$link}++;
        }
    }

    # Append
    if (@linkdefs) {
        push @curr, "";
        push @curr, $_ for (@linkdefs);
    }

    print OUT join("\n", @curr, '');
}

for my $fnam (<[a-z0-9]*.md>) {
    my $ofnam = "$fnam-NEW";

    @curr = split(/\n/, readfile($fnam));
    die "Can't create file: $ofnam" unless open OUT, ">$ofnam";
    process_file();
    die "Failed writing file: $ofnam" unless close OUT;

    my $f1 = readfile($fnam);
    my $f2 = readfile($ofnam);
    if ($f1 ne $f2) {
        if (rename $ofnam, $fnam) {
            print "Updated $fnam\n";
        } else {
            print "Failed to rename file $ofnam to $fnam\n";
        }
    } else {
        unlink $ofnam;
    }
}

for (sort keys %unknown) {
    print "WARNING: Link not known: $_\n";
}
