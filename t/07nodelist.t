# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use Test;
BEGIN { plan tests=>15; }
END {ok(0) unless $loaded;}
use XML::LibXML;
$loaded = 1;
ok($loaded);

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# this performs general dom tests
my $file    = "example/dromeds.xml";
my $string = q{
<B lang="eng">hump</B>
<!-- thingi in german -->
<B lang="ger">H�cker</B>
};
my $camel = 'A';
my $tstr  = qq{<$camel>$string</$camel>};

my $string2 = "H�cker";


# init the file parser
my $parser = XML::LibXML->new();
$dom    = $parser->parse_file( $file );

if ( defined $dom ) {
    # get the root document
    $elem   = $dom->getDocumentElement(); 
    ok( defined $elem && $elem->getName() eq "dromedaries" );

    if( defined $elem ) {
        my @nodelist = $elem->getElementsByTagName( "species" );
        ok( scalar(@nodelist) == 3 );
        return unless scalar(@nodelist) == 3;
        my $lama = $nodelist[1];
        ok( defined $lama && $lama->getAttribute( "name" ) eq "Llama" );
    }	
  
    # we need to create a new document since dromeds is in ASCII ...
    my $doc = XML::LibXML::Document->new( '1.0','iso-8859-1' );
    my $elem2 = $doc->createElement( $camel );
    $doc->setDocumentElement( $elem2 ); 

    $elem2->appendWellBalancedChunk( $string );
    ok(  $elem2->toString() eq $tstr );

    my @bs = $elem2->getElementsByTagName('B');
    ok( ( scalar( @bs ) == 2 ) &&
        ( $bs[0]->getAttribute( 'lang' ) eq "eng" ) && 
        ( $bs[1]->getAttribute( 'lang' ) eq "ger" ) );

    my $elem3 = $doc->createElement('C');
    $elem3->setAttribute( "value", $string2 );


    ok( $elem3->toString() eq "<C value=\"$string2\"/>" );
  
    # test if the output of simple text nodes will be correct as well
    $elem4 = $doc->createTextNode( $string2 );
    ok( $string2 eq $elem4->toString() );
}
# warn "Doc fragments shall be destroyed here!\n";

# attribute lists

my $teststring = '<xml xmlns:b="http://whatever" attr1="1" attr2="2" b:attr3="3"/>';
my $dom2 = $parser->parse_string( $teststring );
if( defined $dom2 ) {
    my $elem = $dom2->getDocumentElement();
    ok($elem);
    my @attr = $elem->getAttributes();
    ok( scalar(@attr) , 4 );
    ok( $attr[1]->getValue(), 2 );
    
    ok( $attr[3]->getName(), "xmlns:b" );
    ok( $attr[3]->getValue(), "http://whatever" );

    my @nsattr = $elem->getAttributesNS("http://whatever");
    ok( scalar(@nsattr) , 1 );
    ok( $nsattr[0]->getValue(), 3 );
}
