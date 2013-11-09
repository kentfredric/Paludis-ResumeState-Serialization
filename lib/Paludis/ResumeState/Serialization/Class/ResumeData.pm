use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::ResumeData;

use Moose;

=head1 SYNOPSIS

    ResumeData        => {
      'targets'                    => { 'FakeArray[String]'   => 3 },
      'world_specs'                => { 'FakeArray[String]'   => 3 },
      'job_lists'                  => { 'FakeClass[JobLists]' => 3 },
      'preserve_world'             => { 'String'              => 3 },
      'target_set'                 => { 'String'              => 3 },
      '_pid'                       => { 'String'              => 3 },
      'removed_if_dependent_names' => { 'FakeArray[]'         => 3 },
    },

=cut

use MooseX::Types::Moose qw( :all );
use MooseX::Has::Sugar;

has 'targets'     => ( isa => ArrayRef [Str], rw, required );
has 'world_specs' => ( isa => ArrayRef [Str], rw, required );
has 'job_lists' => ( isa => 'Paludis::ResumeState::Serialization::Class::JobLists', rw, required );
has 'preserve_world'             => ( isa => Str,      rw, required );
has 'target_set'                 => ( isa => Str,      rw, required );
has '_pid'                       => ( isa => Str,      rw, required );
has 'removed_if_dependent_names' => ( isa => ArrayRef, rw, required );

__PACKAGE__->meta->make_immutable;

1;
