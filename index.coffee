scope = if module? then module.exports={}; module.exports  else window
do(scope) ->
  TAGS =[ "a", "abbr","address","area","article","aside","audio","b","base","bdi",
  "bdo","blockquote","body","br","button","canvas","caption","cite","code","col",
  "colgroup","command","datalist","dd","del","details","dfn","div","dl","dt","em",
  "embed","fieldset","figcaption","figure","footer","form","h1","h2","h3","h4",
  "h5","h6","head","header","hgroup","hr","html","i","iframe","img","input","ins",
  "kbd","keygen","label","legend","li","link","map","mark","menu","meta","meter",
  "nav","noscript","object","ol","optgroup","option","output","p","param","pre",
  "progress","q","rp","rt","ruby","s","samp","script","section","select","small",
  "source","span","strong","style","sub","summary","sup","table","tbody","td",
  "textarea","tfoot","th","thead","time","title","tr","track","u","ul","var",
  "video","wbr"]

  createTagFunction = (tagName) ->
    (args...) ->
      @tag.apply(this, [tagName].concat(args))

  createPartialFunction = (partial) ->
    (args...) ->
      partial.apply(this, args)

  setFields = (ctx, hash) ->
    for k,v of hash
      if typeof(v) is "object"
        setFields(ctx[k], v)
      else
        ctx[k] = v

  class HTML_DSL
    constructor: (elm) ->
      @_element = elm
      @_children = []

    appendTo: (elm) ->
      for x in @_children
        elm.appendChild(x)

    appendToItself: ->
      @appendTo(@_element)

    on: (event, cb) ->
      @_element.addEventListener(event, cb)

    text: (x) ->
      @_children.push document.createTextNode(x)

    tag: (tagName, properties = {}, cb ) ->
      if not cb? and typeof(properties) is 'function'
        cb = properties
        properties = {}

      if typeof(properties) is 'string'
        properties = { innerText: properties }

      cElm = document.createElement(tagName)

      setFields(cElm, properties)

      @_children.push(cElm)

      if typeof(cb) is "string"
        do(text=cb) ->
          cb = -> @text(text)

      if cb
        unless typeof(cb) is 'function'
          throw new Error("This is not a function => #{cb}")
        dsl = new HTML_DSL(cElm)
        HTML.pushdc( cElm  )
        cb.call(dsl)
        dsl.appendToItself()
        HTML.popdc(tagName)

  for tag in TAGS
    HTML_DSL::[tag] = createTagFunction(tag)

  dc = [] #Debug context
  HTML =
    register: (name, cb) ->
      HTML_DSL::[name] = createPartialFunction(cb)

    render: (elm, cb) ->
      try
        HTML.pushdc("#render")
        if not cb? and typeof(elm) is "function"
          cb = elm
          elm = null

        if elm
          dsl = new HTML_DSL()
          cb.call(dsl)
          dsl.appendTo(elm)
          return elm
        else
          dsl = new HTML_DSL()
          cb.call(dsl)
          return dsl
        HTML.popdc()
      catch e
        HTML.showdc()
        throw e;

    pushdc: (tag) -> dc.push(tag)
    popdc: -> dc.pop()
    showdc: ->
      if console.groupCollapsed?
        console.groupCollapsed("%c tinyHtmlTemplate error!","font-style: italic; color: red; background-color: white;")
        tabs = ""
        for x in dc
          tabs += " "
          console.error(">#{tabs}%O",x)
        console.groupEnd()
      else
        console.error("tinyHtmlTemplate error!")
        tabs = ""
        for x in dc
          tabs += " "
          console.error(">#{tabs}",x)

      #console.error("Stopped at <i>#{dc.join(" > ")}</i>")

  scope.tinyHtmlTemplate = HTML