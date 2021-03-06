use Mojolicious::Lite;
use Text::AAlib qw/:all/;
use Imager;
use Data::Dumper;
use warnings FATAL => 'all';

get '/' => sub {
    my $self = shift;
    $self->render('index');
};

post '/convert' => sub {
    my $self = shift;

# Check file size
    return $self->render(text => 'File is too big.', status => 200)
	if $self->req->is_limit_exceeded;

    my $up = $self->param('upload');
    $up->move_to('/tmp/aagen.png');

    my $preview = "";
    if ($up) {
    	my $img = Imager->new();
    	$img->open( file => '/tmp/aagen.png', type => 'png') or die;
    	my ($width, $height) = ($img->getwidth, $img->getheight);
    	my $aa = Text::AAlib->new(
    	    width  => $width,
    	    height => $height,
    	    mask   => AA_REVERSE_MASK,
    	    );
    	$aa->put_image(image => $img);
	$preview = $aa->render();
    }

    $self->render('convert', 'preview' => $preview);
};

app->start;

__DATA__

@@ index.html.ep
% layout 'default';
% title 'AA-generator';
<h1>AA-generator</h1>
<form action="convert" method="post" enctype="multipart/form-data">
filepath: <input type="file" name="upload" accept="image/png" required>
    <input type="submit" value="Submit">
</form>
<div id="loadingimage" style="display: none;">
<img src="/img/loading.gif">
</div>

@@ convert.html.ep
% layout 'preview';
% title 'AA-generator';
<h1>AA-generator</h1>
<div id="preview">
<pre>
<%= stash('preview') %>
</pre>
</div>
<div id="slider">
</div>

@@ layouts/preview.html.ep
<!DOCTYPE html>
<script src="https://code.jquery.com/jquery-1.11.0.min.js"></script>
<script src="https://code.jquery.com/ui/1.10.4/jquery-ui.min.js"></script>
<link rel="stylesheet" type="text/css" href="https://code.jquery.com/ui/1.9.2/themes/base/jquery-ui.css" media="all" />
<script>
 $(document).ready(function(){
   $("#slider").slider({
     value:50,
     min:10,
     max:100,
     step:1,
     range:"min",
     change : function(event,ui){
       $('#preview').css("zoom",ui.value + "%");
     }
   });
});
</script>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>

@@ layouts/default.html.ep
<!DOCTYPE html>
<script src="https://code.jquery.com/jquery-1.11.0.min.js"></script>
<script>
 $(document).ready(function(){
   $('form').submit(function(){
     $(this).hide();
     $('#loadingimage').show();
   });
 });
</script>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
