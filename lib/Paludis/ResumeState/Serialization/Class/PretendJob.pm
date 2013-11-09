
package Paludis::ResumeState::Serialization::Class::PretendJob;

# ABSTRACT: Mapping for Paludis "PretendJob" class.

=head1 SYNOPSIS

    PretendJob => {
      'destination_type'            => { 'String' => 17 }, # DestinationConsumer
      'origin_id_spec'              => { 'String' => 17 }, # Job
      'destination_repository_name' => { 'String' => 17 }, # DestinationConsumer
   }

=cut

use Moose;
use MooseX::Types::Moose qw( :all );
use MooseX::Has::Sugar;

with 'Paludis::ResumeState::Serialization::Role::Job', 'Paludis::ResumeState::Serialization::Role::DestinationConsumer';

__PACKAGE__->meta->make_immutable;

1;
