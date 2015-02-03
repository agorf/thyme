function PhotoViewModel(data) {
  var self = this;

  self.stdAspectRatios = [[4, 3], [3, 2], [16, 9], [5, 3], [5, 4], [1, 1]];

  self.data = data;

  self.aspectRatio = function () {
    var aspectRatio = self.calculateAspectRatio(self.data.width, self.data.height);
    var exactMatch = _.find(self.stdAspectRatios, function (ar) {
      return ar[0] == aspectRatio[0] && ar[1] == aspectRatio[1];
    });

    if (exactMatch) { return aspectRatio.join(':'); }

    var closestMatch = _.sortBy(self.stdAspectRatios, function (ar) {
      return Math.abs((ar[0] / ar[1]) - (aspectRatio[0] / aspectRatio[1]));
    })[0];

    return '~' + closestMatch.join(':');
  };

  self.calculateAspectRatio = function (width, height) {
    var gcd = _.gcd(width, height);
    return [width / gcd, height / gcd];
  };

  self.fileName = function () {
    return self.data.path.split('/').reverse()[0];
  };

  self.fileSize =  function () {
    return self.formatSize(self.data.size);
  };

  self.focalLength = function () {
    var fl = self.data.exif.FocalLength;
    var fl35 = self.data.exif.FocalLengthIn35mmFormat;

    if (!fl) {
      return;
    }

    fl = fl.replace('.0', '');

    if (!fl35) {
      return fl;
    }

    fl35 = fl35.replace('.0', '');

    if (fl === fl35) {
      return fl;
    }

    return fl + ' (<span title="35 mm equivalent">' + fl35 + '</span>)';
  };

  self.formatSize = function (bytes) {
    var n = bytes;

    if (n < 1024) {
      return _.pluralize(n, 'byte');
    }

    n /= 1024; // kB

    if (n < 1024) {
      return _.round(n, 2) + ' kB';
    }

    n /= 1024; // MB

    return _.round(n, 2) + ' MB';
  };

  self.shortName = function () {
    return _.trunc(self.fileName(), 20);
  };

  self.takenAtText = function () {
    return moment(self.data.takenAt).fromNow();
  };

  self.takenAtTitle = function () {
    return moment(self.data.takenAt).format('ddd, D MMM YYYY HH:mm:ss z');
  };
}

function SetViewModel(data) {
  var self = this;

  self.data = data;

  self.photosCountTitle = function () {
    return _.pluralize(self.data.photosCount, 'photo');
  };

  self.shortName = function () {
    return _.trunc(self.data.name, 20);
  };
}

function ThymeViewModel() {
  var self = this;

  self.photo = _.tap(ko.observable(), function (observable) {
    observable.subscribe(function (photo) {
      if (photo) {
        location.hash = photo.data.setId + '/' + photo.data.id;
      }
    });
  });

  self.photos = ko.observableArray([]);

  self.set = _.tap(ko.observable(), function (observable) {
    observable.subscribe(function (set) {
      location.hash = set.data.id;
    });
  });

  self.sets = ko.observableArray([]);

  Sammy(function () {
    this.get('#:setId/:photoId', function () {
      if (self.photo()) { return; } // clicked photo

      var data = {
        id: this.params.photoId,
        set_id: this.params.setId
      };

      $.getJSON('/photo', data, function (photoData) {
        self.photo(new PhotoViewModel(photoData));
      });
    });

    this.get('#:setId', function () {
      self.photo(null);

      if (self.photos().length > 0) { // back pressed
        return;
      }

      $.getJSON('/photos', { set_id: this.params.setId }, function (photosData) {
        _.forEach(photosData, function (photoData) {
          self.photos.push(new PhotoViewModel(photoData));
        });
      });
    });

    this.get('', function () {
      self.photos([]);

      if (self.sets().length > 0) { // back pressed
        return;
      }

      $.getJSON('/sets', function (setsData) {
        _.forEach(setsData, function (setData) {
          self.sets.push(new SetViewModel(setData));
        });
      });
    });
  }).run();
};

// lodash extensions
_.mixin({
  gcd: function (a, b) {
    return b ? _.gcd(b, a % b) : Math.abs(a);
  },
  pluralize: function (n, singular, plural) {
    plural = plural || singular + 's';
    return n + ' ' + (n === 1 ? singular : plural);
  },
  round: function (n, scale) {
    return Math.round(n * Math.pow(10, scale)) / Math.pow(10, scale);
  }
});

ko.applyBindings(new ThymeViewModel());
