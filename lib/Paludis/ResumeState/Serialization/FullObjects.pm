
use strict;
use warnings;

package Paludis::ResumeState::Serialization::FullObjects;

use Paludis::ResumeState::Serialization::Grammar;
use Class::Load 0.06;
use Scalar::Util qw( blessed );
use Params::Util qw( _HASHLIKE _ARRAYLIKE );

sub serialize {
    my ( $self, $data ) = @_ ;

}
sub _vivify_array {
  my $object = shift;
  my @out;
  for ( @{$object} ) {
    push @out, _vivify($_);
  }
  return \@out;
}

sub _vivify_object {
  my $object = shift;
  my $prefix = 'Paludis::ResumeState::Serialization::Class::';
  my $class  = $prefix . $object->{_classname};
  Class::Load::load_class($class);
  delete $object->{_classname};

  my %newobject = ();
  for ( keys %{$object} ) {
    $newobject{$_} = _vivify( $object->{$_} );
  }

  return $class->new(%newobject);
}

sub _vivify_pure_array {
  return [ map { _vivify($_) } @{ $_[0] } ];
}

sub _vivify_pure_hash {
  return { map { _vivify($_) } %{ $_[0] } };
}

sub _vivify {
  my $thing = shift;
  if ( not ref $thing ) {
    return $thing;
  }
  if ( not blessed $thing ) {
    if ( _ARRAYLIKE( $thing ) ) {
      return _vivify_pure_array($thing);
    }
    if ( _HASHLIKE( $thing ) ) {
      return _vivify_pure_hash($thing);
    }
    return $thing;
  }
  if ( $thing->isa('Paludis::ResumeState::Serialization::Grammar::FakeClass') ) {
    return _vivify_object($thing);
  }
  if ( $thing->isa('Paludis::ResumeState::Serialization::Grammar::FakeArray') ) {
    return _vivify_array($thing);
  }
  return $thing;
}

sub deserialize {
  my ( $self, $content ) = @_;

  my @classes;
  my @arrays;

  local $Paludis::ResumeState::Serialization::Grammar::CLASS_CALLBACK = sub {
    my ( $classname, $parameters , $paramter_list, $extra ) = @_;
    $parameters->{_classname} = $classname;
    for ( keys %$extra ){
        $parameters->{ '_' . $_ } = $extra->{ $_ };
    }
    my $object = bless $parameters, 'Paludis::ResumeState::Serialization::Grammar::FakeClass';
    push @classes, $object;
    return $object;
  };

  local $Paludis::ResumeState::Serialization::Grammar::LIST_CALLBACK = sub {
    my ($parameters) = @_;
    my $object = bless $parameters, 'Paludis::ResumeState::Serialization::Grammar::FakeArray';
    push @arrays, $object;
    return $object;
  };

  my $result;
  local %/;
  if ( not( $content =~ Paludis::ResumeState::Serialization::Grammar::grammar() ) ) {
    return;
  }
  $result = \%/;

  # Vivification has to be done after regex, because anything that does regex during construction
  # ( Such as Moose ) can be rooted by Regexp::Grammars.
  return _vivify($result);
}

1;
