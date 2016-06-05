#tinyHtmlTemplate

This lib provide simple template through DSL like javascript declaration.

## What's the purpose of this lib?

With it you can create your DOM in a minute, bind events, and create partial
templates. If there's errors, you know where they are.

The lib is very small, and can suit for project where page loading speed matters
( mobile applications ). Memory footprint is really small also.

In terms of performance, it beats any parsed template and proceed almost the same
speed than native javascript.

## How to install?

Using browserify:

    $ npm install tinyHtmlTemplate --save


## How to use it?

tinyHtmlTemplate use a DSL-like structure and is very well suited for any language 
which simplify the syntax of the  context `this`.
This lib has been built first because I work with coffeescript. So it's very nice on it.
You can still use it on Javascript:

```javascript
  // Using browserify. Otherwise there's an object "window.tinyHtmlTemplate"
  var Template = require('tinyHtmlTemplate').tinyHtmlTemplate;

  // Render into the parent element. Can be anything.
  var parent = document.getElementById("theParent");

  Template.render(parent, function(){
    this.div({id: "template"},function(){
      this.text("Templating is so easy!");
      this.a({href: "#"}, function(){
        this.text("Click here to see binded event!");
        this.on("click", function(evt){
          alert("This is when I click the <a> element !");
        });
      })
      this.p("You can also write the content like this", function(){
        this.ul(function(){
          this.li(htmlContent: "You can set html<br><strong>like this</strong>")
          this.li(function(){
            this.text("Or like")
            this.br()
            this.text({style: { backgroundColor: "red", color: "white" }}, "that.");
          })
        })
      });
    })
  })

```

## Using partials

You can create subtemplates and call them easily:

```javascript
  Template.register('Important', function(text){
    this.strong("/!\" + text);
  } );

  Template.render(document.body, function(){
    this.Important("This is an important message!");
  })
```

Get a look to the `examples` folder for a ultra simple homemade MVC.