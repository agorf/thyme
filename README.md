# Thyme

A simple, web-based photo browser and viewer.

## Quick how-to

1. Install system deps: `sudo apt-get install libimage-exiftool-perl
   imagemagick` (for `mini_exiftool` and `mini_magick` gems respectively)
1. Checkout code: `git clone https://github.com/agorf/thyme && cd thyme`
1. Install Ruby gems: `bundle install`
1. Install [Bower](http://bower.io/) components: `bower install`
1. Scan photos: `bundle exec rake scan[/path/to/photographs]`
1. Generate thumbs: `bundle exec rake generate_thumbs` (may take a while)
1. Open app: `bundle exec rake open`

## License

Licensed under the MIT license (see `LICENSE.txt`).

## Author

Aggelos Orfanakos, <http://agorf.gr/>
