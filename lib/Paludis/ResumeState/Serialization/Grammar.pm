use strict;
use warnings;

package Paludis::ResumeState::Serialization::Grammar;

use Regexp::Grammars;
use Regexp::Grammars::Common::String;

our $CLASS_CALLBACK;
our $LIST_CALLBACK;

{
  package    # Hide
    Paludis::ResumeState::Serialization::Grammar::FakeClass;

  package    # Hide
    Paludis::ResumeState::Serialization::Grammar::FakeList;
}

sub classize {
  my ( $name, $parameters, $parameters_list, $extra ) = @_;
  if ( defined $CLASS_CALLBACK ) {
    return $CLASS_CALLBACK->( $name, $parameters , $parameters_list , $extra );
  }
  bless $parameters, __PACKAGE__ . '::FakeClass';
  $parameters->{_classname} = $name;
  return $parameters;
}

sub listize {
  my ($parameters) = @_;
  if ( defined $LIST_CALLBACK ) {
    return $LIST_CALLBACK->($parameters);
  }
  bless $parameters, __PACKAGE__ . '::FakeArray';
  return $parameters;
}

my $t;

sub grammar {
  _build_grammar() unless defined $t;
  return $t;
}

sub _build_grammar {
  $t = qr{

    <extends: Regexp::Grammars::Common::String>
    <nocontext: >

    <ResumeSpec>

    <token: ResumeSpec>
        <classname=([A-Z][A-Za-z0-9]+)>
        @
        <pid=(\d+)>
        \(<parameters=paramlist>\)

    (?{
        if( ref $MATCH{parameters} ){
            my @parameters = @{$MATCH{parameters}};
            my %hash;
            my @list;
            my %extra = ();
            my $i;
            for( @parameters ){
                $hash{$_->{label}} = $_->{value};
                push @list, [ $_->{label} , $_->{value} ];
                $i++;
            }
            if( scalar keys %hash  == $i ){
                $extra{pid} = $MATCH{pid};
                $MATCH = classize( $MATCH{classname}, \%hash, \@list, \%extra );
            }


        }
    })

    <token: classname>  [A-Z][A-Za-z0-9]*

    <token: classvalue> <classname>\(<parameters=paramlist>\)

    (?{
        if( not $MATCH{parameters} ) {
            $MATCH = classize( $MATCH{classname}, {}, [], {} );
        } elsif( ref $MATCH{parameters} ){
            my @parameters = @{$MATCH{parameters} || []};
            my %hash;
            my @list;
            my $i;
            for( @parameters ){
                $hash{$_->{label}} = $_->{value};
                push @list, [ $_->{label} , $_->{value} ];
                $i++;
            }
            if( scalar keys %hash  == $i ){
                $MATCH = classize( $MATCH{classname}, \%hash, \@list, {}  );
            }


        }
    })

    <token: cvalue>     <classname=(c)>\(<parameters=paramlist>\)
    (?{
        if( not $MATCH{parameters} ){
            $MATCH = listize( [] );
        } elsif ( ref $MATCH{parameters} and $MATCH{parameters}->[-1]->{label} eq 'count' ){
            my $count = pop @{ $MATCH{parameters} };
            $MATCH{count} = int($count->{value});
            my @items = map { $_->{value} } @{ $MATCH{parameters} };
            $MATCH = listize( \@items );
        }
    })

    <token: value>      <MATCH=classvalue>|<MATCH=cvalue>|<MATCH=String>
    <token: label>      [a-z0-9_]+

    <token: paramlist>  (|(<[MATCH=parameter]> ** (;))(;)?)

    <token: parameter>  <label>=<value>

    }x;

}

1;
