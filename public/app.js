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

  self.fileName = function () {
    return self.data.path.split('/').reverse()[0];
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

  self.fileName = function () {
    return self.data.path.split('/').reverse()[0];
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

  self.set = function (value) {
    location.hash = value.data.id;
  };

  Sammy(function () {
    this.get('#:setId/:photoId', function () {
      self.photosData(null); // from photos
      $.getJSON('/photo', { id: this.params.photoId }, self.photoData);
    });

    this.get('#:setId', function () {
      self.setsData(null); // from sets
      self.photoData(null); // back from photo
      $.getJSON('/photos', { set_id: this.params.setId }, self.photosData);
    });

    this.get('', function () {
      self.photosData(null); // back from set
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

ko.applyBindings(new ThymeViewModel());
