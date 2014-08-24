// Generated by CoffeeScript 1.7.1
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

describe('RelationalModel', function() {
  it('is defined', function() {
    return expect(RelationalModel).toBeDefined();
  });
  return it('records class names', function() {
    var Project, Room, name;
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

      return Room;

    })(RelationalModel);
    expect(new Project().models['Project']).toEqual(Project);
    expect(new Project().models['Room']).toEqual(Room);
    console.log("Project.models = " + ((function() {
      var _results;
      _results = [];
      for (name in new Project().models) {
        _results.push(name);
      }
      return _results;
    })()));
    return console.log("Room.models = " + ((function() {
      var _results;
      _results = [];
      for (name in new Room().models) {
        _results.push(name);
      }
      return _results;
    })()));
  });
});
