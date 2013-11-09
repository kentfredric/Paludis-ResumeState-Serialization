use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::JobList;

use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw( :all );
use Moose::Util::TypeConstraints qw( role_type );

=head1 SYNOPSIS

  JobList => {
      'items' => {
        'FakeArray[FakeClass[PretendJob]]'                     => 3,
        'FakeArray[FakeClass[InstallJob],FakeClass[FetchJob]]' => 3,
      }
    },

=cut

#my $job = role_type( 'Paludis::ResumeState::Serialization::Role::Job' );
has items => ( isa => ArrayRef[ role_type( 'Paludis::ResumeState::Serialization::Role::Job' ) ], rw, required );

__PACKAGE__->meta->make_immutable;
1;

