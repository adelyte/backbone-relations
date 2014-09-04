# TODO: move example classes to separate files
class Project extends RelationalModel
  @registerModel('Project')

  @many 'rooms', 'Room', { embeds: true, inverse: 'project' }
  @many 'zones', 'Zone', { embeds: true, inverse: 'project' }

  toString: ->
    "#{@constructor::__name__}:#{@id}"

class Room extends RelationalModel
  @registerModel('Room')

  @one 'project', 'Project', { embedded: true, inverse: 'rooms' }
  @many 'zones', 'Zone', { through: 'project', inverse: 'rooms' }

  toString: ->
    "#{@constructor::__name__}:#{@id}"

class Zone extends RelationalModel
  @registerModel('Zone')

  @one 'project', 'Project', { embedded: true, inverse: 'rooms' }
  @many 'rooms', 'Room', { through: 'project', inverse: 'zones' }

  toString: ->
    "#{@constructor::__name__}:#{@id}"


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
