
use strict;
use warnings;

package Paludis::ResumeState::Serialization::MockObjects;

use Paludis::ResumeState::Serialization::Grammar;
sub serialize {
    my ( $self, $data ) = @_ ;

}
sub deserialize {
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

1;
