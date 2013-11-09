
use strict;
use warnings;

package Paludis::ResumeState::Serialization::Role::DestinationConsumer;

use Moose::Role;

use MooseX::Types::Moose qw( :all );
use MooseX::Has::Sugar;

has destination_type            => ( isa => Str,      rw, required );
has destination_repository_name => ( isa => Str,      rw, required );

1;
