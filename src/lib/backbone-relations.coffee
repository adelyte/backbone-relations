do (root = this, factory = (exports, Backbone, _) ->

  class RelationalModel extends Backbone.Model

  exports.RelationalModel = RelationalModel

  ) ->
  if (define?.amd)
    define ['exports', 'backbone', 'underscore'], factory
  else if (exports?)
    factory exports, require('backbone'), require('underscore')
  else
    factory root, root.Backbone, root._
