use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::JobRequirement;

=head1 SYNOPSIS

    JobRequirement => {
      'job_number'  => { 'String' => 17 },
      'required_if' => { 'String' => 17 }
    },


=cut

use Moose;

use MooseX::Types::Moose qw( :all );
use MooseX::Has::Sugar;

has 'job_number' => ( isa => Str, rw, required );
has 'required_if' => ( isa => Str, rw, required );

__PACKAGE__->meta->make_immutable;

1;
