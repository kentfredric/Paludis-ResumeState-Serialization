use strict;
use warnings;

use Test::More 0.96;
use IO::Uncompress::Gunzip qw( gunzip );
use Paludis::ResumeState::Serialization;

my (@files) = ( 'resume-1293352490.gz', 'resume-1293483679.gz', 'resumefile-1293138973.gz' );

for (@files) {
  gunzip "t/tfiles/$_", \my $data;

  my $structure = Paludis::ResumeState::Serialization->deserialize( { content => $data, format => 'basic' } );
  isnt( $structure, undef, "$_ returns a structure from _deserialize_basic" );
  my $stringified = Paludis::ResumeState::Serialization->serialize( { data => $structure, format => 'basic' } );
  is( $stringified, $data , 'Input =~ output ');
}

for (@files) {
  gunzip "t/tfiles/$_", \my $data;

  my $structure = Paludis::ResumeState::Serialization->deserialize( { content => $data, format => 'simple_objects' } );
  isnt( $structure, undef, "$_ returns a structure from _deserialize_mock_objects" );
  my $stringified = Paludis::ResumeState::Serialization->serialize( { data => $structure, format => 'simple_objects' } );

}

#use Data::Dumper (q{Dumper});

for (@files) {
  gunzip "t/tfiles/$_", \my $data;

  my $structure = Paludis::ResumeState::Serialization->deserialize( { content => $data, format => 'full_objects' } );
  isnt( $structure, undef, "$_ returns a structure from _deserialize_full_objects" );
  my $stringified = Paludis::ResumeState::Serialization->serialize( { data => $structure, format => 'full_objects' } );

  # local $Data::Dumper::Indent = 1;
  #print Dumper($structure);
}

done_testing();
