package WWW::Scraper::ISBN::ISBNnu_Driver;

use strict;
use warnings;
use HTTP::Request::Common;
use LWP::UserAgent;
use WWW::Scraper::ISBN::Driver;

our @ISA = qw(WWW::Scraper::ISBN::Driver);

our $VERSION = '0.17';

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

WWW::Scraper::ISBN::ISBNnu_Driver - Driver for L<WWW::Scraper::ISBN> that searches L<http://www.isbn.nu/>.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 REQUIRES

Requires the following modules be installed:

=over 4

=item L<WWW::Scraper::ISBN::Driver>

=item L<HTTP::Request::Common>

=item L<LWP::UserAgent>

=back

=head1 DESCRIPTION

Searches for book information from http://www.isbn.nu/.

=head1 METHODS

=over 4

=item C<clean_authors()>

Cleans junk from authors field.

=item C<trim()>

Trims excess whitespace.

=item C<search()>

Grabs page from L<http://www.isbn.nu/>'s handy interface and attempts to extract the desired information.

=head2 EXPORT

None by default.

=head1 SEE ALSO

=over 4

=item L<< WWW::Scraper::ISBN >>

=item L<< WWW::Scraper::ISBN::Record >>

=item L<< WWW::Scraper::ISBN::Driver >>

=back

No mailing list or website currently available.  Primary development done through CSX ( L<http://csx.calvin.edu/> )

=back

=head1 AUTHOR

Andy Schamp, E<lt>andy@schamp.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Andy Schamp

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
