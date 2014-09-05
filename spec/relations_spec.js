// Generated by CoffeeScript 1.7.1
var Base, Component, Project, Room, Source, Zone,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Base = (function(_super) {
  __extends(Base, _super);

  function Base() {
    return Base.__super__.constructor.apply(this, arguments);
  }

  Base.prototype.toString = function() {
    return "" + this.constructor.prototype.__name__ + ":" + this.id;
  };

  return Base;

})(RelationalModel);

Project = (function(_super) {
  __extends(Project, _super);

  function Project() {
    return Project.__super__.constructor.apply(this, arguments);
  }

  Project.registerModel('Project');

  Project.many('rooms', 'Room', {
    embeds: true,
    inverse: 'project'
  });

  Project.many('zones', 'Zone', {
    embeds: true,
    inverse: 'project'
  });

  Project.many('components', 'Component', {
    embeds: true,
    inverse: 'project'
  });

  Project.many('sources', 'Source', {
    through: 'components',
    inverse: 'project'
  });

  return Project;

})(RelationalModel);

Room = (function(_super) {
  __extends(Room, _super);

  function Room() {
    return Room.__super__.constructor.apply(this, arguments);
  }

  Room.registerModel('Room');

  Room.one('project', 'Project', {
    embedded: true,
    inverse: 'rooms'
  });

  Room.many('zones', 'Zone', {
    through: 'project',
    inverse: 'rooms'
  });

  Room.many('sources', 'Source', {
    through: 'zones',
    inverse: 'rooms'
  });

  return Room;

})(RelationalModel);

Zone = (function(_super) {
  __extends(Zone, _super);

  function Zone() {
    return Zone.__super__.constructor.apply(this, arguments);
  }

  Zone.registerModel('Zone');

  Zone.one('project', 'Project', {
    embedded: true,
    inverse: 'zones'
  });

  Zone.many('rooms', 'Room', {
    through: 'project',
    inverse: 'zones'
  });

  Zone.many('sources', 'Source', {
    through: 'project',
    inverse: 'zones'
  });

  return Zone;

})(RelationalModel);

Component = (function(_super) {
  __extends(Component, _super);

  function Component() {
    return Component.__super__.constructor.apply(this, arguments);
  }

  Component.registerModel('Component');

  Component.one('project', 'Project', {
    embedded: true,
    inverse: 'components'
  });

  Component.many('sources', 'Source', {
    embeds: true,
    inverse: 'component'
  });

  return Component;

})(RelationalModel);

Source = (function(_super) {
  __extends(Source, _super);

  function Source() {
    return Source.__super__.constructor.apply(this, arguments);
  }

  Source.registerModel('Source');

  Source.one('component', 'Component', {
    embedded: true,
    inverse: 'sources'
  });

  Source.one('project', 'Project', {
    through: 'component',
    inverse: 'sources'
  });

  Source.many('zones', 'Zone', {
    through: 'project',
    inverse: 'sources'
  });

  Source.many('rooms', 'Room', {
    through: 'zones',
    inverse: 'sources'
  });

  return Source;

})(RelationalModel);

describe('RelationalModel', function() {
  it('is defined', function() {
    return expect(RelationalModel).toBeDefined();
  });
  it('records class names', function() {
    expect(new Project().__name__).toEqual('Project');
    expect(new Room().__name__).toEqual('Room');
    return expect(new Zone().__name__).toEqual('Zone');
  });
  return it('references class constructors', function() {
    expect(new Project().models['Project']).toEqual(Project);
    expect(new Project().models['Room']).toEqual(Room);
    return expect(new Project().models['Zone']).toEqual(Zone);
  });
});

describe('Project', function() {
  var project;
  project = null;
  beforeEach(function() {
    return project = new Project({
      name: 'White House',
      linked: {
        rooms: [
          {
            name: 'Oval Office',
            id: 'oval-office',
            links: {
              zones: ['oval-office-video', 'oval-office-audio']
            }
          }
        ],
        zones: [
          {
            name: 'Oval Office Video',
            id: 'oval-office-video',
            links: {
              rooms: ['oval-office']
            }
          }, {
            name: 'Oval Office Audio',
            id: 'oval-office-audio',
            links: {
              rooms: ['oval-office']
            }
          }
        ],
        components: [
          {
            name: 'DirecTV HR-24',
            id: 'directv-hr-24',
            linked: {
              sources: [
                {
                  name: 'DirecTV',
                  id: 'directv',
                  links: {
                    zones: ['oval-office-video']
                  }
                }
              ]
            }
          }
        ]
      }
    });
  });
  it('has a name', function() {
    return expect(project.get('name')).toEqual('White House');
  });
  describe('rooms', function() {
    it('create a collection', function() {
      var rooms;
      rooms = project.get('rooms');
      expect(rooms).toEqual(jasmine.any(Backbone.Collection));
      expect(rooms.length).toEqual(1);
      return expect(rooms.first()).toEqual(jasmine.any(Room));
    });
    it('instantiate lazily', function() {
      var rooms;
      expect(project._rooms).toBeUndefined();
      rooms = project.get('rooms');
      return expect(project._rooms).toBeDefined();
    });
    it('embed within project', function() {
      var room, rooms;
      rooms = project.get('rooms');
      room = rooms.first();
      return expect(room.get('project')).toBe(project);
    });
    it('link to zones through project', function() {
      var room, rooms, zones;
      rooms = project.get('rooms');
      room = rooms.first();
      zones = room.get('zones');
      return expect(zones).toBe(project.get('zones'));
    });
    it('link to sources through zones', function() {
      var room, rooms, sources;
      rooms = project.get('rooms');
      room = rooms.first();
      sources = room.get('sources');
      return expect(sources.length).toEqual(1);
    });
    return it('updates sources through zones', function() {
      var room, rooms, source, sources, zone, zones;
      rooms = project.get('rooms');
      room = rooms.first();
      sources = room.get('sources');
      expect(sources.length).toEqual(1);
      zones = room.get('zones');
      zone = zones.first();
      source = new Source;
      zone.get('sources').add(source);
      expect(sources.length).toEqual(2);
      zone.get('sources').remove(source);
      return expect(sources.length).toEqual(1);
    });
  });
  return describe('zones', function() {
    it('create a collection', function() {
      var zones;
      zones = project.get('zones');
      expect(zones).toEqual(jasmine.any(Backbone.Collection));
      expect(zones.length).toEqual(2);
      return expect(zones.first()).toEqual(jasmine.any(Zone));
    });
    it('instantiate lazily', function() {
      var zones;
      expect(project._zones).toBeUndefined();
      zones = project.get('zones');
      return expect(project._zones).toBeDefined();
    });
    it('embed within project', function() {
      var zone, zones;
      zones = project.get('zones');
      zone = zones.first();
      return expect(zone.get('project')).toBe(project);
    });
    return it('link to rooms through project', function() {
      var rooms, zone, zones;
      zones = project.get('zones');
      zone = zones.first();
      rooms = zone.get('rooms');
      return expect(rooms).toBe(project.get('rooms'));
    });
  });
});

describe('Room', function() {
  return describe('instantiated directly', function() {
    var room;
    room = null;
    it('creates without error', function() {
      return expect(function() {
        return new Room({
          id: 'instantiated-directly'
        });
      }).not.toThrow();
    });
    return it('raises an error upon getting project', function() {
      room = new Room({
        id: 'instantiated-directly'
      });
      return expect(function() {
        return room.get('project');
      }).toThrow();
    });
  });
});

describe('Zone', function() {
  return describe('instantiated directly', function() {
    var zone;
    zone = null;
    it('creates without error', function() {
      return expect(function() {
        return new Zone({
          id: 'instantiated-directly'
        });
      }).not.toThrow();
    });
    return it('raises an error upon getting project', function() {
      zone = new Zone({
        id: 'instantiated-directly'
      });
      return expect(function() {
        return zone.get('project');
      }).toThrow();
    });
  });
});
