
use strict;
use warnings;

package Paludis::ResumeState::Serialization::Role::JobStateConsumer;

use Moose::Role;

use MooseX::Types::Moose qw( :all );
use MooseX::Has::Sugar;

has state => ( does => 'Paludis::ResumeState::Serialization::Role::JobState', rw, required );

1;
