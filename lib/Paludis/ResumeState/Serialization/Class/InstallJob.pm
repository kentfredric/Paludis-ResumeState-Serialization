use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::InstallJob;

# ABSTRACT: Mapping for Paludis "InstallJob" class.

=head1 SYNOPSIS

  InstallJob => {
      destination_type            => { String                                 => 17 }, # Role::DestinationConsumer
      origin_id_spec              => { String                                 => 17 }, # Role::Job
      destination_repository_name => { String                                 => 17 }, # Role::DestinationConsumer
      replacing_specs             => { 'FakeArray[String]'                    => 17 },
      requirements                => { 'FakeArray[FakeClass[JobRequirement]]' => 17 }, # Role::JobRequirementConsumer
      state                       => {                                                 # Role::JobStateConsumer
        'FakeClass[JobSkippedState]'   => 3,
        'FakeClass[JobSucceededState]' => 9,
        'FakeClass[JobFailedState]'    => 5
      },
    },


=cut

use Moose;
use MooseX::Types::Moose qw( :all );
use MooseX::Has::Sugar;

with 'Paludis::ResumeState::Serialization::Role::Job',
  'Paludis::ResumeState::Serialization::Role::JobStateConsumer',
  'Paludis::ResumeState::Serialization::Role::JobRequirementConsumer',
  'Paludis::ResumeState::Serialization::Role::DestinationConsumer';

has replacing_specs => ( isa => ArrayRef [Str], rw, required );

__PACKAGE__->meta->make_immutable;

1;
