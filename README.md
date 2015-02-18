# thyme

A minimal single-page web app for browsing and viewing your photos

<a href="https://www.flickr.com/photos/infobunny/7093903557"
title="thyme by poppet with a camera, on Flickr"><img
src="https://raw.githubusercontent.com/agorf/thyme/master/thyme.jpg" width="240"
height="240" alt="thyme"></a>

## Installation

1. Clone repo: `git clone https://github.com/agorf/thyme`
1. Enter directory: `cd thyme`
1. Install gems: `bundle install` ([Bundler][] needs to be installed)
1. Install Bower components: `bower install` ([Bower][] needs to be installed)
1. Install [thyme-backend][] binaries: `go get
   https://github.com/agorf/thyme-backend/thyme-scan-photos && go get
   https://github.com/agorf/thyme-backend/thyme-generate-thumbs`
   ([Go][] needs to be installed)
1. Install system packages: `sudo apt-get install libvips-tools libsqlite3-dev`

[Bundler]: http://bundler.io/
[Bower]: http://bower.io/
[thyme-backend]: https://github.com/agorf/thyme-backend
[Go]: http://golang.org/

## Use

1. Enter directory: `cd thyme`
1. Scan photos: `thyme-scan-photos /path/to/photos /another/path/to/photos`
1. Generate thumbs: `thyme-generate-thumbs`
1. Run app with `bundle exec rackup` and point your browser to
   <http://localhost:9292/>

Repeat the above steps each time you want to add new photos.

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
