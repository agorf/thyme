window.App = Ember.Application.create({
  LOG_TRANSITIONS: true
});

App.computed = {}

App.computed.pluralize = function (property, singular, plural) {
  return function () {
    var n = this.get(property);
    return n + ' ' + (n === 1 ? singular : plural);
  }.property(property);
};

App.Router.map(function () {
  this.resource('sets', { path: '/' }, function () {
    this.resource('set', { path: '/set/:set_id' }, function () {
      this.resource('photo', { path: '/photo/:photo_id' });
    });
  });
});

App.SetsRoute = Ember.Route.extend({
  model: function () {
    return Ember.$.getJSON('/set');
  }
});

App.SetRoute = Ember.Route.extend({
  model: function (params) {
    return Ember.$.getJSON('/set', { id: params.set_id });
  },
  setupController: function (controller, set) {
    controller.set('model', set);
    Ember.$.getJSON('/photo', { set_id: set.id }).then(function (data) {
      controller.set('photos', data);
    });
  }
});

App.PhotoRoute = Ember.Route.extend({
  model: function (params) {
    return Ember.$.getJSON('/photo', { id: params.photo_id });
  }
});

App.SetController = Ember.ObjectController.extend({
  photos_count_title: App.computed.pluralize('model.photos_count',
                                             'photo',
                                             'photos')
});

App.PhotoController = Ember.ObjectController.extend({
  aspectRatio: function () {
    var width = this.get('model.width');
    var height = this.get('model.height');
    var gcd = (function gcd(a, b) {
      return b ? gcd(b, a % b) : Math.abs(a);
    })(width, height);
    return (width / gcd) + ':' + (height / gcd);
  }.property('model.width, model.height'),
  fileName: function () {
    return this.get('model.path').split('/').reverse()[0];
  }.property('model.path'),
  formattedSize: function () {
    return (Math.round((this.get('model.size') / 1048576) * 100) / 100) + ' MB';
  }.property('model.size'),
  formattedTakenAt: function () {
    return moment(this.get('model.taken_at')).format(
      'ddd, D MMM YYYY HH:mm:ss z');
  }.property('model.taken_at')
});

Ember.Handlebars.helper('truncate', function (text, length) {
  if (text.length < length) {
    return text;
  }

  return text.slice(0, length).replace(/\s+$/, '') + '...';
});
