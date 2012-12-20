### global CodeMirror:false ###

DEFAULT_SENTRY = "00default"
ERRORCLASS = 'error'

class DFA
    constructor: (start) ->
        @start = start

    recognize: (stream) =>
        crntState = @start
        lastAccept = false
        ch = stream.next()

        while ch isnt undefined
            state_map = @states[crntState]
            accept = @accepts[crntState]
            if ch of state_map
                crntState = state_map[ch]
            else if DEFAULT_SENTRY of state_map
                crntState = state_map[DEFAULT_SENTRY]
            else if accept
                if ch
                    stream.backUp 1
                    return true
                else
                    return false
            else if lastAccept
                if ch
                    stream.backUp 1
                return true
            else
                return false

            lastAccept = accept
            ch = stream.next()

        if @accepts[crntState]
            return true
        else if lastAccept
            return true
        else
            return false

class PseudoDFA extends DFA
        accepts: [true, true, true, true, true, true, true, true, true, true, false, true, true, true, true, false, false, false, true, false, false, true, false, false, true, false, true, false, true, false, false, true, false, false, true, true, true, false, false, true, false, false, false, true]

        states: [
            # 0 - Start state
            {'\t': 0, '\n': 13, '\x0c': 0, '\r': 14, ' ': 0, '!': 10, '"': 16, '#': 18, '%': 12, '&': 12, "'": 15, '(': 13, ')': 13, '*': 7, '+': 12, ',': 13, '-': 12, '.': 6, '/': 11, '0': 4, '1': 5, '2': 5, '3': 5, '4': 5, '5': 5, '6': 5, '7': 5, '8': 5, '9': 5, ':': 13, ';': 13, '<': 9, '=': 12, '>': 8, '@': 13, 'A': 1, 'B': 2, 'C': 1, 'D': 1, 'E': 1, 'F': 1, 'G': 1, 'H': 1, 'I': 1, 'J': 1, 'K': 1, 'L': 1, 'M': 1, 'N': 1, 'O': 1, 'P': 1, 'Q': 1, 'R': 3, 'S': 1, 'T': 1, 'U': 2, 'V': 1, 'W': 1, 'X': 1, 'Y': 1, 'Z': 1, '[': 13, '\\': 17, ']': 13, '^': 12, '_': 1, '`': 13, 'a': 1, 'b': 2, 'c': 1, 'd': 1, 'e': 1, 'f': 1, 'g': 1, 'h': 1, 'i': 1, 'j': 1, 'k': 1, 'l': 1, 'm': 1, 'n': 1, 'o': 1, 'p': 1, 'q': 1, 'r': 3, 's': 1, 't': 1, 'u': 2, 'v': 1, 'w': 1, 'x': 1, 'y': 1, 'z': 1, '{': 13, '|': 12, '}': 13, '~': 13}

            # 1 - identifiers
            {'0': 1, '1': 1, '2': 1, '3': 1, '4': 1, '5': 1, '6': 1, '7': 1, '8': 1, '9': 1, 'A': 1, 'B': 1, 'C': 1, 'D': 1, 'E': 1, 'F': 1, 'G': 1, 'H': 1, 'I': 1, 'J': 1, 'K': 1, 'L': 1, 'M': 1, 'N': 1, 'O': 1, 'P': 1, 'Q': 1, 'R': 1, 'S': 1, 'T': 1, 'U': 1, 'V': 1, 'W': 1, 'X': 1, 'Y': 1, 'Z': 1, '_': 1, 'a': 1, 'b': 1, 'c': 1, 'd': 1, 'e': 1, 'f': 1, 'g': 1, 'h': 1, 'i': 1, 'j': 1, 'k': 1, 'l': 1, 'm': 1, 'n': 1, 'o': 1, 'p': 1, 'q': 1, 'r': 3, 's': 1, 't': 1, 'u': 1, 'v': 1, 'w': 1, 'x': 1, 'y': 1, 'z': 1}

            # 2 - Could be string/identifier ('u')
            {'"': 16, "'": 15, '0': 1, '1': 1, '2': 1, '3': 1, '4': 1, '5': 1, '6': 1, '7': 1, '8': 1, '9': 1, 'A': 1, 'B': 1, 'C': 1, 'D': 1, 'E': 1, 'F': 1, 'G': 1, 'H': 1, 'I': 1, 'J': 1, 'K': 1, 'L': 1, 'M': 1, 'N': 1, 'O': 1, 'P': 1, 'Q': 1, 'R': 3, 'S': 1, 'T': 1, 'U': 1, 'V': 1, 'W': 1, 'X': 1, 'Y': 1, 'Z': 1, '_': 1, 'a': 1, 'b': 1, 'c': 1, 'd': 1, 'e': 1, 'f': 1, 'g': 1, 'h': 1, 'i': 1, 'j': 1, 'k': 1, 'l': 1, 'm': 1, 'n': 1, 'o': 1, 'p': 1, 'q': 1, 'r': 3, 's': 1, 't': 1, 'u': 1, 'v': 1, 'w': 1, 'x': 1, 'y': 1, 'z': 1}

            # 3 - Could be string/identifier ('r')
            {'"': 16, "'": 15, '0': 1, '1': 1, '2': 1, '3': 1, '4': 1, '5': 1, '6': 1, '7': 1, '8': 1, '9': 1, 'A': 1, 'B': 1, 'C': 1, 'D': 1, 'E': 1, 'F': 1, 'G': 1, 'H': 1, 'I': 1, 'J': 1, 'K': 1, 'L': 1, 'M': 1, 'N': 1, 'O': 1, 'P': 1, 'Q': 1, 'R': 1, 'S': 1, 'T': 1, 'U': 1, 'V': 1, 'W': 1, 'X': 1, 'Y': 1, 'Z': 1, '_': 1, 'a': 1, 'b': 1, 'c': 1, 'd': 1, 'e': 1, 'f': 1, 'g': 1, 'h': 1, 'i': 1, 'j': 1, 'k': 1, 'l': 1, 'm': 1, 'n': 1, 'o': 1, 'p': 1, 'q': 1, 'r': 1, 's': 1, 't': 1, 'u': 1, 'v': 1, 'w': 1, 'x': 1, 'y': 1, 'z': 1}

            # 4 - Could be numbers
            {'.': 24, '0': 21, '1': 21, '2': 21, '3': 21, '4': 21, '5': 21, '6': 21, '7': 21, '8': 23, '9': 23, 'B': 22, 'E': 25, 'J': 13, 'L': 13, 'O': 20, 'X': 19, 'b': 22, 'e': 25, 'j': 13, 'l': 13, 'o': 20, 'x': 19}

            # 5 - Could be numbers
            {'.': 24, '0': 5, '1': 5, '2': 5, '3': 5, '4': 5, '5': 5, '6': 5, '7': 5, '8': 5, '9': 5, 'E': 25, 'J': 13, 'L': 13, 'e': 25, 'j': 13, 'l': 13}

            # 6 - Start of a number
            {'0': 26, '1': 26, '2': 26, '3': 26, '4': 26, '5': 26, '6': 26, '7': 26, '8': 26, '9': 26}

            # 7
            {'*': 12, '=': 13}

            # 8
            {'=': 13, '>': 12}

            # 9
            {'<': 12, '=': 13, '>': 13}

            # 10
            {'=': 13}

            # 11
            {'/': 12, '=': 13}

            # 12
            {'=': 13}
            # 13
            {}

            # 14
            {'\n': 13}

            # 15
            {DEFAULT_SENTRY: 30, '\n': 27, '\r': 27, "'": 28, '\\': 29}

            # 16
            {DEFAULT_SENTRY: 33, '\n': 27, '\r': 27, '"': 31, '\\': 32}

            # 17
            {'\n': 13, '\r': 14}

            # 18
            {DEFAULT_SENTRY: 18, '\n': 27, '\r': 27}

            # 19
            {'0': 34, '1': 34, '2': 34, '3': 34, '4': 34, '5': 34, '6': 34, '7': 34, '8': 34, '9': 34, 'A': 34, 'B': 34, 'C': 34, 'D': 34, 'E': 34, 'F': 34, 'a': 34, 'b': 34, 'c': 34, 'd': 34, 'e': 34, 'f': 34}

            # 20
            {'0': 35, '1': 35, '2': 35, '3': 35, '4': 35, '5': 35, '6': 35, '7': 35}

            # 21
            {'.': 24, '0': 21, '1': 21, '2': 21, '3': 21, '4': 21, '5': 21, '6': 21, '7': 21, '8': 23, '9': 23, 'E': 25, 'J': 13, 'L': 13, 'e': 25, 'j': 13, 'l': 13}

            # 22
            {'0': 36, '1': 36}

            # 23
            {'.': 24, '0': 23, '1': 23, '2': 23, '3': 23, '4': 23, '5': 23, '6': 23, '7': 23, '8': 23, '9': 23, 'E': 25, 'J': 13, 'e': 25, 'j': 13}

            # 24
            {'0': 24, '1': 24, '2': 24, '3': 24, '4': 24, '5': 24, '6': 24, '7': 24, '8': 24, '9': 24, 'E': 37, 'J': 13, 'e': 37, 'j': 13}

            # 25
            {'+': 38, '-': 38, '0': 39, '1': 39, '2': 39, '3': 39, '4': 39, '5': 39, '6': 39, '7': 39, '8': 39, '9': 39}

            # 26
            {'0': 26, '1': 26, '2': 26, '3': 26, '4': 26, '5': 26, '6': 26, '7': 26, '8': 26, '9': 26, 'E': 37, 'J': 13, 'e': 37, 'j': 13}

            # 27
            {}

            # 28
            {"'": 13}

            # 29
            {DEFAULT_SENTRY: 40, '\n': 13, '\r': 14}

            # 30
            {DEFAULT_SENTRY: 30, '\n': 27, '\r': 27, "'": 13, '\\': 29}

            # 31
            {'"': 13}

            # 32
            {DEFAULT_SENTRY: 41, '\n': 13, '\r': 14}

            # 33
            {DEFAULT_SENTRY: 33, '\n': 27, '\r': 27, '"': 13, '\\': 32}

            # 34
            {'0': 34, '1': 34, '2': 34, '3': 34, '4': 34, '5': 34, '6': 34, '7': 34, '8': 34, '9': 34, 'A': 34, 'B': 34, 'C': 34, 'D': 34, 'E': 34, 'F': 34, 'L': 13, 'a': 34, 'b': 34, 'c': 34, 'd': 34, 'e': 34, 'f': 34, 'l': 13}

            # 35
            {'0': 35, '1': 35, '2': 35, '3': 35, '4': 35, '5': 35, '6': 35, '7': 35, 'L': 13, 'l': 13}

            # 36
            {'0': 36, '1': 36, 'L': 13, 'l': 13}

            # 37
            {'+': 42, '-': 42, '0': 43, '1': 43, '2': 43, '3': 43, '4': 43, '5': 43, '6': 43, '7': 43, '8': 43, '9': 43}

            # 38
            {'0': 39, '1': 39, '2': 39, '3': 39, '4': 39, '5': 39, '6': 39, '7': 39, '8': 39, '9': 39}

            # 39
            {'0': 39, '1': 39, '2': 39, '3': 39, '4': 39, '5': 39, '6': 39, '7': 39, '8': 39, '9': 39, 'J': 13, 'j': 13}

            # 40
            {DEFAULT_SENTRY: 40, '\n': 27, '\r': 27, "'": 13, '\\': 29}

            # 41
            {DEFAULT_SENTRY: 41, '\n': 27, '\r': 27, '"': 13, '\\': 32}

            # 42
            {'0': 43, '1': 43, '2': 43, '3': 43, '4': 43, '5': 43, '6': 43, '7': 43, '8': 43, '9': 43}

            # 43
            {'0': 43, '1': 43, '2': 43, '3': 43, '4': 43, '5': 43, '6': 43, '7': 43, '8': 43, '9': 43, 'J': 13, 'j': 13}
        ]

class EOLTokenizer
    constructor: (return_tokenizer) ->
        @ret_tok = return_tokenizer

    token: (stream, state) =>
        state.tokenizer = @ret_tok
        return 'newline'

class IndentTokenizer
    constructor: (column, return_tokenizer) ->
        @column = column
        @ret_tok = return_tokenizer

    token: (stream, state) =>
        state.scopes.unshift {level:@column, type:'py'}

        state.tokenizer = @ret_tok

        return 'indent'

class DedentTokenizer
    constructor: (column, return_tokenizer) ->
        @column = column
        @ret_tok = return_tokenizer

    token: (stream, state) =>
        current_scope = state.scopes[0];
        if @column < current_scope.level and current_scope.type is 'py'
            state.scopes.shift()
            return 'dedent'

        state.tokenizer = @ret_tok

        if current_scope.level isnt @column or current_scope.type isnt 'py'
            return @ERRORCLASS

        return null

class StringTokenizer
    constructor: (delimiter, return_tokenizer) ->
        while !(/['"]/.test delimiter.charAt(0))
            delimiter = delimiter.substr 1

        @delimiter = delimiter
        @ret_tok = return_tokenizer
        @singleline = delimiter.length is 1;

    token: (stream, state) =>
        if @delimiter.length is 2
            state.tokenizer = this.ret_tok
            return 'string'

        while !stream.eol()
            stream.eatWhile /[^'"\\]/
            if stream.eat '\\'
                stream.next()
                if @singleline && stream.eol()
                    return 'string'

            else if stream.match @delimiter
                state.tokenizer = @ret_tok
                return 'string'
            else
                stream.eat /['"]/

        if @singleline
            state.tokenizer = @ret_tok

        return 'string'

class StatementTokenizer
    opmap:
        "(":'lpar'
        ")":'rpar'
        "[":'lsqb'
        "]":'rsqb'
        ":":'colon'
        "":'comma'
        ";":'semi'
        "+":'plus'
        "-":'minus'
        "*":'star'
        "/":'slash'
        "|":'vbar'
        "&":'amper'
        "<":'less'
        ">":'greater'
        "=":'equal'
        ".":'dot'
        "%":'percent'
        "`":'backquote'
        "{":'lbrace'
        "}":'rbrace'
        "==":'eqequal'
        "<>":'notequal'
        "!=":'notequal'
        "<=":'lessequal'
        ">=":'greaterequal'
        "~":'tilde'
        "^":'circumflex'
        "<<":'leftshift'
        ">>":'rightshift'
        "**":'doublestar'
        "+=":'plusequal'
        "-=":'minequal'
        "*=":'starequal'
        "/=":'slashequal'
        "%=":'percentequal'
        "&=":'amperequal'
        "|=":'vbarequal'
        "^=":'circumflexequal'
        "<<=":'leftshiftequal'
        ">>=":'rightshiftequal'
        "**=":'doublestarequal'
        "//":'doubleslash'
        "//=":'doubleslashequal'
        "@":'at'

    constructor: (cfg) ->
        @tab_size = cfg.tabSize or 4
        @pseudodfa = new PseudoDFA(0)

    token: (stream, state) =>
        # The first token could be an ENCODING token but we will skip that for now

        if stream.sol()
            column = 0

            consumed = 1
            ch = stream.next()

            while /[\s\u00a0]/.test(ch)
                if ch is '\t'
                    column = (column/@tab_size + 1) * @tab_size
                else if ch is '\f'
                    column = 0
                else
                    column += 1
                consumed += 1
                ch = stream.next()

            current_scope = state.scopes[0]
            if column > current_scope.level
                state.tokenizer = new IndentTokenizer(column, @)
            else if column < current_scope.level
                state.tokenizer = new DedentTokenizer(column, @)

            stream.backUp(if ch is undefined then consumed - 1 else consumed)

        if stream.eatSpace()
            return 'whitespace'
        else if state.tokenizer isnt @
            return null

        ch = stream.peek()

        if ch is '#'
            stream.skipToEnd()
            state.tokenizer = new EOLTokenizer(@)
            return 'comment'

        token_cls = ERRORCLASS
        if @pseudodfa.recognize stream
            token_cls = 'token'

            token = stream.current()

            ch = token.charAt 0

            if /[0-9]/.test ch or (ch is '.' and token.length > 1)
                token_cls = 'number'

            else if /("("")?)|('('')?)/.test token
                state.tokenizer = new StringTokenizer(token, @)
                return null

            else if (/[\n\r]/.test ch) and state.paren_level is 0
                console.log 'found a newline'
                token_cls = 'newline'

            else if /[A-Za-z_]/.test ch
                token_cls = 'name'

            else
                if /[\(\[\{]/.test ch
                    state.paren_level += 1
                else if /[\)\]\}]/.test ch
                    state.paren_level -= 1
                    if state.paren_level < 0
                        token_cls = ERRORCLASS

                if token of @opmap
                    token_cls = @opmap[token]
                else
                    token_cls = 'op'


        if stream.eol()
            state.tokenizer = new EOLTokenizer(@)

        return token_cls

CodeMirror.defineMode "python", (conf, parserConf) ->
    return {
        startState: (basecolumn) ->
            return {
                tokenizer: new StatementTokenizer(conf)
                scopes: [{level:basecolumn || 0, type:'py', paren_level: 0}]
            }

        token: (stream, state) ->
            style = null
            while typeof style isnt 'string'
                if style isnt null
                    console.log style
                style = state.tokenizer.token stream, state
            return style
        }


CodeMirror.defineMIME "text/x-python", "python"
