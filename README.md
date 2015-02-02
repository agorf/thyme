# thyme

A minimal single-page web app for browsing and viewing photos locally.

<a href="https://www.flickr.com/photos/infobunny/7093903557" title="thyme by
poppet with a camera, on Flickr"><img
src="https://raw.githubusercontent.com/agorf/thyme/master/thyme.jpg" width="240"
height="240" alt="thyme"></a>

## Quick how-to

1. Install system deps: `sudo apt-get install libimage-exiftool-perl
   imagemagick` (for `mini_exiftool` and `mini_magick` gems respectively)
1. Clone code: `git clone https://github.com/agorf/thyme && cd thyme`
1. Install Ruby gems: `bundle install`
1. Install [Bower](http://bower.io/) components: `bower install`
1. Scan photos: `bundle exec rake scan[/path/to/photographs]`
1. Generate thumbs: `bundle exec rake generate_thumbs` (may take a while)
1. Run app and open in browser: `bundle exec rake open`

## License

Licensed under the MIT license (see `LICENSE.txt`).

## Author

Aggelos Orfanakos, <http://agorf.gr/>
