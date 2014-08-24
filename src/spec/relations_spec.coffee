describe 'RelationalModel', ->
  it 'should be defined', ->
    expect(RelationalModel).toBeDefined()

  it 'should record class names', ->
    class Project extends RelationalModel
      @registerModel('Project')

      @many 'rooms', 'Room', { embedded: true }

    class Room extends RelationalModel
      @registerModel('Room')

      @many 'projects', 'Project', { embedded: true }

    console.log "Project.models = #{name for name of new Project().models}"
    console.log "Room.models = #{name for name of new Room().models}"
