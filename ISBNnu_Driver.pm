package WWW::Scraper::ISBN::ISBNnu_Driver;

use 5.008;
use strict;
use warnings;
use HTTP::Request::Common;
use LWP::UserAgent;
use WWW::Scraper::ISBN::Driver;
        
require Exporter;

our @ISA = qw(WWW::Scraper::ISBN::Driver);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use WWW::Scraper::ISBN::ISBNnu_Driver ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.15';

sub clean_authors {
	my $self = shift;
        my $authors_with_tags = shift;
        my @authors = split('<br>', $authors_with_tags);
        foreach my $author (@authors) {
                $author =~ s/<[^>]+>//g;
        }
        return join(", ", @authors);
}

sub trim {
	my $self = shift;
        $_ = shift;
        s/^\s+//;           # trim leading whitespace
        s/\s+$//;           # trim trailing whitespace
        s/\n//g;            # trim newlines?
        s/ +/ /g;           # trim extra middle space
        return $_;
}
                
sub search {
        my $self = shift;
        my $isbn = shift;
        $self->found(0);
        $self->book(undef);
        my $post_url = "http://isbn.nu/".$isbn;
        my $ua = new LWP::UserAgent;
        my $res = $ua->request(GET $post_url);
        my $doc = $res->as_string;
        
        my $volume = "";
        my $edition = "";
        my $title = "";
                
        if ($doc =~ /<p class="rsheadnr"><font color="#333366">([^<]+)<\/font><\/p>/) {
                $title = $self->trim($1);
        }

        if (($title eq "") || ($title eq "No Title Found")) {
		$self->found(0);
                return 0;
        } else {
		$self->found(1);
	}

        $doc =~ /<td class="smallbold" align="left" valign="top" width="35%">Authors*<\/td><td class="bodytext" align="left" valign="top">(.+)<\/td><\/tr>/;
        my $tempauthors = $1;
        my $authors = "";
        my $sep = "";
        while ($tempauthors =~ s/<a href="[^"]+">([^<]+)<\/a>(<br>)*//) {
                $authors .=  $sep.$1;
                $sep = ", ";
        }
         
        if ($doc =~ /<tr><td class="smallbold" align="left" valign="top" width="35%">Edition<\/td><td class="bodytext" align="left" valign="top">([^<]+)<\/td><\/tr>/) {
                $edition = $1;
        }
         
        if ($doc =~ /<tr><td class="smallbold" align="left" valign="top" width="35%">Volume<\/td><td class="bodytext" align="left" valign="top">([^<]+)<\/td><\/tr>/) {
                $volume = $1;
        }

        my $bk = {   
                'isbn' => $isbn,
                'author' => $authors,
                'title' => $title,
                'edition' => $edition,
        };
	$self->book($bk);
        return $bk;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

WWW::Scraper::ISBN::ISBNnu_Driver - Driver for WWW::Scraper::ISBN that searches http://www.isbn.nu/.

=head1 SYNOPSIS

See parent class documentation (WWW::Scraper::ISBN::Driver)

=head1 REQUIRES

Requires the following modules be installed:

WWW::Scraper::ISBN::Driver
HTTP::Request::Common
LWP::UserAgent

=head1 DESCRIPTION

Searches for book information from http://www.isbn.nu/.

=head1 METHODS

=head2 clean_authors()

Cleans junk from authors field.

=head2 trim()

Trims excess whitespace.

=head2 search()

Grabs page from http://www.isbn.nu/'s handy interface and attempts to extract the desired information.

=head2 EXPORT

None by default.

=head1 SEE ALSO

WWW::Scraper::ISBN
WWW::Scraper::Record
WWW::Scraper::Driver

No mailing list or website currently available.  Primary development done through CSX [http://csx.calvin.edu/]

=head1 AUTHOR

Andy Schamp, E<lt>ams5@calvin.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Andy Schamp

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
