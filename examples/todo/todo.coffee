Template = tinyHtmlTemplate

_uid = 1
nextUID = ->
  _uid+=1

todos = [
  {name: "Test Tiny HTML Template", id: 1, done: no}
]

Controller = {
  create: (text) ->
    todos.push { name: text, id:nextUID() , done: no }
    View.render()
  delete: (todo) ->
    for x, idx in todos when x.id is todo.id
      todos.splice(idx, 1)
      View.render()
      break
  toggleDone: (todo, value) ->
    todo.done = value
}

View =
  render: ->
    todoList = document.getElementById("todo-list")
    todoList.removeChild(todoList.firstChild) while (todoList.firstChild)
    Template.render(todoList, -> @TodoListView(todos) )

Template.register "TodoListView", (todoList) ->
  @div id: "todo-list-component", ->
    @ul className="todo-list", ->
      for todo in todoList
        @TodoView(todo)

Template.register "TodoView", (record) ->
  @div className: "record", ->
    @input type: "checkbox", id: "todo_#{record.id}", checked: record.done, ->
      @on 'change', (evt) ->
        Controller.toggleDone(record, evt.value)

    @label htmlFor: "todo_#{record.id}", record.name

View.render()