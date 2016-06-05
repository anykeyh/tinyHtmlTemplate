Template = require("../index").tinyHtmlTemplate

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
  toggleDone: (todo) ->
    todo.done = !todo.done
    View.render()
}

View =
  render: ->
    Template.render(todoListElm, TodoListView(todos))

Template.register "TodoListView", (todoList) ->
  @div id: "todo-list-component", ->
    @ul className="todo-list", ->
      for todo in todoList
        @TodoView(todo)

Template.register "RecordView", (record) ->
  @div className: "record", ->
    @h2 "Data"
    @label "Name"
    @text record.name
    @h2 "Actions"
    @ul ->
      @li ->
        @a href: "/#{record.id}/edit", ->
          @text "Edit"
          @on "click", (evt) ->
            alert("TODO: Ajax call instead ! :)")
            evt.preventDefault()
      @li ->
        @a href: "/#{record.id}/delete", "Delete"

View.render()