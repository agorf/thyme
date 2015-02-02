function PhotoViewModel(data) {
  var self = this;

  self.data = data;

  self.aspectRatio = function () {
    var width = self.data.width;
    var height = self.data.height;
    var gcd = _.gcd(width, height);

    return (width / gcd) + ':' + (height / gcd);
  };

  self.fileName = function () {
    return self.data.path.split('/').reverse()[0];
  };

  self.shortName = function () {
    return _.trunc(self.fileName(), 20);
  };

  self.formattedSize =  function () {
    return (Math.round((self.data.size / (1024 * 1024)) * 100) / 100) + ' MB';
  };

  self.formattedTakenAt = function () {
    return moment(self.data.takenAt).format('ddd, D MMM YYYY HH:mm:ss z');
  };

  self.relativeTakenAt = function () {
    return moment(self.data.takenAt).fromNow();
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

  self.photo = ko.observable();

  self.photos = ko.observableArray([]);

  self.set = ko.observable();

  self.sets = ko.observableArray([]);

  self.loadPhotos = function (set) {
    self.photos([]); // clear photos

    $.getJSON('/photos', { set_id: set.data.id }, function (photosData) {
      _.forEach(photosData, function (photoData, i) {
        var photo = new PhotoViewModel(photoData);
        self.photos.push(photo);

        if (i === 0) {
          self.photo(photo); // show photo
        }
      });
    });
  };

  self.loadSets = function () {
    $.getJSON('/sets', function (setsData) {
      _.forEach(setsData, function (setData, i) {
        var set = new SetViewModel(setData);
        self.sets.push(set);

        if (i === 0) {
          self.set(set); // load photos
        }
      });
    });
  };

  self.set.subscribe(self.loadPhotos);

  self.loadSets();
};

// lodash extensions
_.mixin({
  gcd: function (a, b) {
    return b ? _.gcd(b, a % b) : Math.abs(a);
  },
  pluralize: function (n, singular, plural) {
    plural = plural || singular + 's';
    return n + ' ' + (n === 1 ? singular : plural);
  }
});

ko.applyBindings(new ThymeViewModel());
