# thyme

A minimal single-page web app for browsing and viewing local photos

<a href="https://www.flickr.com/photos/infobunny/7093903557"
title="thyme by poppet with a camera, on Flickr"><img
src="https://raw.githubusercontent.com/agorf/thyme/master/thyme.jpg" width="240"
height="240" alt="thyme"></a>

## Installation

1. Install system package dependencies: `sudo apt-get install imagemagick
   libsqlite3-dev`
1. Clone repo: `git clone https://github.com/agorf/thyme`
1. Enter checked out directory: `cd thyme`
1. Install Ruby gems: `bundle install`
   * You need to have [bundler][] installed for this
1. Install Bower components: `bower install`
   * You need to have [Bower][] installed for this

## Use

1. Scan photos: `go run ./script/scan_photos.go /path/to/photos
   /another/path/to/photos`
   * You need to have [Go][] installed for this
   * You can build a `./scan_photos` binary to avoid compiling each time:
     `go build ./script/scan_photos.go`
   * It took 5m29s to scan 17407 photos on my system (~53 photos/sec)
1. Generate thumbs: `./script/generate_thumbs`
   * It may take a while the first time
1. Run app with `./script/server` and point your browser to
   <http://localhost:9292/>

Run `go run ./script/scan_photos.go` (or `./scan_photos` if you've built a
binary) and `./script/generate_thumbs` to add new photos.

[mini_magick]: https://rubygems.org/gems/mini_magick
[sqlite3]: https://rubygems.org/gems/sqlite3
[bundler]: https://rubygems.org/gems/bundler
[Bower]: http://bower.io/
[Go]: http://golang.org/

## Map support

A map with [OpenStreetMap][] tiles is shown below each geotagged photo. To use
[Mapbox][] (better-looking tiles):

1. [Signup][Mapbox] for a free account
1. [Get the map id][map_id] of your map you want to use
1. [Create an API access token][token]
1. Create `public/mapbox.js` with the following:

```javascript
mapbox_map_id = "your_map_id_here"
mapbox_api_token = "your_api_token_here"
```

[OpenStreetMap]: http://www.openstreetmap.org/
[Mapbox]: https://www.mapbox.com/
[map_id]: https://www.mapbox.com/help/define-map-id/
[token]: https://www.mapbox.com/help/create-api-access-token/

## License

Licensed under the MIT license (see `LICENSE.txt`).

## Author

Aggelos Orfanakos, <http://agorf.gr/>
