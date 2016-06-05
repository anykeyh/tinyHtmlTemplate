
/*
  tinyHtmlTemplate.
  Because I needed it for a project. I tried to made it as small as possible.
 */
(function(o) {
  var HTML, HTML_DSL, TAGS, _Array, _OBJECT, _PROTOTYPE, _PUSH, _STR_ERROR, _STR_FUNCTION, _STR_STRING, _STR_THT, _console, _copy, _document, _is, _isArray, ato, consoleError, consoleGroup, consoleGroupEnd, createSubTemplate, createTagFunction, dc, i, len, popDebugContext, pushDebugContext, setFields, showdc, tag;
  _STR_THT = "tinyHtmlTemplate";

  /*
    List of standard tags.
   */
  TAGS = "a,abbr,address,area,article,aside,audio,b,base,bdi,bdo,blockquote,body,br,button,canvas,caption,cite,code,col,colgroup,command,datalist,dd,del,details,dfn,div,dl,dt,em,embed,fieldset,figcaption,figure,footer,form,h1,h2,h3,h4,h5,h6,head,header,hgroup,hr,html,i,iframe,img,input,ins,kbd,keygen,label,legend,li,link,map,mark,menu,meta,meter,nav,noscript,object,ol,optgroup,option,output,p,param,pre,progress,q,rp,rt,ruby,s,samp,script,section,select,small,source,span,strong,style,sub,summary,sup,table,tbody,td,textarea,tfoot,th,thead,time,title,tr,track,u,ul,var,video,wbr".split(",");

  /*
    Vars for minification.
   */
  _STR_STRING = 'string';
  _STR_FUNCTION = 'function';
  _STR_ERROR = "error";
  _PROTOTYPE = "prototype";
  _PUSH = 'push';
  _OBJECT = 'object';
  _document = document;
  _console = console;
  _Array = Array;
  _copy = _Array.from || _Array.slice;
  _isArray = _Array.isArray;

  /*
    Methods for debug.
   */
  dc = [];
  [consoleGroup = _console.groupCollapsed, consoleGroupEnd = _console.groupEnd, consoleError = _console[_STR_ERROR]].map(function(x) {
    return x.bind(_console);
  });
  _is = function(o, x) {
    return typeof o === x;
  };
  pushDebugContext = function(tag) {
    dc[_PUSH](tag);
  };
  popDebugContext = function() {
    dc.pop();
  };
  showdc = function() {
    var debugPrint, m;
    debugPrint = function() {
      var i, len, tabs, x;
      tabs = "";
      for (i = 0, len = dc.length; i < len; i++) {
        x = dc[i];
        tabs += " ";
        consoleError(">" + tabs + "%O", x);
      }
    };
    m = "" + _STR_THT + _STR_ERROR;
    if (consoleGroup) {
      consoleGroup("%c" + m);
      debugPrint();
      consoleGroupEnd();
    } else {
      consoleError(m);
      debugPrint();
    }
  };
  createTagFunction = function(tagName) {
    return function() {
      return this.tag.apply(this, [tagName].concat(_copy(arguments)));
    };
  };
  createSubTemplate = function(name, partial) {
    return function() {
      pushDebugContext(name);
      partial.apply(this, arguments);
      return popDebugContext();
    };
  };
  setFields = function(ctx, hash) {
    var elmField, hashField, name;
    for (name in hash) {
      hashField = hash[name];
      elmField = ctx[name];
      if (_is(elmField, _OBJECT) && _is(hashField, _OBJECT) && !(_isArray(elmField) || _isArray(hashField))) {
        setFields(elmField, hashField);
      } else {
        ctx[name] = hashField;
      }
    }
  };
  ato = function(elm, c) {
    var i, len, x;
    for (i = 0, len = c.length; i < len; i++) {
      x = c[i];
      elm.appendChild(x);
    }
  };
  HTML_DSL = function(elm) {
    this.$e = elm;
    this.$c = [];
  };
  HTML_DSL[_PROTOTYPE] = {
    on: function(evt, cb) {
      this.$e.addEventListener(event, cb);
      return this;
    },
    text: function(x) {
      this.$c[_PUSH](_document.createTextNode(x));
      return this;
    },
    tag: function(tagName, properties, cb) {
      var cElm, dsl, text;
      if (!cb && _is(properties, _STR_FUNCTION)) {
        cb = properties;
        properties = {};
      }
      if (_is(properties, _STR_STRING)) {
        properties = {
          innerText: properties
        };
      }
      cElm = _document.createElement(tagName);
      setFields(cElm, properties);
      this.$c[_PUSH](cElm);
      if (_is(text = cb, _STR_STRING)) {
        cb = function() {
          return this.text(text);
        };
      }
      if (cb) {
        if (!_is(cb, _STR_FUNCTION)) {
          throw new Error("should be " + _STR_FUNCTION);
        }
        dsl = new HTML_DSL(cElm);
        pushDebugContext(cElm);
        cb.call(dsl);
        ato(dsl.$e, dsl.$c);
        popDebugContext(tagName);
      }
      return this;
    }
  };
  for (i = 0, len = TAGS.length; i < len; i++) {
    tag = TAGS[i];
    HTML_DSL[_PROTOTYPE][tag] = createTagFunction(tag);
  }
  HTML = {
    register: function(name, cb) {
      HTML_DSL[_PROTOTYPE][name] = createSubTemplate(name, cb);
    },
    render: function(elm, cb) {
      var dsl, e, error;
      try {
        if (!cb && _is(elm, _STR_FUNCTION)) {
          cb = elm;
          elm = null;
        }
        pushDebugContext("#render");
        dsl = new HTML_DSL;
        cb.call(dsl);
        popDebugContext();
        if (elm) {
          ato(elm, dsl.$c);
          return elm;
        }
        return dsl;
      } catch (error) {
        e = error;
        showdc();
        throw e;
      }
    }
  };
  o[_STR_THT] = HTML;
})((typeof module !== "undefined" && module !== null ? module.exports = {} : window));
