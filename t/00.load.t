use Test::More tests => 5;    ## TODO: SOOOOOO many more tests

use Plack::Test;
use HTTP::Request::Common;

diag("Testing Dancer2::Plugin::Locale $Dancer2::Plugin::Locale::VERSION");

package YourDancerApp {
    use Dancer2;
    use Dancer2::Plugin::Locale;
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
};

my $app  = YourDancerApp->to_app;
my $test = Plack::Test->create($app);

my $res = $test->request( GET '/' );
like( $res->content, qr/Hello World/, 'locale() works in code' );

my $res = $test->request( GET '/tag' );
like( $res->content, qr/en/, 'defaults to en' );

$res = $test->request( GET '/isa' );
like( $res->content, qr/yes/, 'based on expected class' );

$res = $test->request( GET '/reuse' );
like( $res->content, qr/yes/, 'object is reused' );

$res = $test->request( GET '/multiton' );
like( $res->content, qr/yes/, 'object is multiton' );
