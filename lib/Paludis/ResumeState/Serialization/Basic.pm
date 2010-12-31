use strict;
use warnings;

package Paludis::ResumeState::Serialization::Basic;

use Paludis::ResumeState::Serialization::Grammar;
use Params::Util qw( _HASHLIKE _STRING );

use Data::Dumper qw( Dumper );

sub _debug {
    local $Data::Dumper::Indent=1;
    local $Data::Dumper::Maxdepth=3;
    # print Dumper( \@_ );
}

sub serialize {
  my ( $self, $data ) = @_;
  my $string = _serialize_basic_resumespec($data);
  return $string;
}


sub deserialize {
  my ( $self, $content ) = @_;

  local $Paludis::ResumeState::Serialization::Grammar::CLASS_CALLBACK = sub {
    my ( $classname, $parameters, $parameters_list, $extra ) = @_;
    return { type => 'class', classname => $classname, parameters => $parameters_list, %{$extra} };
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
  _debug( 'serialize_basic_parameters', $data );

  my @pairs = ();
  for my $record ( @$data ) {
    my ( $key, $value ) = @{ $record };
#    my $value = $data->{$key};
    push @pairs, sprintf q{%s=%s;}, $key, _serialize_basic_value($value);
  }
  return ( join q{}, @pairs );
}

sub _serialize_basic_resumespec {
  my $data = shift;
  _debug( 'serialize_basic_resumespec', $data );
  return undef unless _HASHLIKE($data);
  return undef unless defined $data->{ResumeSpec};
  return undef unless defined $data->{ResumeSpec}->{classname};
  return undef unless defined $data->{ResumeSpec}->{type} and $data->{ResumeSpec}->{type} eq 'class';
  return undef unless defined $data->{ResumeSpec}->{parameters};
  return undef unless defined $data->{ResumeSpec}->{pid};
  my $out = $data->{ResumeSpec}->{classname} . '@' . $data->{ResumeSpec}->{pid};
  $out .= '(';
  $out .= _serialize_basic_parameters( $data->{ResumeSpec}->{parameters} );
  $out .= ');';
  return $out;
}


1;

