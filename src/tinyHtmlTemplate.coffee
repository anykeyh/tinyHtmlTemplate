###
  tinyHtmlTemplate.
  Because I needed it for a project. I tried to made it as small as possible.
###
do (o=(if module? then module.exports={} else window)) ->
  _STR_THT = "tinyHtmlTemplate"

  ###
    List of standard tags.
  ###
  TAGS = "a,abbr,address,area,article,aside,audio,b,base,bdi,bdo,blockquote,body,br,button,canvas,caption,cite,code,col,colgroup,command,datalist,dd,del,details,dfn,div,dl,dt,em,embed,fieldset,figcaption,figure,footer,form,h1,h2,h3,h4,h5,h6,head,header,hgroup,hr,html,i,iframe,img,input,ins,kbd,keygen,label,legend,li,link,map,mark,menu,meta,meter,nav,noscript,object,ol,optgroup,option,output,p,param,pre,progress,q,rp,rt,ruby,s,samp,script,section,select,small,source,span,strong,style,sub,summary,sup,table,tbody,td,textarea,tfoot,th,thead,time,title,tr,track,u,ul,var,video,wbr".split(",")

  ###
    Vars for minification.
  ###
  _STR_STRING = 'string'
  _STR_FUNCTION = 'function'
  _STR_ERROR = "error"
  _PROTOTYPE = "prototype"
  _PUSH = 'push'
  _OBJECT = 'object'
  # Document. Local var for minification
  _document = document
  _console = console

  # For the later arguments block
  _Array = Array
  _copy = _Array.from||_Array.slice
  _isArray = _Array.isArray

  ###
    Methods for debug.
  ###
  dc = [] #Debug context stack.

  # Better once minifed. No perf cost.
  [ consoleGroup = _console.groupCollapsed,
    consoleGroupEnd = _console.groupEnd
    consoleError = _console[_STR_ERROR] ].map((x) -> x.bind(_console))
  # Better once minifed in the cost of slight performance
  _is = (o,x) -> typeof(o) is x

  # Stack Push/pop
  pushDebugContext = (tag) -> dc[_PUSH](tag); return
  popDebugContext = -> dc.pop(); return

  # Show console debug context
  showdc = ->
    debugPrint = ->
      tabs = ""
      for x in dc
        tabs += " "
        consoleError(">#{tabs}%O",x)
      return

    m="#{_STR_THT}#{_STR_ERROR}"

    if consoleGroup
      consoleGroup("%c#{m}")
      debugPrint()
      consoleGroupEnd()
    else
      consoleError(m)
      debugPrint()
    return

  # Generate a tag type function
  createTagFunction = (tagName) ->
    ->
      @tag.apply this, [tagName].concat(_copy(arguments))

  # Generate a subTemplate type function
  createSubTemplate = (name, partial) ->
    ->
      pushDebugContext(name)
      partial.apply(this, arguments)
      popDebugContext()

  # Applying fields recursively (good for HTMLElement#style)
  setFields = (ctx, hash) ->
    for name,hashField of hash
      elmField=ctx[name]
      if _is(elmField, _OBJECT) and _is(hashField,_OBJECT) and not ( _isArray(elmField) || _isArray(hashField) )
        setFields(elmField, hashField)
      else
        ctx[name] = hashField

    return

  #AppendTo
  ato = (elm,c) -> elm.appendChild(x) for x in c; return

  # The inglorious bastard
  HTML_DSL = (elm) ->
    @$e = elm #Element related to this DSL. can be null!
    @$c = [] #array of children
    return

  HTML_DSL[_PROTOTYPE] = {
    on: (evt,cb) ->
      @$e.addEventListener(event, cb)
      return this
    text: (x) ->
      @$c[_PUSH] _document.createTextNode(x)
      return this
    tag: (tagName, properties, cb ) ->
      if not cb and _is(properties, _STR_FUNCTION)
        cb = properties
        properties = {}

      if _is(properties, _STR_STRING)
        properties = { innerText: properties }

      cElm = _document.createElement(tagName)

      setFields(cElm, properties)

      @$c[_PUSH](cElm)

      if _is(text=cb, _STR_STRING)
        cb = -> @text(text)

      if cb
        unless _is(cb, _STR_FUNCTION)
          throw new Error("should be #{_STR_FUNCTION}")
        dsl = new HTML_DSL(cElm)
        pushDebugContext( cElm  )
        cb.call(dsl)
        ato(dsl.$e, dsl.$c)
        popDebugContext(tagName)

      return this
  }

  for tag in TAGS
    HTML_DSL[_PROTOTYPE][tag] = createTagFunction(tag)

  HTML =
    register: (name, cb) ->
      HTML_DSL[_PROTOTYPE][name] = createSubTemplate(name, cb)
      return

    render: (elm, cb) ->
      try
        if not cb and _is(elm, _STR_FUNCTION)
          cb = elm
          elm = null

        pushDebugContext("#render")
        dsl = new HTML_DSL
        cb.call dsl
        popDebugContext()

        if elm
          ato(elm, dsl.$c)
          return elm
        return dsl
      catch e
        showdc()
        throw e;

  o[_STR_THT] = HTML;
  return