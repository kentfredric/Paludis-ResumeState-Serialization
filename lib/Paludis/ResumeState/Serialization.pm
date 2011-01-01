use strict;
use warnings;

package Paludis::ResumeState::Serialization;

use Paludis::ResumeState::Serialization::Grammar;
use Class::Load 0.06 qw();
use Params::Util qw( _HASHLIKE _STRING _SCALAR _HANDLE);
use Carp qw();

no autovivification;

sub _get_content_fh {
  my ($config) = shift;
  Carp::croak("{ filehandle => } must be a HANDLE ")
    unless _HANDLE( $config->{filehandle} );
  local $/ = undef;
  my $fh = $config->{filehandle};
  return scalar <$fh>;
}

sub _get_content_filename {
  my ($config) = shift;
  Carp::croak("{ filename => } must be a STRING")
    unless _STRING( $config->{filename} );
  my $fn = $config->{filename};
  my $fh;
  Carp::croak("Can't open $fn for read, $!")
    unless open $fh, '<', $fn;
  local $/ = undef;
  return scalar <$fh>;
}

sub _get_content {
  my ($config) = shift;
  return $config->{content} if _STRING( $config->{content} );
  return ${ $config->{content} } if _SCALAR( $config->{content} );
  Carp::croak("{ content => } must be a scalar or a scalar ref")
    if defined $config->{content};

  return;
}

sub _serializer {
  my ($name) = shift;
  my $formats = {
    'basic'          => __PACKAGE__ . '::Basic',
#    'simple_objects' => __PACKAGE__ . '::MockObjects',
#    'full_objects'   => __PACKAGE__ . '::FullObjects',
  };
  Carp::croak("Format $name not in basic,simple_objects,full_objects") unless exists $formats->{$name};
  Class::Load::load_class( $formats->{$name} );
  return $formats->{$name};
}

sub deserialize {
  my ( $self, $config ) = @_;

  Carp::croak( "deserialize needs a configuration hash passed to it.\n" . "please see perldoc for details" )
    unless _HASHLIKE($config);

  my $content = _get_content($config);

  $content = _get_content_fh($config) if ( not defined $content and defined $config->{filehandle} );

  $content = _get_content_file($config) if ( not defined $content and defined $config->{filename} );

  Carp::croak(
    "Can't deserialize, no content provided, provide deserialize(\$hash) with content => , filehandle => , or filename =>")
    unless defined $content;

  Carp::croak("No {format=> } specified, pick either 'basic', 'simple_objects', or 'full_objects'")
    unless defined $config->{format};

  return _serializer( $config->{format} )->deserialize( $config->{content} );
}

sub serialize {
  my ( $self, $config ) = @_;
  return _serializer( $config->{format} )->serialize( $config->{data} );
}

1;
