#!/usr/bin/env perl
# SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
# Copyright (c) 2026 Ahmad Ali Parr. All rights reserved.
# Authored by Ahmad Ali Parr.
# Licensed under the SNAPKITTY OPAQUE SOURCE LICENSE v1.0. See LICENSE.
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/blocks";
use NRSE::Engine;
use Mojolicious::Lite -signatures;

my $engine = NRSE::Engine->new;

post '/locate' => sub ($c) {
    my $q = $c->req->json // {};
    return $c->render(status => 400, json => { error => 'source and query required' })
        unless defined $q->{source} && defined $q->{query};
    my $source = $q->{source};
    my $span = $engine->locate($source, $q->{query});
    $c->render(json => { span => $span, found => $span->[0] >= 0 });
};

post '/extract' => sub ($c) {
    my $q = $c->req->json // {};
    return $c->render(status => 400, json => { error => 'source and span required' })
        unless defined $q->{source} && ref($q->{span}) eq 'ARRAY';
    my $text = $engine->extract($q->{source}, $q->{span});
    return $c->render(status => 422, json => { span => [-1, -1] }) unless defined $text;
    $c->render(json => { span => $q->{span}, text => $text });
};

get '/health' => sub ($c) {
    $c->render(json => { service => 'NRSE', status => 'ok', version => $NRSE::Engine::VERSION });
};

app->start;
