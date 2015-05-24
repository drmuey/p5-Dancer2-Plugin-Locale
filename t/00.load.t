use Test::More tests => 9;    ## TODO: SOOOOOO many more tests

use Plack::Test;
use HTTP::Request::Common;
use File::Slurp      ();
use File::Path::Tiny ();

diag("Testing Dancer2::Plugin::Locale $Dancer2::Plugin::Locale::VERSION");

package YourDancerApp {
    use Dancer2;
    use Dancer2::Plugin::Locale;

    set template => "template_toolkit";
    File::Path::Tiny::rm( config->{appdir} . '/views' );
    File::Path::Tiny::mk( config->{appdir} . '/views/tt' );
    File::Slurp::write_file( config->{appdir} . '/views/tt.tt',       "[% locale.maketext('Hello World') %]" );
    File::Slurp::write_file( config->{appdir} . '/views/tt/tag.tt',   "[% locale.get_language_tag() %]" );
    File::Slurp::write_file( config->{appdir} . '/views/tt/noarg.tt', "[% locale() %]" );
    File::Slurp::write_file( config->{appdir} . '/views/tt/argfr.tt', "[% locale('fr') %]" );

    get '/' => sub {
        return locale->maketext('Hello World');
    };

    get '/tag' => sub {
        return locale->get_language_tag;
    };

    get '/isa' => sub {
        return locale->isa('Locale::Maketext::Utils') ? "yes" : "no";
    };

    get '/reuse' => sub {
        return locale() eq locale() ? "yes" : "no";
    };

    get '/multiton' => sub {
        return locale("fr") ne locale() ? "yes" : "no";
    };

    get '/tt' => sub {
        return template 'tt';
    };

    get '/tt/tag' => sub {
        return template 'tt/tag';
    };

    get '/tt/reuse' => sub {
        return template('tt/noarg') eq template('tt/noarg') ? "yes" : "no";
    };

    get '/tt/multiton' => sub {
        return template('tt/argfr') ne template('tt/noarg') ? "yes" : "no";
    };
};

my $app  = YourDancerApp->to_app;
my $test = Plack::Test->create($app);

my $res = $test->request( GET '/' );
like( $res->content, qr/Hello World/, 'locale() works in code' );

$res = $test->request( GET '/tag' );
like( $res->content, qr/en/, 'locale() defaults to en in code' );

$res = $test->request( GET '/isa' );
like( $res->content, qr/yes/, 'locale() based on expected class in code' );

$res = $test->request( GET '/reuse' );
like( $res->content, qr/yes/, 'locale() object is reused in code' );

$res = $test->request( GET '/multiton' );
like( $res->content, qr/yes/, 'locale() object is multiton in code' );

$res = $test->request( GET '/tt' );
like( $res->content, qr/Hello World/, 'locale() works in template' );

$res = $test->request( GET '/tt/tag' );
like( $res->content, qr/en/, 'locale() defaults to en in template' );

$res = $test->request( GET '/tt/reuse' );
like( $res->content, qr/yes/, 'locale() object is reused in template' );

$res = $test->request( GET '/tt/multiton' );
like( $res->content, qr/yes/, 'locale() object is multiton in template' );
