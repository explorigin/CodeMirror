/*global CodeMirror:false */

CodeMirror.defineMode("python", function(conf, parserConf) {
    var ERRORCLASS = 'error',
        singleOperators = new RegExp("^[\\+\\-\\*/%&|\\^~<>!]"),
        singleDelimiters = new RegExp('^[\\(\\)\\[\\]\\{\\}@,:`=;\\.]'),
        doubleOperators = new RegExp("^((==)|(!=)|(<=)|(>=)|(<>)|(<<)|(>>)|(//)|(\\*\\*))"),
        doubleDelimiters = new RegExp("^((\\+=)|(\\-=)|(\\*=)|(%=)|(/=)|(&=)|(\\|=)|(\\^=))"),
        tripleDelimiters = new RegExp("^((//=)|(>>=)|(<<=)|(\\*\\*=))"),
        identifiers = new RegExp("^[_A-Za-z][_A-Za-z0-9]*"),
        wordOperators = wordRegexp(['and', 'or', 'not', 'is', 'in']),
        commonkeywords = ['as', 'assert', 'break', 'class', 'continue',
                          'def', 'del', 'elif', 'else', 'except', 'finally',
                          'for', 'from', 'global', 'if', 'import',
                          'lambda', 'pass', 'raise', 'return',
                          'try', 'while', 'with', 'yield'],
        commonBuiltins = ['abs', 'all', 'any', 'bin', 'bool', 'bytearray', 'callable', 'chr',
                          'classmethod', 'compile', 'complex', 'delattr', 'dict', 'dir', 'divmod',
                          'enumerate', 'eval', 'filter', 'float', 'format', 'frozenset',
                          'getattr', 'globals', 'hasattr', 'hash', 'help', 'hex', 'id',
                          'input', 'int', 'isinstance', 'issubclass', 'iter', 'len',
                          'list', 'locals', 'map', 'max', 'memoryview', 'min', 'next',
                          'object', 'oct', 'open', 'ord', 'pow', 'property', 'range',
                          'repr', 'reversed', 'round', 'set', 'setattr', 'slice',
                          'sorted', 'staticmethod', 'str', 'sum', 'super', 'tuple',
                          'type', 'vars', 'zip', '__import__', 'NotImplemented',
                          'Ellipsis', '__debug__'],
        py2 = {'builtins': ['apply', 'basestring', 'buffer', 'cmp', 'coerce', 'execfile',
                            'file', 'intern', 'long', 'raw_input', 'reduce', 'reload',
                            'unichr', 'unicode', 'xrange', 'False', 'True', 'None'],
               'keywords': ['exec', 'print']},
        py3 = {'builtins': ['ascii', 'bytes', 'exec', 'print'],
               'keywords': ['nonlocal', 'False', 'True', 'None']},
        stringPrefixes = new RegExp("^(([rub]|(ur)|(br))?('{3}|\"{3}|['\"]))", "i"),
        indentInfo = null,
        keywords, builtins;

    function wordRegexp(words) {
        return new RegExp("^((" + words.join(")|(") + "))\\b");
    }

    if (!!parserConf.version && parseInt(parserConf.version, 10) === 3) {
        commonkeywords = commonkeywords.concat(py3.keywords);
        commonBuiltins = commonBuiltins.concat(py3.builtins);
        stringPrefixes = new RegExp("^(([rb]|(br))?('{3}|\"{3}|['\"]))", "i");
    } else {
        commonkeywords = commonkeywords.concat(py2.keywords);
        commonBuiltins = commonBuiltins.concat(py2.builtins);
    }
    keywords = wordRegexp(commonkeywords);
    builtins = wordRegexp(commonBuiltins);

    // tokenizers
    function tokenBase(stream, state) {
        var scopeOffset, lineOffset, ch, floatLiteral, intLiteral;
        // Handle scope changes
        if (stream.sol()) {
            scopeOffset = state.scopes[0].offset;
            if (stream.eatSpace()) {
                lineOffset = stream.indentation();
                if (lineOffset > scopeOffset) {
                    indentInfo = 'indent';
                } else if (lineOffset < scopeOffset) {
                    indentInfo = 'dedent';
                }
                return null;
            } else {
                if (scopeOffset > 0) {
                    dedent(stream, state);
                }
            }
        }
        if (stream.eatSpace()) {
            return null;
        }

        ch = stream.peek();

        // Handle Comments
        if (ch === '#') {
            stream.skipToEnd();
            return 'comment';
        }

        // Handle Number Literals
        if (stream.match(/^[0-9\.]/, false)) {
            floatLiteral = false;
            // Floats
            if (stream.match(/^\d*\.\d+(e[\+\-]?\d+)?/i)) { floatLiteral = true; }
            if (stream.match(/^\d+\.\d*/)) { floatLiteral = true; }
            if (stream.match(/^\.\d+/)) { floatLiteral = true; }
            if (floatLiteral) {
                // Float literals may be "imaginary"
                stream.eat(/J/i);
                return 'number';
            }
            // Integers
            intLiteral = false;
            // Hex
            if (stream.match(/^0x[0-9a-f]+/i)) { intLiteral = true; }
            // Binary
            if (stream.match(/^0b[01]+/i)) { intLiteral = true; }
            // Octal
            if (stream.match(/^0o[0-7]+/i)) { intLiteral = true; }
            // Decimal
            if (stream.match(/^[1-9]\d*(e[\+\-]?\d+)?/)) {
                // Decimal literals may be "imaginary"
                stream.eat(/J/i);
                // TODO - Can you have imaginary longs?
                intLiteral = true;
            }
            // Zero by itself with no other piece of number.
            if (stream.match(/^0(?![\dx])/i)) { intLiteral = true; }
            if (intLiteral) {
                // Integer literals may be "long"
                stream.eat(/L/i);
                return 'number';
            }
        }

        // Handle Strings
        if (stream.match(stringPrefixes)) {
            state.tokenize = tokenStringFactory(stream.current());
            return state.tokenize(stream, state);
        }

        // Handle operators and Delimiters
        if (stream.match(tripleDelimiters) || stream.match(doubleDelimiters)) {
            return null;
        }

        if (stream.match(doubleOperators) || stream.match(singleOperators) || stream.match(wordOperators)) {
            return 'operator';
        }

        if (stream.match(singleDelimiters)) {
            return null;
        }

        if (stream.match(keywords)) {
            return 'keyword';
        }

        if (stream.match(builtins)) {
            return 'builtin';
        }

        if (stream.match(identifiers)) {
            return 'variable';
        }

        // Handle non-detected items
        stream.next();
        return ERRORCLASS;
    }

    function tokenStringFactory(delimiter) {
        var OUTCLASS = 'string',
            singleline = 1;

        while ('rub'.indexOf(delimiter.charAt(0).toLowerCase()) >= 0) {
            delimiter = delimiter.substr(1);
        }
        singleline = delimiter.length === 1;

        function tokenString(stream, state) {
            while (!stream.eol()) {
                stream.eatWhile(/[^'"\\]/);
                if (stream.eat('\\')) {
                    stream.next();
                    if (singleline && stream.eol()) {
                        return OUTCLASS;
                    }
                } else if (stream.match(delimiter)) {
                    state.tokenize = tokenBase;
                    return OUTCLASS;
                } else {
                    stream.eat(/['"]/);
                }
            }
            if (singleline) {
                if (parserConf.singleLineStringErrors) {
                    return ERRORCLASS;
                } else {
                    state.tokenize = tokenBase;
                }
            }
            return OUTCLASS;
        }
        tokenString.isString = true;
        return tokenString;
    }

    function indent(stream, state, type) {
        var indentUnit = 0,
            i;
        type = type || 'py';
        if (type === 'py') {
            if (state.scopes[0].type !== 'py') {
                state.scopes[0].offset = stream.indentation();
                return;
            }
            for (i = 0; i < state.scopes.length; ++i) {
                if (state.scopes[i].type === 'py') {
                    indentUnit = state.scopes[i].offset + conf.indentUnit;
                    break;
                }
            }
        } else {
            indentUnit = stream.column() + stream.current().length;
        }
        state.scopes.unshift({
            offset: indentUnit,
            type: type
        });
    }

    function dedent(stream, state, type) {
        var _indent, _indent_index, i;

        type = type || 'py';
        if (state.scopes.length === 1) { return; }
        if (state.scopes[0].type === 'py') {
            _indent = stream.indentation();
            _indent_index = -1;
            for (i = 0; i < state.scopes.length; ++i) {
                if (_indent === state.scopes[i].offset) {
                    _indent_index = i;
                    break;
                }
            }
            if (_indent_index === -1) {
                return true;
            }
            while (state.scopes[0].offset !== _indent) {
                state.scopes.shift();
            }
            return false;
        } else {
            if (type === 'py') {
                state.scopes[0].offset = stream.indentation();
                return false;
            } else {
                if (state.scopes[0].type !== type) {
                    return true;
                }
                state.scopes.shift();
                return false;
            }
        }
    }

    function tokenLexer(stream, state) {
        var style, current, delimiter_index;

        indentInfo = null;
        style = state.tokenize(stream, state);
        current = stream.current();

        // Handle '.' connected identifiers
        if (current === '.') {
            style = stream.match(identifiers, false) ? null : ERRORCLASS;
            if (style === null && state.lastToken === 'meta') {
                // Apply 'meta' style to '.' connected identifiers when
                // appropriate.
                style = 'meta';
            }
            return style;
        }

        // Handle decorators
        if (current === '@') {
            return stream.match(identifiers, false) ? 'meta' : ERRORCLASS;
        }

        if ((style === 'variable' || style === 'builtin') && state.lastToken === 'meta') {
            style = 'meta';
        }

        // Handle scope changes.
        if (current === 'pass' || current === 'return') {
            state.dedent += 1;
        }
        if (current === 'lambda') { state.lambda = true; }
        if ((current === ':' && !state.lambda && state.scopes[0].type === 'py') || indentInfo === 'indent') {
            indent(stream, state);
        }
        delimiter_index = '[({'.indexOf(current);
        if (delimiter_index !== -1) {
            indent(stream, state, '])}'.slice(delimiter_index, delimiter_index+1));
        }
        if (indentInfo === 'dedent') {
            if (dedent(stream, state)) {
                return ERRORCLASS;
            }
        }
        delimiter_index = '])}'.indexOf(current);
        if (delimiter_index !== -1) {
            if (dedent(stream, state, current)) {
                return ERRORCLASS;
            }
        }
        if (state.dedent > 0 && stream.eol() && state.scopes[0].type === 'py') {
            if (state.scopes.length > 1) {
                state.scopes.shift();
            }
            state.dedent -= 1;
        }

        return style;
    }

    return {
        startState: function(basecolumn) {
            return {
              tokenize: tokenBase,
              scopes: [{offset:basecolumn || 0, type:'py'}],
              lastToken: null,
              lambda: false,
              dedent: 0
          };
        },

        token: function(stream, state) {
            var style = tokenLexer(stream, state);

            state.lastToken = style;

            if (stream.eol() && stream.lambda) {
                state.lambda = false;
            }

            return style;
        },

        indent: function(state) {
            if (state.tokenize !== tokenBase) {
                return state.tokenize.isString ? CodeMirror.Pass : 0;
            }

            return state.scopes[0].offset;
        }

    };
});

CodeMirror.defineMIME("text/x-python", "python");
