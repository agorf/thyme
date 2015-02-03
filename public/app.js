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
  }
});

ko.applyBindings(new ThymeViewModel());
