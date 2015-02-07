function PhotoViewModel(data) {
  var self = this;

  self.stdAspectRatios = [[4, 3], [3, 2], [16, 9], [5, 3], [5, 4], [1, 1]];

  self.data = data;

  self.prevPhotoData = ko.observable();

  self.prevPhoto = ko.computed(function () {
    if (self.prevPhotoData()) {
      return new PhotoThumbViewModel(self.prevPhotoData());
    }
  });

  if (self.data.prev_photo_id) {
    $.getJSON('/photo', { id: self.data.prev_photo_id }, self.prevPhotoData);
  }

  self.nextPhotoData = ko.observable();

  self.nextPhoto = ko.computed(function () {
    if (self.nextPhotoData()) {
      return new PhotoThumbViewModel(self.nextPhotoData());
    }
  });

  if (self.data.next_photo_id) {
    $.getJSON('/photo', { id: self.data.next_photo_id }, self.nextPhotoData);
  }

  self.setData = ko.observable();

  self.set = ko.computed(function () {
    if (self.setData()) {
      return new SetThumbViewModel(self.setData());
    }
  });

  if (self.data.set_id) {
    $.getJSON('/set', { id: self.data.set_id }, self.setData);
  }

  self.aspectRatio = function (width, height) {
    var gcd = self.gcd(width, height);
    return [width / gcd, height / gcd];
  };

  self.aspectRatioText = function () {
    var aspectRatio = self.aspectRatio(self.data.width, self.data.height);
    var exactMatch = _.find(self.stdAspectRatios, function (ar) {
      if (self.isPortrait()) {
        ar[1] = [ar[0], ar[0] = ar[1]][0]; // swap hack
      }

      return ar[0] == aspectRatio[0] && ar[1] == aspectRatio[1];
    });

    if (exactMatch) { return aspectRatio.join(':'); }

    var closestMatch = _.sortBy(self.stdAspectRatios, function (ar) {
      return Math.abs((ar[0] / ar[1]) - (aspectRatio[0] / aspectRatio[1]));
    })[0];

    return '<span title="Approximation">~</span>' + closestMatch.join(':');
  };

  self.baseName = function (path) {
    return _.last(path.split('/'));
  }

  self.bigThumbHeight = function () {
    if (self.isPortrait()) {
      return self.bigThumbHeightPortrait();
    }

    return self.bigThumbHeightLandscape();
  };

  self.bigThumbHeightLandscape = function () {
    if (self.bigThumbWidth() < 1000) { return self.data.height; }
    var aspectRatio = self.aspectRatio(self.data.width, self.data.height);
    return self.round((aspectRatio[1] / aspectRatio[0]) * self.bigThumbWidth());
  };

  self.bigThumbHeightPortrait = function () {
    if (self.data.height < 1000) { return self.data.height; }
    return 1000;
  };

  self.bigThumbWidth = function () {
    if (self.isPortrait()) {
      return self.bigThumbWidthPortrait();
    }

    return self.bigThumbWidthLandscape();
  };

  self.bigThumbWidthLandscape = function () {
    if (self.data.width < 1000) { return self.data.width; }
    return 1000;
  };

  self.bigThumbWidthPortrait = function () {
    if (self.bigThumbHeight() < 1000) { return self.data.width; }
    var aspectRatio = self.aspectRatio(self.data.width, self.data.height);
    return self.round((aspectRatio[0] / aspectRatio[1]) * self.bigThumbHeight());
  };

  self.fileName = function () {
    return self.baseName(self.data.path);
  };

  self.fileSize =  function () {
    return self.formatSize(self.data.size);
  };

  self.focalLength = function () {
    var fl = self.data.exif.FocalLength;
    var fl35 = self.data.exif.FocalLengthIn35mmFormat;

    if (!fl) { return; }

    fl = fl.replace('.0', '');

    if (!fl35) { return fl; }

    fl35 = fl35.replace('.0', '');

    if (fl === fl35) { return fl; }

    return fl + ' (<span title="35 mm equivalent">' + fl35 + '</span>)';
  };

  self.formatSize = function (bytes) {
    var n = bytes;

    if (n < 1024) { return _.pluralize(n, 'byte'); }

    n /= 1024; // kB

    if (n < 1024) { return self.round(n, 2) + ' kB'; }

    n /= 1024; // MB

    return self.round(n, 2) + ' MB';
  };

  self.gcd = function (a, b) {
    return b ? self.gcd(b, a % b) : Math.abs(a);
  };

  self.isPortrait = function () {
    return self.data.width < self.data.height;
  };

  self.round = function (n, scale) {
    if (typeof scale === 'undefined') { scale = 0; }
    return Math.round(n * Math.pow(10, scale)) / Math.pow(10, scale);
  }

  self.takenAtText = function () {
    return moment(self.data.taken_at).fromNow();
  };

  self.takenAtTitle = function () {
    return moment(self.data.taken_at).format('ddd, D MMM YYYY HH:mm:ss z');
  };
}

function PhotoThumbViewModel(data) {
  var self = this;

  self.data = data;

  self.baseName = function (path) {
    return _.last(path.split('/'));
  }

  self.fileName = function () {
    return self.baseName(self.data.path);
  };
}

function SetThumbViewModel(data) {
  var self = this;

  self.data = data;

  self.photosCountTitle = function () {
    return _.pluralize(self.data.photos_count, 'photo');
  };

  self.shortName = function () {
    return _.trunc(self.data.name, 25);
  };
}

function ThymeViewModel() {
  var self = this;

  self.photoData = ko.observable();

  self.photo = ko.pureComputed({
    read: function () {
      if (self.photoData()) {
        return new PhotoViewModel(self.photoData());
      }
    },
    write: function (value) {
      self.photoData(value.data);
      location.hash = value.data.set_id + '/' + value.data.id;
    },
    owner: this
  });

  self.photosData = ko.observable();

  self.photos = ko.computed(function () {
    if (self.photosData()) {
      return _.map(self.photosData(), function (photoData) {
        return new PhotoThumbViewModel(photoData);
      });
    }
  });

  self.setsData = ko.observable();

  self.sets = ko.computed(function () {
    if (self.setsData()) {
      return _.map(self.setsData(), function (setData) {
        return new SetThumbViewModel(setData);
      });
    }
  });

  self.setData = ko.observable();

  self.set = function (value) {
    self.setData(value.data);
    location.hash = value.data.id;
  };

  self.pageTitle = ko.computed(function () {
    var parts = ['thyme'];

    if (self.setData()) {
      parts.push(self.setData().name);
    }
    else if (self.photo() && self.photo().setData()) {
      parts.push(self.photo().setData().name);
    }

    if (self.photo()) {
      parts.push(self.photo().fileName());
    }

    return parts.join(' - ');
  });

  Sammy(function () {
    this.get('#:setId/:photoId', function () {
      self.photosData(null); // from photos

      if (!self.photoData()) { // direct (not from photos)
        $.getJSON('/photo', { id: this.params.photoId }, self.photoData);
      }
    });

    this.get('#:setId', function () {
      self.setsData(null); // from sets
      self.photoData(null); // from photo

      if (!self.setData()) { // direct (not from sets or photo)
        $.getJSON('/set', { id: this.params.setId }, self.setData);
      }

      $.getJSON('/photos', { set_id: this.params.setId }, self.photosData);
    });

    this.get('', function () {
      self.photosData(null); // back from set
      self.setData(null); // back from set
      $.getJSON('/sets', self.setsData);
    });
  }).run();
};

// lodash extensions
_.mixin({
  pluralize: function (n, singular, plural) {
    plural = plural || singular + 's';
    return n + ' ' + (n === 1 ? singular : plural);
  }
});

ko.bindingHandlers.photoMap = {
  init: function (element, valueAccessor) {
    var latlng = valueAccessor(); // [lat, lng]

    $(element).show(); // show container before creating map

    $.getJSON('/config', function (configData) {
      var map = L.map('map').setView(latlng, 15);
      L.tileLayer(
        'http://{s}.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={token}',
        { id: configData.mapbox_map_id, token: configData.mapbox_token }
      ).addTo(map);
      L.marker(latlng).addTo(map);
    });
  }
};

ko.applyBindings(new ThymeViewModel(), $('#thyme')[0]);
