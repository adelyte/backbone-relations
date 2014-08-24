describe 'RelationalModel', ->
  it 'is defined', ->
    expect(RelationalModel).toBeDefined()

  it 'records class names', ->
    class Project extends RelationalModel
      @registerModel('Project')

      @many 'rooms', 'Room', { embeds: true, inverse: 'project' }

    class Room extends RelationalModel
      @registerModel('Room')

      @one 'project', 'Project', { embedded: true, inverse: 'rooms' }

    expect(new Project().models['Project']).toEqual(Project)
    expect(new Project().models['Room']).toEqual(Room)

    console.log "Project.models = #{name for name of new Project().models}"
    console.log "Room.models = #{name for name of new Room().models}"
