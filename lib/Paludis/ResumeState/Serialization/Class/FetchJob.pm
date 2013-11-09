use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::FetchJob;

# ABSTRACT: Mapping for Paludis "FetchJob" class.

=head1 SYNOPSIS

    FetchJob        => {
      'origin_id_spec' => { 'String'      => 17 }, # Role::Job
      'requirements'   => { 'FakeArray[]' => 17 }, # Role::JobRequirementConsumer
      'state'          => {                        # Role::JobStateConsumer
        'FakeClass[JobSucceededState]' => 14,
        'FakeClass[JobFailedState]'    => 3,
      },
    },


=cut
use Moose;
use MooseX::Types::Moose qw( :all );
use MooseX::Has::Sugar;

with 'Paludis::ResumeState::Serialization::Role::Job',
  'Paludis::ResumeState::Serialization::Role::JobStateConsumer',
  'Paludis::ResumeState::Serialization::Role::JobRequirementConsumer';

__PACKAGE__->meta->make_immutable;

1;

