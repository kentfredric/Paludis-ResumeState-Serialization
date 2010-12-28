use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::JobSkippedState;

# ABSTRACT: Mapping for Paludis 'JobSkippedState';
use Moose;

with 'Paludis::ResumeState::Serialization::Role::JobState';


__PACKAGE__->meta->make_immutable;

1;
