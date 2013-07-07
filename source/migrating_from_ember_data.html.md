---
title: "Migrating from Ember Data to EPF"
layout: resource
---

# Migrating from Ember Data

Epf was built by people who have extensive Ember Data experience. Many of the API's and conventions are heavily inspired by Ember Data if not directly based.

## Models

Unlike Ember Data, there is no state machine backing each model. This means there will be no more [pesky error messages](https://github.com/emberjs/data/issues/1024) related to `willCommit`.

A loose analogy is that Epf uses an MVCC write system while Ember Data uses locks. In Epf **you can modify models and their relationships any time.** This includes while models are in transit to the server. Moreover, multiple instance of the same logical model can exist at the same time. This is premise behind Epf's merging and isolation logic.

Defining models in Epf is almost 1-1 with Ember Data. Porting over model definitions is as simple as changing the namespace:

```javascript
App.Post = DS.Model.extend({
  title: DS.attr('string'),
  body: DS.attr('string'),

  comments: DS.hasMany(App.Comment),
  user: DS.belongsTo(App.User)
});
```

becomes:

```javascript
App.Post = Ep.Model.extend({
  title: Ep.attr('string'),
  body: Ep.attr('string'),

  comments: Ep.hasMany(App.Comment),
  user: Ep.belongsTo(App.User)
});
```

## REST Backends

The default conventions around the expect JSON format (including sideloading etc.) is a superset of what Ember Data expects. If you are currently using Ember Data **your existing backend should require little to no modification.**

## What About the Store and Transactions?

There is currently no store in Epf. The closest construct are sessions. Sessions are the primary means of interacting with Epf and, in practice, many of it's methods correspond to methods on the store. See the table in the next section for more detail.

Transactions in Ember Data are an extremely overloaded concept. In practice, transactions in Ember Data do not provide any transactional guarantees and are simply used to group operations. Instead of transactions, Epf has the notion of *child sessions*.

Child sessions can be used to fork records and achieve change isolation. Below are two rough comparison code samples:

```javascript
var transaction = store.transaction();
transaction.add(post);
post.tite = 'new title';
transaction.commit();
```

Versus:

```javascript
var childSession = session.newSession();
var childPost = session.add(post);
childPost.title = 'new title';
childSession.flush();
```

Unlike transactions, child sessions can be flushed multiple times and have robust ways of handling errors.

## Table of Functional Equivalence

Below is a rudimentary mapping of some Epf methods, their intended use, and the closest corresponding Ember Data equivalent:


<table class="mappings">
<tr>
<th>Epf Code</th>
<th>Use Case</th>
<th>Ember Data Equivalent</th>
</tr>


<tr>
<td><pre>session.load()
session.find()</pre></td>
<td>Loads a single model from the server.</td>
<td><pre>store.find()</pre></td>
</tr>


<tr>
<td><pre>session.query()</pre></td>
<td>Loads a collection of models from the server based on a query.</td>
<td><pre>store.findQuery()</pre></td>
</tr>


<tr>
<td><pre>session.flush()</pre></td>
<td>Persists all pending changes to the server.</td>
<td><pre>store.commit()
transaction.commit()</pre></td>
</tr>


<tr>
<td><pre>session.newSession()</pre></td>
<td>Creates a child session.</td>
<td><pre>store.transaction()</pre></td>
</tr>


<tr>
<td><pre>session.add()</pre></td>
<td>Adds a model to a session.</td>
<td><pre>transaction.add()</pre></td>
</tr>


<tr>
<td><pre>session.create()</pre></td>
<td>Creates a model inside the session.</td>
<td><pre>store.createRecord()</pre></td>
</tr>


<tr>
<td><pre>session.deleteModel()</pre></td>
<td>Deletes and removes a model from the session.</td>
<td><pre>store.deleteRecord()
model.deleteRecord()</pre></td>
</tr>


<tr>
<td><pre>session.remoteCall()</pre></td>
<td>Calls a remote method on the server</td>
<td>N/A</td>
</tr>


<tr>
<td><pre>session.merge()</pre></td>
<td>Merges in data from the server.</td>
<td><pre>store.load()</pre></td>
</tr>


<tr>
<td><pre>session.refresh()</pre></td>
<td>Reloads data from the server and updates the model.</td>
<td><pre>store.reloadModel()</pre></td>
</tr>




</table>