# TODO: move example classes to separate files
class Base extends RelationalModel
  toString: ->
    "#{@constructor::__name__}:#{@id}"

class Project extends RelationalModel
  @registerModel('Project')

  @many 'rooms', 'Room', { embeds: true, inverse: 'project' }
  @many 'zones', 'Zone', { embeds: true, inverse: 'project' }
  @many 'components', 'Component', { embeds: true, inverse: 'project' }
  @many 'sources', 'Source', { through: 'components', inverse: 'project' }

class Room extends RelationalModel
  @registerModel('Room')

  @one 'project', 'Project', { embedded: true, inverse: 'rooms' }
  @many 'zones', 'Zone', { through: 'project', inverse: 'rooms' }
  @many 'sources', 'Source', { through: 'zones', inverse: 'rooms' }

class Zone extends RelationalModel
  @registerModel('Zone')

  @one 'project', 'Project', { embedded: true, inverse: 'zones' }
  @many 'rooms', 'Room', { through: 'project', inverse: 'zones' }
  @many 'sources', 'Source', { through: 'project', inverse: 'zones' }

class Component extends RelationalModel
  @registerModel('Component')

  @one 'project', 'Project', { embedded: true, inverse: 'components' }
  @many 'sources', 'Source', { embeds: true, inverse: 'component' }

class Source extends RelationalModel
  @registerModel('Source')

  @one 'component', 'Component', { embedded: true, inverse: 'sources' }
  @one 'project', 'Project', { through: 'component', inverse: 'sources' }
  @many 'zones', 'Zone', { through: 'project', inverse: 'sources' }
  @many 'rooms', 'Room', { through: 'zones', inverse: 'sources' }


describe 'RelationalModel', ->
  it 'is defined', ->
    expect(RelationalModel).toBeDefined()

  it 'records class names', ->
    expect(new Project().__name__).toEqual('Project')
    expect(new Room().__name__).toEqual('Room')
    expect(new Zone().__name__).toEqual('Zone')

  it 'references class constructors', ->
    expect(new Project().models['Project']).toEqual(Project)
    expect(new Project().models['Room']).toEqual(Room)
    expect(new Project().models['Zone']).toEqual(Zone)

describe 'Project', ->
  project = null

  beforeEach ->
    project = new Project
      name: 'White House'
      linked:
        rooms: [
          name: 'Oval Office'
          id: 'oval-office'
          links:
            zones: ['oval-office-video', 'oval-office-audio']
        ]
        zones: [
          name: 'Oval Office Video'
          id: 'oval-office-video'
          links:
            rooms: ['oval-office']
        ,
          name: 'Oval Office Audio'
          id: 'oval-office-audio'
          links:
            rooms: ['oval-office']
        ]
        components: [
          name: 'DirecTV HR-24'
          id: 'directv-hr-24'
          linked:
            sources: [
              name: 'DirecTV'
              id: 'directv'
              links:
                zones: ['oval-office-video']
            ]
        ]

  it 'has a name', ->
    expect(project.get 'name').toEqual('White House')

  describe 'rooms', ->
    it 'create a collection', ->
      rooms = project.get 'rooms'

      expect(rooms).toEqual(jasmine.any Backbone.Collection)
      expect(rooms.length).toEqual(1)
      expect(rooms.first()).toEqual(jasmine.any Room)

    it 'instantiate lazily', ->
      expect(project._rooms).toBeUndefined()

      rooms = project.get 'rooms'

      expect(project._rooms).toBeDefined()

    it 'embed within project', ->
      rooms = project.get 'rooms'
      room  = rooms.first()

      expect(room.get 'project').toBe(project)

    it 'link to zones through project', ->
      rooms = project.get 'rooms'
      room  = rooms.first()
      zones = room.get 'zones'

      expect(zones).toBe(project.get 'zones')

    it 'link to sources through zones', ->
      rooms = project.get 'rooms'
      room  = rooms.first()
      sources = room.get 'sources'

      expect(sources.length).toEqual(1)

    it 'updates sources through zones', ->
      rooms = project.get 'rooms'
      room  = rooms.first()
      sources = room.get 'sources'

      expect(sources.length).toEqual(1)

      zones = room.get 'zones'
      zone  = zones.first()
      source = new Source
      zone.get('sources').add source # TODO: fix project embedding through assignment

      expect(sources.length).toEqual(2)

      zone.get('sources').remove source

      expect(sources.length).toEqual(1)

  describe 'zones', ->
    it 'create a collection', ->
      zones = project.get 'zones'

      expect(zones).toEqual(jasmine.any Backbone.Collection)
      expect(zones.length).toEqual(2)
      expect(zones.first()).toEqual(jasmine.any Zone)

    it 'instantiate lazily', ->
      expect(project._zones).toBeUndefined()

      zones = project.get 'zones'

      expect(project._zones).toBeDefined()

    it 'embed within project', ->
      zones = project.get 'zones'
      zone  = zones.first()

      expect(zone.get 'project').toBe(project)

    it 'link to rooms through project', ->
      zones = project.get 'zones'
      zone  = zones.first()
      rooms = zone.get 'rooms'

      expect(rooms).toBe(project.get 'rooms')

describe 'Room', ->
  describe 'instantiated directly', ->
    room = null

    it 'creates without error', ->
      expect(-> new Room id: 'instantiated-directly').not.toThrow()

    it 'raises an error upon getting project', ->
      room = new Room id: 'instantiated-directly'

      expect(-> room.get('project')).toThrow()

describe 'Zone', ->
  describe 'instantiated directly', ->
    zone = null

    it 'creates without error', ->
      expect(-> new Zone id: 'instantiated-directly').not.toThrow()

    it 'raises an error upon getting project', ->
      zone = new Zone id: 'instantiated-directly'

      expect(-> zone.get('project')).toThrow()
