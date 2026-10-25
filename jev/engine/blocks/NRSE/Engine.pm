package NRSE::Engine;
use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use Encode qw(decode FB_CROAK);

our $VERSION = '0.1.0';
my $NOT_FOUND = [-1, -1];

sub new { bless { max_query_bytes => 1_000_000 }, shift }

sub locate {
    my ($self, $source, $query) = @_;
    return [@$NOT_FOUND] unless defined $source && defined $query;
    my $needle = _bytes($query);
    return [@$NOT_FOUND] unless length $needle;
    return [@$NOT_FOUND] if length($needle) > $self->{max_query_bytes};
    my $at = index($source, $needle);
    return [@$NOT_FOUND] if $at < 0;
    return [$at, $at + length($needle)];
}

sub locate_all {
    my ($self, $source, $query, $limit) = @_;
    $limit = 1000 unless defined $limit;
    return [] if $limit < 1 || $limit > 100_000;
    my $needle = _bytes($query);
    return [] unless length $needle;
    my (@hits, $offset);
    $offset = 0;
    while (@hits < $limit) {
        my $at = index($source, $needle, $offset);
        last if $at < 0;
        push @hits, [$at, $at + length($needle)];
        $offset = $at + (length($needle) || 1);
    }
    return \@hits;
}

sub locate_normalized {
    my ($self, $source, $query) = @_;
    return [@$NOT_FOUND] unless defined $source && defined $query;
    my ($normalized, $map) = _normalize_with_map($source);
    my ($qnorm) = _normalize_with_map(_bytes($query));
    return [@$NOT_FOUND] unless length $qnorm;
    my $at = index($normalized, $qnorm);
    return [@$NOT_FOUND] if $at < 0;
    my $last = $at + length($qnorm) - 1;
    return [$map->[$at], $map->[$last] + 1];
}

sub extract {
    my ($self, $source, $span) = @_;
    return undef unless ref($span) eq 'ARRAY' && @$span == 2;
    my ($start, $end) = @$span;
    return undef unless _integer($start) && _integer($end);
    return undef if $start < 0 || $end < $start || $end > length($source);
    return substr($source, $start, $end - $start);
}

sub validate_span {
    my ($self, $source, $span) = @_;
    return 0 unless ref($span) eq 'ARRAY' && @$span == 2;
    my ($s, $e) = @$span;
    return 0 unless _integer($s) && _integer($e);
    return 0 if $s < 0 || $e < $s || $e > length($source);
    return 1;
}

sub format_span {
    my ($self, $span) = @_;
    return '[-1, -1]' unless ref($span) eq 'ARRAY' && @$span == 2;
    return '[' . int($span->[0]) . ', ' . int($span->[1]) . ']';
}

sub audit {
    my ($self, $source) = @_;
    my $lines = () = $source =~ /\n/g;
    $lines++ if length($source) && substr($source, -1, 1) ne "\n";
    return { bytes => length($source), lines => $lines, sha256 => sha256_hex($source) };
}

sub bounded_context {
    my ($self, $source, $span, $radius) = @_;
    $radius = 80 unless defined $radius;
    return undef unless _integer($radius) && $radius >= 0 && $radius <= 100_000;
    return undef unless $self->validate_span($source, $span);
    my $s = $span->[0] - $radius;
    $s = 0 if $s < 0;
    my $e = $span->[1] + $radius;
    $e = length($source) if $e > length($source);
    return { span => [$s, $e], text => substr($source, $s, $e - $s) };
}

sub _bytes {
    my ($s) = @_;
    return '' unless defined $s;
    return utf8::is_utf8($s) ? Encode::encode('UTF-8', $s) : $s;
}

sub _normalize_with_map {
    my ($input) = @_;
    my $bytes = _bytes($input);
    my (@out, @map);
    my $pending_space = 0;
    for (my $i = 0; $i < length($bytes); $i++) {
        my $c = substr($bytes, $i, 1);
        if ($c =~ /[ \t\r\n]/) {
            $pending_space = 1 if @out;
            next;
        }
        if ($pending_space) {
            push @out, ' ';
            push @map, $i - 1;
            $pending_space = 0;
        }
        push @out, lc($c);
        push @map, $i;
    }
    return (join('', @out), \@map);
}

sub _integer { defined $_[0] && $_[0] =~ /\A-?\d+\z/ }

1;
