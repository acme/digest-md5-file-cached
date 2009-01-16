#!perl
use strict;
use warnings;
use Test::More tests => 10;
use Digest::MD5::File::Cached;

my $cached = Digest::MD5::File::Cached->new;
$cached->clear_cache;
my $md5_hex1 = $cached->file_md5_hex('Makefile.PL');
my $md5_hex2 = $cached->file_md5_hex('Makefile.PL');
