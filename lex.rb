class TokenType
  EOF = -1
  NEWLINE = 0
  NUMBER = 1
  IDENT = 2
  STRING = 3
  # keywords
  LABEL = 101
  GOTO = 102
  PRINT = 103
  INPUT = 104
  LET = 105
  IF = 106
  THEN = 107
  ENDIF = 108
  WHILE = 109
  REPEAT = 110
  ENDWHILE = 111
  # operators
  EQ = 201
  PLUS = 202
  MINUS = 203
  ASTERISK = 204
  SLASH = 205
  EQEQ = 206
  NOTEQ = 207
  LT = 208
  LTEQ = 209
  GT = 210
  GTEQ = 211
end

class Token
  attr_accessor :text, :kind

  def initialize(token_text, token_kind)
    @text = token_text
    @kind = token_kind
  end

  def self.check_if_keyword(token_text)
    TokenType.constants.each do |c|
      value = TokenType.const_get(c)
      return value if (c.to_s == token_text) && (value >= 100) && (value <= 200)
    end
    nil
  end
end

class Lexer
  attr_accessor :source, :cur_char

  # attr_accessor :cur_pos

  def initialize(input)
    @source = input + "\n"
    @cur_char = ''
    @cur_pos = -1
    next_char
  end

  def next_char
    @cur_pos += 1
    @cur_char = if @cur_pos >= @source.length
                  "\0"
                else
                  @source[@cur_pos]
                end
    # puts @cur_char
  end

  def peek
    return "\0" if @cur_pos + 1 >= @source.length

    @source[@cur_pos + 1]
  end

  def abort(message)
    Kernel.abort(message)
  end

  def skip_whitespace
    next_char while (@cur_char == ' ') || (@cur_char == "\t") || (@cur_char == "\r")
  end

  def skip_comment
    next_char while @cur_char != "\n" if @cur_char == '#'
  end

  def get_token
    skip_whitespace
    skip_comment
    token = nil

    case @cur_char
    when '+'
      token = Token.new(@cur_char, TokenType::PLUS)
    when '-'
      token = Token.new(@cur_char, TokenType::MINUS)
    when '*'
      token = Token.new(@cur_char, TokenType::ASTERISK)
    when '/'
      token = Token.new(@cur_char, TokenType::SLASH)
    when '='
      if peek == '='
        last_char = @cur_char
        next_char
        token = Token.new(last_char + @cur_char, TokenType::EQEQ)
      else
        token = Token.new(@cur_char, TokenType::EQ)
      end
    when '>'
      if peek == '='
        last_char = @cur_char
        next_char
        token = Token.new(last_char + @cur_char, TokenType::GTEQ)
      else
        token = Token.new(@cur_char, TokenType::GT)
      end
    when '<'
      if peek == '='
        last_char = @cur_char
        next_char
        token = Token.new(last_char + @cur_char, TokenType::LTEQ)
      else
        token = Token.new(@cur_char, TokenType::LT)
      end
    when '!'
      if peek == '='
        last_char = @cur_char
        next_char
        token = Token.new(last_char + @cur_char, TokenType::NOTEQ)
      else
        self.abort('Expected !=, got !' + peek)
      end
    when '"'
      next_char
      start_pos = @cur_pos

      while @cur_char != '"'
        if (@cur_char == "\r") || (@cur_char == "\n") || (@cur_char == "\t") || (@cur_char == '\\') || (@cur_char == '%')
          self.abort('Illegal character in string.')
        end
        next_char
      end

      tok_text = @source[start_pos, @cur_pos - start_pos]
      token = Token.new(tok_text, TokenType::STRING)
    when /[0-9]/
      start_pos = @cur_pos
      next_char while peek =~ /[0-9]/
      if peek == '.'
        next_char

        self.abort('Illegal character in number') unless peek =~ /[0-9]/

        next_char while peek =~ /[0-9]/
      end

      tok_text = source[start_pos, @cur_pos + 1 - start_pos]
      token = Token.new(tok_text, TokenType::NUMBER)
    when /[A-Za-z]/
      start_pos = @cur_pos
      next_char while peek =~ /[A-Za-z0-9]/

      tok_text = @source[start_pos, @cur_pos + 1 - start_pos]
      keyword = Token.check_if_keyword(tok_text)
      token = if keyword.nil?
                Token.new(tok_text, TokenType::IDENT)
              else
                Token.new(tok_text, keyword)
              end
    when "\n"
      token = Token.new(@cur_char, TokenType::NEWLINE)
    when "\0"
      token = Token.new(@cur_char, TokenType::EOF)
    else
      self.abort('Unknown token: ' + @cur_char)
    end

    next_char
    token
  end
end
