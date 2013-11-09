
use strict;
use warnings;

package Paludis::ResumeState::Serialization::Role::Job;

use Moose::Role;

use MooseX::Types::Moose qw( :all );
use MooseX::Has::Sugar;

has origin_id_spec => ( isa => Str, rw, required );

1;
