do (o=(if module? then module.exports={} else window)) ->
  _STR_THT = "tinyHtmlTemplate"

  ###
    List of standard tags.
  ###
  TAGS = "a,abbr,address,area,article,aside,audio,b,base,bdi,bdo,blockquote,body,br,button,canvas,caption,cite,code,col,colgroup,command,datalist,dd,del,details,dfn,div,dl,dt,em,embed,fieldset,figcaption,figure,footer,form,h1,h2,h3,h4,h5,h6,head,header,hgroup,hr,html,i,iframe,img,input,ins,kbd,keygen,label,legend,li,link,map,mark,menu,meta,meter,nav,noscript,object,ol,optgroup,option,output,p,param,pre,progress,q,rp,rt,ruby,s,samp,script,section,select,small,source,span,strong,style,sub,summary,sup,table,tbody,td,textarea,tfoot,th,thead,time,title,tr,track,u,ul,var,video,wbr".split(",")

  ###
    Helper for minification. DRY.
  ###
  _STR_STRING = 'string'
  _STR_FUNCTION = 'function'
  _STR_ERROR = "error"

  ###
    Methods for debug.
  ###
  dc = [] #Debug context stack.

  # Better once minifed. No perf cost.
  [ consoleGroup = console.groupCollapsed,
    consoleGroupEnd = console.groupEnd
    consoleError = console[_STR_ERROR] ].map((x) -> x.bind(console))
  # Better once minifed in the cost of slight performance
  _is = (o,x) -> typeof(o) is x

  # Stack Push/pop
  pushdc = (tag) -> dc.push(tag)
  popdc = -> dc.pop()

  # Show console debug context
  showdc = ->
    debugPrint = ->
      tabs = ""
      for x in dc
        tabs += " "
        consoleError(">#{tabs}%O",x)

    m="#{_STR_THT}#{_STR_ERROR}"
    if consoleGroup
      consoleGroup("%c#{m}")
      debugPrint()
      consoleGroupEnd()
    else
      consoleError(m)
      debugPrint()

  # Generate a tag type function
  createTagFunction = (tagName) ->
    (args...) ->
      @tag.apply(this, [tagName].concat(args))

  # Generate a subTemplate type function
  createSubTemplate = (name, partial) ->
    (args...) ->
      pushdc(name)
      partial.apply(this, args)
      popdc()

  # Applying fields recursively (good for HTMLElement#style)
  setFields = (ctx, hash) ->
    for k,v of hash
      if _is(v,"object")
        setFields(ctx[k], v)
      else
        ctx[k] = v

  # The inglorious bastard
  class HTML_DSL
    constructor: (elm) ->
      @_e = elm #Element related to this DSL. can be null!
      @_c = [] #array of children

    #AppendTo
    ato: (elm) ->
      for x in @_c
        elm.appendChild(x)

    on: (event, cb) ->
      @_e.addEventListener(event, cb)

    text: (x) ->
      @_c.push document.createTextNode(x)

    tag: (tagName, properties = {}, cb ) ->
      if not cb and _is(properties, _STR_FUNCTION)
        cb = properties
        properties = {}

      if _is(properties, _STR_STRING)
        properties = { innerText: properties }

      cElm = document.createElement(tagName)

      setFields(cElm, properties)

      @_c.push(cElm)

      if _is(text=cb, _STR_STRING)
        cb = -> @text(text)

      if cb
        unless _is(cb, _STR_FUNCTION)
          throw new Error("Callback isn't #{_STR_FUNCTION}")
        dsl = new HTML_DSL(cElm)
        pushdc( cElm  )
        cb.call(dsl)
        dsl.ato(dsl._e)
        popdc(tagName)

  for tag in TAGS
    HTML_DSL::[tag] = createTagFunction(tag)

  HTML =
    register: (name, cb) ->
      HTML_DSL::[name] = createSubTemplate(name, cb)

    render: (elm, cb) ->
      try
        pushdc("#render")
        if not cb and _is(elm, _STR_FUNCTION)
          cb = elm
          elm = null

        if elm
          dsl = new HTML_DSL
          cb.call dsl
          dsl.ato(elm)
          return elm
        else
          dsl = new HTML_DSL
          cb.call dsl
          return dsl
        popdc()
      catch e
        showdc()
        throw e;

  o[_STR_THT] = HTML;