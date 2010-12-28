use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::JobList;

use Moose;
use MooseX::Has::Sugar;

=head1 SYNOPSIS

  JobList => {
      'items' => {
        'FakeArray[FakeClass[PretendJob]]'                     => 3,
        'FakeArray[FakeClass[InstallJob],FakeClass[FetchJob]]' => 3,
      }
    },

=cut

has items => ( does => 'Paludis::ResumeState::Serialization::Role::Job', rw, required );

__PACKAGE__->meta->make_immutable;
1;

