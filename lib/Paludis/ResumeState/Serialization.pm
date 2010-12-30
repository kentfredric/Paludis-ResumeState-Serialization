use strict;
use warnings;

package Paludis::ResumeState::Serialization;

use Moose;
use Paludis::ResumeState::Serialization::Grammar;
use Class::Load 0.06;
use Scalar::Util qw( blessed );

sub deserialize {
  my ($self, $config) = @_;

tryfilehandle: {
    if ( not defined $config->{filehandle} and defined $config->{filename} ) {
      if ( not defined $config->{decompress} ) {
        open $config->{filehandle}, '<', $config->{filename} or die "Cant open $config->{filename}, $! ";
        last tryfilehandle;
      }
      die "Unsupported condition: filehandle = undef, filename = defined ,"
        . " decompress = defined ( decompress not implemented yet, its easy to do it yourself )";
    }
  }
tryfillcontent: {
    if ( not defined $config->{content} and defined $config->{filehandle} ) {
      local $/ = undef;
      my $fh = $config->{filehandle};
      $config->{content} = < $fh >;
      last tryfillcontent;
    }
    if ( defined $config->{content} and ref $config->{content} ) {
      my $configref = $config->{content};
      if ( ref $configref eq 'SCALAR' ) {
        $config->{content} = $$configref;
        last tryfillcontent;
      }
      die "Unsupported 'content' type" . ref $config->{content};
    }
  }
  if ( not defined $config->{content} ) {
    die "Can't deserialize, no content provided, provide deserialize(\$hash) with content => , filehandle => , or filename =>";
  }
  if ( not defined $config->{format} ) {
    die "No {format=> } specified, pick either 'basic', 'simple_objects', or 'full_objects'";
  }
  my $formats = {
    'basic'          => '_deserialize_basic',
    'simple_objects' => '_deserialize_mock_objects',
    'full_objects'   => '_deserialize_full_objects',
  };
  if ( not exists $formats->{ $config->{format} } ) {
    die "Format $config->{format} not in basic,simple_objects,full_objects";
  }
  my $method = $self->can( $formats->{ $config->{format} } );
  return $self->$method( $config->{content} );
}

sub _deserialize_basic {
  my ( $self, $content ) = @_;

  local $Paludis::ResumeState::Serialization::Grammar::CLASS_CALLBACK = sub {
    my ( $classname, $parameters ) = @_;
    return { type => 'class', classname => $classname, parameters => $parameters };
  };

  local $Paludis::ResumeState::Serialization::Grammar::ARRAY_CALLBACK = sub {
    my ($parameters) = @_;
    return { type => 'array', parameters => $parameters, count => scalar @{$parameters} };
  };
  local %/;
  if ( $content =~ Paludis::ResumeState::Serialization::Grammar::grammar() ) {
    my $result = \%/;
    return $result;
  }

  return;

}

sub _deserialize_mock_objects {
  my ( $self, $content ) = @_;

  local $Paludis::ResumeState::Serialization::Grammar::CLASS_CALLBACK = sub {
    my ( $classname, $parameters ) = @_;
    $parameters->{_classname} = $classname;
    return bless $parameters, 'Paludis::ResumeState::Serialization::Grammar::FakeClass';
  };

  local $Paludis::ResumeState::Serialization::Grammar::ARRAY_CALLBACK = sub {
    my ($parameters) = @_;
    return bless $parameters, 'Paludis::ResumeState::Serialization::Grammar::FakeArray';
  };
  local %/;
  if ( $content =~ Paludis::ResumeState::Serialization::Grammar::grammar() ) {
    my $result = \%/;
    return $result;
  }

  return;

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
    if ( ref $thing eq 'ARRAY' ) {
      return _vivify_pure_array($thing);
    }
    if ( ref $thing eq 'HASH' ) {
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

sub _deserialize_full_objects {
  my ( $self, $content ) = @_;

  my @classes;
  my @arrays;

  local $Paludis::ResumeState::Serialization::Grammar::CLASS_CALLBACK = sub {
    my ( $classname, $parameters ) = @_;
    $parameters->{_classname} = $classname;
    my $object = bless $parameters, 'Paludis::ResumeState::Serialization::Grammar::FakeClass';
    push @classes, $object;
    return $object;
  };

  local $Paludis::ResumeState::Serialization::Grammar::ARRAY_CALLBACK = sub {
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
