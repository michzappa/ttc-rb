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
  # attr_accessor :text
  attr_accessor :kind
  def initialize(token_text, token_kind)
    @text = token_text
    @kind = token_kind
  end
end
class Lexer
  # attr_accessor :source
  attr_accessor :cur_char
  # attr_accessor :cur_pos

  def initialize(input)
    @source = input + '\n'
    @cur_char = ''
    @cur_pos = -1
    self.next_char()
  end

  def next_char
    @cur_pos += 1
    if @cur_pos >= @source.length
      @cur_char = '\0'
    else
      @cur_char = @source[@cur_pos]
    end
  end

  def peek
    if @cur_pos + 1 >= @source.length
      return '\0'
    end
    return @source[@cur_pos + 1]
  end

  def abort(message)
    Kernel.abort(message)
  end

  def skip_whitespace
    while @cur_char == ' ' or @cur_char == '\t' or @cur_char == '\r'
      self.next_char()
    end
  end

  def skip_comment
  end

  def get_token
    self.skip_whitespace()
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
    when '\n'
      token = Token.new(@cur_char, TokenType::NEWLINE)
    when '\0'
      token = Token.new(@cur_char, TokenType::EOF)
    else
      self.abort("Uknown token: " + @cur_char)
    end

    self.next_char()
    return token
  end
end
