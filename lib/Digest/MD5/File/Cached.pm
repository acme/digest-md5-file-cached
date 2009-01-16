package Digest::MD5::File::Cached;
use Moose;
use MooseX::StrictConstructor;
use BerkeleyDB::Manager;
use Cwd;
use Digest::MD5::File;
use File::stat;
use Path::Class;

our $VERSION = '0.34';

has 'berkeleydb_manager' =>
    ( is => 'rw', isa => 'BerkeleyDB::Manager', required => 0 );
has 'berkeleydb_db' =>
    ( is => 'rw', isa => 'BerkeleyDB::Hash', required => 0 );

__PACKAGE__->meta->make_immutable;

sub BUILD {
    my $self    = shift;
    my $manager = BerkeleyDB::Manager->new(
        home     => Path::Class::Dir->new(cwd),
        db_class => 'BerkeleyDB::Hash',
        create   => 1,
    );
    $self->berkeleydb_manager($manager);
    my $db = $manager->open_db( file => 'md5_cache' );
    $self->berkeleydb_db($db);
}

sub clear_cache {
    my $self    = shift;
    my $manager = $self->berkeleydb_manager;
    my $db      = $self->berkeleydb_db;
    my $stream  = $manager->cursor_stream( db => $db );
    while ( my $block = $stream->next ) {
        foreach my $item (@$block) {
            my ( $key, $value ) = @$item;
            $manager->txn_do(
                sub {
                    $db->db_del($key);
                }
            );
        }
    }
}

sub file_md5_hex {
    my ( $self, $filename ) = @_;
    my $file    = file($filename);
    my $manager = $self->berkeleydb_manager;
    my $db      = $self->berkeleydb_db;

    my $stat     = $file->stat;
    my $ctime    = $stat->ctime;
    my $mtime    = $stat->mtime;
    my $size     = $stat->size;
    my $inodenum = $stat->ino;
    my $cachekey = "$filename:$ctime,$mtime,$size,$inodenum";

    $db->db_get( $cachekey, my $md5_hex );
    if ($md5_hex) {

        warn "hit $cachekey $md5_hex";
    } else {
        $md5_hex = Digest::MD5::File::file_md5_hex($filename)
            || die "Failed to find MD5 for $filename";
        $manager->txn_do(
            sub {
                $db->db_put( $cachekey, $md5_hex );
            }
        );

        warn "miss $cachekey $md5_hex";
    }
    return $md5_hex;
}

1;
