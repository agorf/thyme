window.App = Ember.Application.create({
  LOG_TRANSITIONS: true
});

App.JsonTransform = DS.Transform.extend({
  serialize: function (data) {
    return JSON.stringify(data);
  },
  deserialize: function (data) {
    return data;
  }
});

App.Set = DS.Model.extend({
  name: DS.attr('string'),
  takenAt: DS.attr('date'),
  photos: DS.hasMany('photo')
});

App.Photo = DS.Model.extend({
  path: DS.attr('string'),
  size: DS.attr('number'),
  width: DS.attr('number'),
  height: DS.attr('number'),
  takenAt: DS.attr('date'),
  exif: DS.attr('json'),
  bigThumbUrl: DS.attr('string'),
  smallThumbUrl: DS.attr('string'),
  set: DS.belongsTo('set')
});

App.Router.map(function () {
  this.resource('sets', { path: '/' }, function () {
    this.resource('set', { path: '/set/:set_id' }, function () {
      this.resource('photo', { path: '/photo/:photo_id' });
    });
  });
});

App.SetsRoute = Ember.Route.extend({
  model: function () {
    return this.store.find('set');
  }
});

App.SetRoute = Ember.Route.extend({
  model: function (params) {
    return this.store.find('set', params.set_id);
  }
});

App.PhotoRoute = Ember.Route.extend({
  model: function (params) {
    return this.store.find('photo', params.photo_id);
  }
});

App.SetController = Ember.ObjectController.extend({
  photosCount: function () {
    return this.get('model.photos.length');
  }.property('model.photos.length'),
  photosCountTitle: function () {
    var n = this.get('photosCount');
    return (n === 1) ? '1 photo' : n + ' photos';
  }.property('photosCount'),
  thumbUrl: function () {
    return this.get('model.photos.firstObject.smallThumbUrl');
  }.property('model.photos.firstObject.smallThumbUrl')
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

// http://mavilein.github.io/javascript/2013/08/01/Ember-JS-After-Render-Event/
Ember.View.reopen({
  didInsertElement: function () {
    this._super();
    Ember.run.scheduleOnce('afterRender', this, this.afterRenderEvent);
  },
  afterRenderEvent: function () {}
});

App.ThumbsView = Ember.View.extend({
  scrollToActive: function (container) {
    var $container = Ember.$(container);
    var $target = $container.find('.active');

    if ($target.length) {
      if ($target.prev().length) {
        $target = $target.prev();
      }

      $container.scrollTop(
        $target.offset().top - $container.offset().top + $container.scrollTop()
      );
    }
  }
});

App.SetView = App.ThumbsView.extend({
  afterRenderEvent: function () {
    this.scrollToActive('#sets');
  }
});

App.PhotoView = App.ThumbsView.extend({
  afterRenderEvent: function () {
    this.scrollToActive('#photos');
  }
});

Ember.Handlebars.helper('truncate', function (text, length) {
  if (text.length < length) {
    return text;
  }

  return text.slice(0, length).replace(/\s+$/, '') + '...';
});
