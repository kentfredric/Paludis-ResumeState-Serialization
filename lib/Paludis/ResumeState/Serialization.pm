use strict;
use warnings;

package Paludis::ResumeState::Serialization;

# ABSTRACT: Work with resume-files generated by Paludis

use Paludis::ResumeState::Serialization::Grammar;
use Class::Load 0.06 qw();
use Params::Util qw( _HASHLIKE _STRING);
use Carp qw();

no autovivification;

sub _get_content {
  my ($config) = shift;
  return $config->{content} if _STRING( $config->{content} );
  Carp::croak('{ content => } must be a scalar ')
    if defined $config->{content};

  return;
}

=head1 SYNOPSIS



=cut

sub _serializer {
  my ($name) = shift;
  my $formats = {
    'basic' => __PACKAGE__ . '::Basic',

    #    'simple_objects' => __PACKAGE__ . '::MockObjects',
    #    'full_objects'   => __PACKAGE__ . '::FullObjects',
  };

  Carp::croak( "Format $name not in " . join q{,}, keys %{$formats} ) unless exists $formats->{$name};
  Class::Load::load_class( $formats->{$name} );
  return $formats->{$name};
}

sub deserialize {
  my ( $self, $config ) = @_;

  Carp::croak( 'deserialize needs a configuration hash passed to it.' . qq{\n} . 'please see perldoc for details' )
    unless _HASHLIKE($config);

  my $content = _get_content($config);

  Carp::croak('Can\'t deserialize, no content provided, provide deserialize( hash ) with content => ')
    unless defined $content;

  Carp::croak(q[No {format=> } specified, pick 'basic'])
    unless defined $config->{format};

  return _serializer( $config->{format} )->deserialize( $config->{content} );
}

sub serialize {
  my ( $self, $config ) = @_;
  return _serializer( $config->{format} )->serialize( $config->{data} );
}

1;
