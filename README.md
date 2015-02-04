# thyme

A minimal single-page web app for browsing and viewing local photos

<a href="https://www.flickr.com/photos/infobunny/7093903557"
title="thyme by poppet with a camera, on Flickr"><img
src="https://raw.githubusercontent.com/agorf/thyme/master/thyme.jpg" width="240"
height="240" alt="thyme"></a>

## Quick how-to

1. Clone repo: `git clone https://github.com/agorf/thyme && cd thyme`
1. Install system package dependencies (for [mini_exiftool][] and
   [mini_magick][] gems respectively):
   * Linux: `sudo apt-get install libimage-exiftool-perl imagemagick`
   * Mac OS X: `brew install exiftool imagemagick`
1. Install Ruby gems: `bundle install` (you need to have [Ruby][], [RubyGems][]
   and [bundler][] installed for this)
1. Install Bower components: `bower install` (you need to have [Node.js][] and
   [Bower][] installed for this)
1. Scan photos: `./script/scan_photos /path/to/photographs`
1. Generate thumbs: `./script/generate_thumbs` (may take a while)
1. Run app with `./script/server` and point your browser to
   <http://localhost:9292/>

[mini_exiftool]: https://rubygems.org/gems/mini_exiftool
[mini_magick]: https://rubygems.org/gems/mini_magick
[Ruby]: https://www.ruby-lang.org/en/
[RubyGems]: https://rubygems.org/
[bundler]: https://rubygems.org/gems/bundler
[Node.js]: http://nodejs.org/
[Bower]: http://bower.io/

## License

Licensed under the MIT license (see `LICENSE.txt`).

## Author

Aggelos Orfanakos, <http://agorf.gr/>
