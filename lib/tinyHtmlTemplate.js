var slice = [].slice;

(function(o) {
  var HTML, HTML_DSL, TAGS, _STR_ERROR, _STR_FUNCTION, _STR_STRING, _STR_THT, _is, consoleError, consoleGroup, consoleGroupEnd, createSubTemplate, createTagFunction, dc, i, len, popdc, pushdc, setFields, showdc, tag;
  _STR_THT = "tinyHtmlTemplate";

  /*
    List of standard tags.
   */
  TAGS = "a,abbr,address,area,article,aside,audio,b,base,bdi,bdo,blockquote,body,br,button,canvas,caption,cite,code,col,colgroup,command,datalist,dd,del,details,dfn,div,dl,dt,em,embed,fieldset,figcaption,figure,footer,form,h1,h2,h3,h4,h5,h6,head,header,hgroup,hr,html,i,iframe,img,input,ins,kbd,keygen,label,legend,li,link,map,mark,menu,meta,meter,nav,noscript,object,ol,optgroup,option,output,p,param,pre,progress,q,rp,rt,ruby,s,samp,script,section,select,small,source,span,strong,style,sub,summary,sup,table,tbody,td,textarea,tfoot,th,thead,time,title,tr,track,u,ul,var,video,wbr".split(",");

  /*
    Helper for minification. DRY.
   */
  _STR_STRING = 'string';
  _STR_FUNCTION = 'function';
  _STR_ERROR = "error";

  /*
    Methods for debug.
   */
  dc = [];
  [consoleGroup = console.groupCollapsed, consoleGroupEnd = console.groupEnd, consoleError = console[_STR_ERROR]].map(function(x) {
    return x.bind(console);
  });
  _is = function(o, x) {
    return typeof o === x;
  };
  pushdc = function(tag) {
    return dc.push(tag);
  };
  popdc = function() {
    return dc.pop();
  };
  showdc = function() {
    var debugPrint;
    debugPrint = function() {
      var i, len, results, tabs, x;
      tabs = "";
      results = [];
      for (i = 0, len = dc.length; i < len; i++) {
        x = dc[i];
        tabs += " ";
        results.push(consoleError(">" + tabs + "%O", x));
      }
      return results;
    };
    if (consoleGroup) {
      consoleGroup("%c" + _STR_THT + _STR_ERROR, "font-style: italic; color: red; background-color: white;");
      debugPrint();
      return consoleGroupEnd();
    } else {
      consoleError("" + _STR_THT + _STR_ERROR);
      return debugPrint();
    }
  };
  createTagFunction = function(tagName) {
    return function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return this.tag.apply(this, [tagName].concat(args));
    };
  };
  createSubTemplate = function(name, partial) {
    return function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      pushdc(name);
      partial.apply(this, args);
      return popdc();
    };
  };
  setFields = function(ctx, hash) {
    var k, results, v;
    results = [];
    for (k in hash) {
      v = hash[k];
      if (_is(v, "object")) {
        results.push(setFields(ctx[k], v));
      } else {
        results.push(ctx[k] = v);
      }
    }
    return results;
  };
  HTML_DSL = (function() {
    function HTML_DSL(elm) {
      this._e = elm;
      this._c = [];
    }

    HTML_DSL.prototype.ato = function(elm) {
      var i, len, ref, results, x;
      ref = this._c;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        x = ref[i];
        results.push(elm.appendChild(x));
      }
      return results;
    };

    HTML_DSL.prototype.on = function(event, cb) {
      return this._e.addEventListener(event, cb);
    };

    HTML_DSL.prototype.text = function(x) {
      return this._c.push(document.createTextNode(x));
    };

    HTML_DSL.prototype.tag = function(tagName, properties, cb) {
      var cElm, dsl, text;
      if (properties == null) {
        properties = {};
      }
      if (!cb && _is(properties, _STR_FUNCTION)) {
        cb = properties;
        properties = {};
      }
      if (_is(properties, _STR_STRING)) {
        properties = {
          innerText: properties
        };
      }
      cElm = document.createElement(tagName);
      setFields(cElm, properties);
      this._c.push(cElm);
      if (_is(text = cb, _STR_STRING)) {
        cb = function() {
          return this.text(text);
        };
      }
      if (cb) {
        if (!_is(cb, _STR_FUNCTION)) {
          throw new Error("Callback isn't " + _STR_FUNCTION);
        }
        dsl = new HTML_DSL(cElm);
        pushdc(cElm);
        cb.call(dsl);
        dsl.ato(dsl._e);
        return popdc(tagName);
      }
    };

    return HTML_DSL;

  })();
  for (i = 0, len = TAGS.length; i < len; i++) {
    tag = TAGS[i];
    HTML_DSL.prototype[tag] = createTagFunction(tag);
  }
  HTML = {
    register: function(name, cb) {
      return HTML_DSL.prototype[name] = createSubTemplate(name, cb);
    },
    render: function(elm, cb) {
      var dsl, e, error;
      try {
        pushdc("#render");
        if (!cb && _is(elm, _STR_FUNCTION)) {
          cb = elm;
          elm = null;
        }
        if (elm) {
          dsl = new HTML_DSL;
          cb.call(dsl);
          dsl.ato(elm);
          return elm;
        } else {
          dsl = new HTML_DSL;
          cb.call(dsl);
          return dsl;
        }
        return popdc();
      } catch (error) {
        e = error;
        showdc();
        throw e;
      }
    }
  };
  return o[_STR_THT] = HTML;
})((typeof module !== "undefined" && module !== null ? module.exports = {} : window));
