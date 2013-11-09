
use strict;
use warnings;

package Paludis::ResumeState::Serialization::Role::JobRequirementConsumer;

use Moose::Role;

use MooseX::Types::Moose qw( :all );
use MooseX::Has::Sugar;

has requirements => ( isa => ArrayRef, rw, required );

1;
