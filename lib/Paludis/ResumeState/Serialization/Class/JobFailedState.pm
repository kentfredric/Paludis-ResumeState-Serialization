use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::JobFailedState;

# ABSTRACT: Mapping for Paludis 'JobFailedState';
use Moose;

with 'Paludis::ResumeState::Serialization::Role::JobState';


__PACKAGE__->meta->make_immutable;

1;
