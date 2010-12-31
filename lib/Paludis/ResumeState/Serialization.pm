use strict;
use warnings;

package Paludis::ResumeState::Serialization;

use Moose;
use Paludis::ResumeState::Serialization::Grammar;
use Class::Load 0.06;
use Scalar::Util qw( blessed );
use Params::Util qw( _HASHLIKE _STRING _SCALAR _HANDLE _ARRAYLIKE );
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

  my $formats = {
    'basic'          => '_deserialize_basic',
    'simple_objects' => '_deserialize_mock_objects',
    'full_objects'   => '_deserialize_full_objects',
  };
  Carp::croak("Format $config->{format} not in basic,simple_objects,full_objects") unless exists $formats->{ $config->{format} };

  my $method = $self->can( $formats->{ $config->{format} } );
  return $self->$method( $config->{content} );
}

sub serialize {
  my ( $self, $config ) = @_;
  my $formats = {
    'basic'          => '_serialize_basic',
    'simple_objects' => '_serialize_mock_objects',
    'full_objects'   => '_serialize_full_objects',
  };
  Carp::croak("Format $config->{format} not in basic,simple_objects,full_objects") unless exists $formats->{ $config->{format} };
  my $method = $self->can( $formats->{ $config->{format} } );
  return $self->$method( $config->{data} );
}

sub _deserialize_basic {
  my ( $self, $content ) = @_;

  local $Paludis::ResumeState::Serialization::Grammar::CLASS_CALLBACK = sub {
    my ( $classname, $parameters ) = @_;
    return { type => 'class', classname => $classname, parameters => $parameters };
  };

  local $Paludis::ResumeState::Serialization::Grammar::LIST_CALLBACK = sub {
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

  local $Paludis::ResumeState::Serialization::Grammar::LIST_CALLBACK = sub {
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

sub _serialize_basic_array {
  my $data = shift;
  my $out = "c(";
  my $i = 1;
  my @pairs = ();
  for my $value ( @{ $data->{parameters} } ){
    my $key = $i;
    $i++;
    push @pairs, sprintf q{%s=%s;}, $key, _serialize_basic_value($value);
  }
  push @pairs , 'count=' . _serialize_basic_value( $data->{count} ) . ';';
  $out .= ( join q{}, @pairs );
  $out .= ')';
  return $out;
}
sub _serialize_basic_class {
  my $data = shift;
  my $out = $data->{classname} . "(";
  $out .= _serialize_basic_parameters( $data->{parameters} );
  $out .= ')';
  return $out;
}

sub _serialize_basic_value {
  my $value = shift;
  if ( defined _STRING($value) ) {
    $value =~ s/"/\\"/g;
    return sprintf q{"%s"}, $value;
  }
  if ( _HASHLIKE($value) ) {
    if ( defined $value->{type} and $value->{type} eq 'class' ) {
      return _serialize_basic_class( $value );
    }
    if ( defined $value->{type} and $value->{type} eq 'array' ) {
      return _serialize_basic_array( $value );
    }
    Carp::croak("UNEXPECTED PARAMETER TYPE: $value->{type} ");

  }
  Carp::croak("UNEXPECTED PARAMETER VALUE: $value");

}

sub _serialize_basic_parameters {
  my $data  = shift;
  my @pairs = ();
  for my $key ( sort keys %$data ) {
    my $value = $data->{$key};
    push @pairs, sprintf q{%s=%s;}, $key, _serialize_basic_value($value);
  }
  return ( join q{}, @pairs );
}

sub _serialize_basic_resumespec {
  my $data = shift;
  return undef unless _HASHLIKE($data);
  return undef unless defined $data->{ResumeSpec};
  return undef unless defined $data->{ResumeSpec}->{classname};
  return undef unless defined $data->{ResumeSpec}->{type} and $data->{ResumeSpec}->{type} eq 'class';
  return undef unless defined $data->{ResumeSpec}->{parameters};
  return undef unless defined $data->{ResumeSpec}->{parameters}->{_pid};
  my $out = $data->{ResumeSpec}->{classname} . '@' . $data->{ResumeSpec}->{parameters}->{_pid};
  delete $data->{ResumeSpec}->{parameters}->{_pid};
  $out .= '(';
  $out .= _serialize_basic_parameters( $data->{ResumeSpec}->{parameters} );
  $out .= ');';
  return $out;
}

sub _serialize_basic {
  my ( $self, $data ) = @_;
  my $string = _serialize_basic_resumespec($data);

#  die;
    return $string;
}

sub _serialize_mock_objects {

}

sub _serialize_full_objects {

}

1;
