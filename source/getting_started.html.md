---
title: "Getting Started with EPF"
layout: resource
---

# Getting Started

## Installation

Download the latest version of Epf and insert into the webpage after Ember.js:

```html
<script type="text/javascript" src="ember.js"></script>
<script type="text/javascript" src="epf.js"></script>
```

Epf is also available via [npm](https://npmjs.org/package/epf).

## Overview

Before getting started, it is helpful to understand how Epf aligns with the rest of the Ember.js ecosystem. If you have spent any time reading the [Ember.js guides](http://emberjs.com/guides/models/), you are undoubtedly aware of [Ember Data](https://github.com/emberjs/data). For all intensive purposes, Epf is a full alternative to Ember Data. To assist in translating any of the guides to Epf, see the [migrating from Ember Data](migrating_from_ember_data.html) section.

Epf is essentially an [ORM](https://en.wikipedia.org/wiki/Object-relational_mapping) for the web and gives you all the tools necessary to define models and synchronize with your backend. Unlike other solutions, Epf is built around strong primitives for keeping your app in sync with the server. Currently, the focus of Epf is on REST backends, but out of the box support for streaming technologies is on the roadmap.

### Defining Models

All models within Epf are subclasses of `Ep.Model`. For example:

```javascript
App.Post = Ep.Model.extend({
  title: Ep.attr('string'),
  body: Ep.attr('string'),

  comments: Ep.hasMany(App.Comment),
  user: Ep.belongsTo(App.User)
});
```

### Loading Data

Similarly to Ember Data, model classes have a `find` method:

```javascript
App.PostRoute = Ember.Route.extend({
  
  model: function(params) {
    return App.Post.find(params.post_id);
  }

});
```

In general, however, it is discouraged to interact directly with the models and their classes. Instead, the primary means of interacting with Epf is through a `session`. Epf automatically injects a primary session into all routes and controllers. Using a session, the above code is functionally equivalent to:

```javascript
App.PostRoute = Ember.Route.extend({
  
  model: function(params) {
    return this.session.load('post', params.post_id);
  }

});
```

By default, Ember.js will automatically call the `find` method, so the above route can actually be simplified to:

```javascript
App.PostRoute = Ember.Route.extend({
  // no model method required, Ember.js will automatically call `find` on `App.Post`
});
```

The session object also has other methods for finding data such as `query`.

### Mutating Models

To mutate models, simply modify their properties:

```javascript
post.title = 'updated title';
```

To persist changes to the backend, simply call the `flush` method on the session object.

```javascript
post.title = 'updated title';
session.flush();
```

In Epf, most things are promises. In the above example you could listen for when the flush has completed using the promise API:


```javascript
post.title = 'updated title';
session.flush().then(function(models) {
  // this will be reached if the flush is successful
}, function(models) {
  // this will be reached only if there are errors
});
```

### Handling Errors

Sessions can be flushed at any point (even if other flushes are pending) and re-trying errors is as simple as performing another flush:

```javascript
post.title = 'updated title';
session.flush().then(null, function() {
  // the reject promise callback will be invoked on error
});

// do something here that should correct the error (e.g. fix validations)

session.flush(); // flush again
```

Models also have an `errors` property which will be populated when the backend returns errors.

### Transactional Semantics and Forked Records

Changes can be isolated easily using child sessions:

```javascript
var post = session.load(App.Post, 1);

var childSession = session.newSession(); // this creates a "child" session

var childPost = childSession.load(App.Post, 1); // this record instance is separate from its corresponding instance in the parent session

post === childPost; // returns false, they are separate instances
post.isEqual(childPost); // this will return true

childPost.title = 'something'; // this will not affect `post`

childSession.flush(); // this will flush changes both to the backend and the parent session, at this point `post` will have its title updated to reflect `childPost`
```





