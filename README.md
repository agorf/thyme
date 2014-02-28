# Thyme

A minimal gallery for viewing your photos.

## Quick how-to

1. Install system deps: `sudo apt-get install libimage-exiftool-perl
   imagemagick`
1. Checkout code: `git clone` and `cd thyme`
1. Install gems: `bundle install`
1. Build database: `bundle exec rake build_index[/path/to/photographs]`
1. Generate thumbs: `bundle exec rake generate_thumbs` (may take a while)
1. Run app: `bundle exec rake serve`
1. Open <http://localhost:4567/>
