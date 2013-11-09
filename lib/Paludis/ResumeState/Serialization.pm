use strict;
use warnings;

package Paludis::ResumeState::Serialization;
BEGIN {
  $Paludis::ResumeState::Serialization::AUTHORITY = 'cpan:KENTNL';
}
{
  $Paludis::ResumeState::Serialization::VERSION = '0.01000410';
}

# ABSTRACT: Work with resume-files generated by Paludis

use Paludis::ResumeState::Serialization::Grammar;
use Class::Load 0.06 qw();
use Params::Util qw( _HASHLIKE _STRING);
use Carp qw();

no autovivification;

sub _get_content {
  my ($config) = shift;
  return $config->{content} if _STRING( $config->{content} );
  Carp::croak('{ content => } must be a scalar ')
    if defined $config->{content};

  return;
}


sub _serializer {
  my ($name) = shift;
  my $formats = {
    'basic' => __PACKAGE__ . '::Basic',

    #    'simple_objects' => __PACKAGE__ . '::MockObjects',
    #    'full_objects'   => __PACKAGE__ . '::FullObjects',
  };
  my $formatnames = join q{,}, keys %{$formats};

  Carp::croak("Format Name must be a string ( in [$formatnames] ), not undef or a ref")
    unless defined $name and _STRING($name);

  Carp::croak("Format $name not in $formatnames ") unless exists $formats->{$name};
  Class::Load::load_class( $formats->{$name} );
  return $formats->{$name};
}




sub deserialize {
  my ( $self, $config ) = @_;

  Carp::croak( 'deserialize needs a configuration hash passed to it.' . qq{\n} . 'please see perldoc for details' )
    unless _HASHLIKE($config);

  my $content = _get_content($config);

  Carp::croak('Can\'t deserialize, no content provided, provide deserialize( hash ) with content => ')
    unless defined $content;

  return _serializer( $config->{format} )->deserialize( $config->{content} );
}


sub serialize {
  my ( $self, $config ) = @_;
  return _serializer( $config->{format} )->serialize( $config->{data} );
}

1;

__END__

=pod

=head1 NAME

Paludis::ResumeState::Serialization - Work with resume-files generated by Paludis

=head1 VERSION

version 0.01000410

=head1 SYNOPSIS

    use Paludis::ResumeState::Serialization;

    open my $fh, '<' , '/resumefile' or die;

    my $objects = Paludis::ResumeState::Serialization->deserialize({
        content => ( do { local $/ = undef;  scalar <$fh> } ),
        format => 'basic'
    });

    my $content = Paludis::ResumeState::Serialization->serialize({
        data => $object,
        format => 'basic'
    });

    # $content should == contents of resumefile.

This class is just really a proxy serialization interface for a few of the varying back-ends.

Currently only the 'basic' back-end exists, which provides basic, but consistent serialization support.

=head2 FormatNames

=head3 basic

Defers serialization to L<< C<::Basic>|Paludis::ResumeState::Serialization::Basic >>

=head1 METHODS

=head2 deserialize

    my $object = ::Serialization->deserialize({
        content => $string
        format  => FormatName
    });

See L</FormatNames>

=head2 serialize

    my $string = ::Serialization->serialize({
        data => $object,
        format => FormatName
    });

See L</FormatNames>

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentnl@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
