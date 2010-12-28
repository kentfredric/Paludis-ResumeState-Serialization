use strict;
use warnings;

package Paludis::ResumeState::Serialization::Class::JobSucceededState;

# ABSTRACT: Mapping for Paludis 'JobSucceededState';
use Moose;

with 'Paludis::ResumeState::Serialization::Role::JobState';

__PACKAGE__->meta->make_immutable;

1;
