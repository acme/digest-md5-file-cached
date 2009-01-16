#!perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Digest::MD5::File::Cached',
    VERSION_FROM => 'lib/Digest/MD5/File/Cached.pm',
    ABSTRACT     => 'Caching MD5 sums for files',
    AUTHOR       => 'Leon Brocard <acme@astray.com>',
    LICENSE      => 'perl',
    PREREQ_PM    => {
        'BerkeleyDB::Manager'       => '0',
        'Digest::MD5::File'         => '0',
        'Moose'                     => '0',
        'MooseX::StrictConstructor' => '0',
        'Path::Class'               => '0',
    }
);

