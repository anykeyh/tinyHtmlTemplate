var Controller, Template, View, _uid, nextUID, todos;

Template = tinyHtmlTemplate;

_uid = 1;

nextUID = function() {
  return _uid += 1;
};

todos = [
  {
    name: "Test Tiny HTML Template",
    id: 1,
    done: false
  }
];

Controller = {
  create: function(text) {
    todos.push({
      name: text,
      id: nextUID(),
      done: false
    });
    return View.render();
  },
  "delete": function(todo) {
    var i, idx, len, results, x;
    results = [];
    for (idx = i = 0, len = todos.length; i < len; idx = ++i) {
      x = todos[idx];
      if (!(x.id === todo.id)) {
        continue;
      }
      todos.splice(idx, 1);
      View.render();
      break;
    }
    return results;
  },
  toggleDone: function(todo, value) {
    return todo.done = value;
  }
};

View = {
  render: function() {
    var todoList;
    todoList = document.getElementById("todo-list");
    while (todoList.firstChild) {
      todoList.removeChild(todoList.firstChild);
    }
    return Template.render(todoList, function() {
      return this.TodoListView(todos);
    });
  }
};

Template.register("TodoListView", function(todoList) {
  return this.div({
    id: "todo-list-component"
  }, function() {
    var className;
    return this.ul(className = "todo-list", function() {
      var i, len, results, todo;
      results = [];
      for (i = 0, len = todoList.length; i < len; i++) {
        todo = todoList[i];
        results.push(this.TodoView(todo));
      }
      return results;
    });
  });
});

Template.register("TodoView", function(record) {
  return this.div({
    className: "record"
  }, function() {
    this.input({
      type: "checkbox",
      id: "todo_" + record.id,
      checked: record.done
    }, function() {
      return this.on('change', function(evt) {
        return Controller.toggleDone(record, evt.value);
      });
    });
    return this.label({
      htmlFor: "todo_" + record.id
    }, record.name);
  });
});

View.render();
