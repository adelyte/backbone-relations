do (root = this, factory = (exports, Backbone, _) ->

  class RelationalModel extends Backbone.Model
    @::models ?= {}

    @registerModel: (name) ->
      @::__name__ = name
      @::models[name] = this

    @many: (association, model, options) ->
      # console.log "many association: #{association}, model: #{model}, options: #{options}"
      # console.log "many @::models: #{name for name of @::models}, model: #{@::models[model]}"

  exports.RelationalModel = RelationalModel

  ) ->
  if (define?.amd)
    define ['exports', 'backbone', 'underscore'], factory
  else if (exports?)
    factory exports, require('backbone'), require('underscore')
  else
    factory root, root.Backbone, root._
