#!/usr/bin/perl -w

# Version: 2020-06-27
#
# This code assumes that it owns all the `[...]: ...` definitions at
# the end of each ".md" file.  It deletes them and rewrites them
# according to the links known to this script.  (Any other links must
# be made inline to avoid being deleted.)

my $CRATES = "https://crates.io/crates";
my $DOCS = "https://docs.rs/stakker/*/stakker";
my $QCELL = "https://docs.rs/qcell/*/qcell";
my $STD = "https://doc.rust-lang.org/stable/std";

my $links = <<"EOF";
[**qcell**]: $CRATES/qcell
[**stakker_mio**]: $CRATES/stakker_mio
[**stakker_log**]: $CRATES/stakker_log
[**stakker_macros**]: $CRATES/stakker_macros
[**stakker_tui**]: $CRATES/stakker_tui
[**unsized_enum**]: $CRATES/unsized_enum
[**regex**]: $CRATES/regex
[**tungstenite**]: $CRATES/tungstenite
[`fail`]: $DOCS/struct.Cx.html#method.fail
[`fail_str`]: $DOCS/struct.Cx.html#method.fail_str
[`kill`]: $DOCS/struct.Actor.html#method.kill
[`Cx`]: $DOCS/struct.Cx.html
[`Fwd`]: $DOCS/struct.Fwd.html
[`Ret`]: $DOCS/struct.Ret.html
[`Actor`]: $DOCS/struct.Actor.html
[`ActorOwn`]: $DOCS/struct.ActorOwn.html
[`ActorOwnAnon`]: $DOCS/struct.ActorOwnAnon.html
[`ActorOwnSlab`]: $DOCS/struct.ActorOwnSlab.html
[`Core`]: $DOCS/struct.Core.html
[`Deferrer`]: $DOCS/struct.Deferrer.html
[`Share`]: $DOCS/struct.Share.html
[`Stakker`]: $DOCS/struct.Stakker.html
[`Waker`]: $DOCS/struct.Waker.html
[`PipedThread`]:  $DOCS/struct.PipedThread.html
[`StopCause`]: $DOCS/enum.StopCause.html
[`actor_of_trait!`]: $DOCS/macro.actor_of_trait.html
[`call!`]: $DOCS/macro.call.html
[`fwd_to!`]: $DOCS/macro.fwd_to.html
[`ret_some_to!`]: $DOCS/macro.ret_some_to.html
[`ret_tmo_to!`]: $DOCS/macro.ret_tmo_to.html
[`ret_to!`]: $DOCS/macro.ret_to.html
[`ret_nop!`]: $DOCS/macro.ret_nop.html
[`after!`]: $DOCS/macro.after.html
[`at!`]: $DOCS/macro.at.html
[`fwd!`]: $DOCS/macro.fwd.html
[`idle!`]: $DOCS/macro.idle.html
[`lazy!`]: $DOCS/macro.lazy.html
[`query!`]: $DOCS/macro.query.html
[`ret!`]: $DOCS/macro.ret.html
[`TLCell`]: $QCELL/struct.TLCell.html
[`Error`]: $STD/error/trait.Error.html
[`BTreeMap`]: $STD/collections/struct.BTreeMap.html
[`BinaryHeap`]: $STD/collections/struct.BinaryHeap.html
[`FnOnce`]: $STD/ops/trait.FnOnce.html
[`Rc`]: $STD/rc/struct.Rc.html
[`RefCell`]: $STD/cell/struct.RefCell.html
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

for my $fnam (<[a-z]*.md>) {
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
