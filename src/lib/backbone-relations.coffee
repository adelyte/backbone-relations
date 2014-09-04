do (root = this, factory = (exports, Backbone, _) ->

  class RelationalModel extends Backbone.Model
    @::models ?= {}

    @registerModel: (name) ->
      @::__name__ = name
      @::models[name] = this

    @_relational:
      define: (name, model, plural, options) ->
        @_associations ?= {}
        @_associations[name] =
          name: name
          plural: plural
          model: model
          embeds: options.embeds
          embedded: options.embedded
          through: options.through
          inverse: options.inverse

    @many: (name, model, options) ->
      # console.log "#{@::__name__} many #{name}, #{model}, options: #{JSON.stringify options}"

      @_relational.define.call this, name, model, true, options

      # TODO: add mechanism to force reload association
      @::mutators[name] = () ->
        return @["_#{name}"] if @["_#{name}"]

        definition = @constructor._associations[name]
        model = @constructor::models[definition.model]
        Collection = Backbone.Collection.extend model: model
        # console.log "#{@__name__} #{name} #{JSON.stringify definition}"

        switch
          when definition.embeds
            @["_#{name}"] = new Collection @get('linked')?[name]

            inverse = definition.inverse
            if model._associations[inverse] # TODO: consider deeper validation
              @["_#{name}"].each (member) ->
                member["_#{inverse}"] = this
              , this
            else
              throw "#{model::__name__} missing inverse association '#{inverse}'"

          when definition.through
            if model._associations[definition.through].plural
              @["_#{name}"] = new Collection
              @.get(definition.through).each (member) ->
                @["_#{name}"].add member.get(definition.source ? name)?.models
              , this
            else
              @["_#{name}"] = @.get(definition.through)?.get(definition.source ? name) # TODO: this is identical to a delegate

          else
            throw "many #{name} must be #embeds or #through"

        @["_#{name}"]

      @_associations[name]

    @one: (name, model, options) ->
      # console.log "#{@::__name__} one #{name}, #{model}, options: #{JSON.stringify options}"

      @_relational.define.call this, name, model, false, options

      @::mutators[name] = () ->
        return @["_#{name}"] if @["_#{name}"]

        definition = @constructor._associations[name]
        # console.log "#{@__name__} #{name} #{JSON.stringify definition}"

        data = switch
          when definition.embedded
            throw "#{this} must be instantiated from #{name}, eg #{name}.get('#{definition.inverse}')"
          else
            throw "#{@__name__} one #{name} must be #embeds"

      @_associations[name]

  exports.RelationalModel = RelationalModel
  return

) ->
  if (define?.amd)
    define ['exports', 'backbone', 'underscore'], factory
  else if (exports?)
    factory exports, require('backbone'), require('underscore')
  else
    factory root, root.Backbone, root._
