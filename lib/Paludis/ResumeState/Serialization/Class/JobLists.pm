use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::JobLists;

use Moose;

=head1 SYNOPSIS

    JobLists       => {
      'pretend_job_list' => { 'FakeClass[JobList]' => 3 },
      'execute_job_list' => { 'FakeClass[JobList]' => 3 }
    },

=cut

use MooseX::Has::Sugar;

has 'pretend_job_list' => ( isa => 'Paludis::ResumeState::Serialization::Class::JobList', rw, required );
has 'execute_job_list' => ( isa => 'Paludis::ResumeState::Serialization::Class::JobList', rw, required );

__PACKAGE__->meta->make_immutable;

1;

