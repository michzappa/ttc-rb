require 'set'
require_relative 'lex'

class Parser
  def initialize(lexer, emitter)
    @lexer = lexer
    @emitter = emitter

    @symbols = Set.new
    @labels_declared = Set.new
    @labels_gotoed = Set.new

    @cur_token = nil
    @peek_token = nil
    next_token
    next_token
  end

  def program
    @emitter.header_line('#include <stdio.h>')
    @emitter.header_line('int main(void){')

    next_token while check_token(TokenType::NEWLINE)

    statement until check_token(TokenType::EOF)

    @emitter.emit_line('return 0;')
    @emitter.emit_line('}')

    @labels_gotoed.each do |label|
      self.abort("Attempting to GOTO to undeclared label '#{label}'") if @labels_declared.include?(label)
    end
  end

  def statement
    case @cur_token.kind
    when TokenType::PRINT
      next_token
      if check_token(TokenType::STRING)
        @emitter.emit_line("printf(\"#{@cur_token.text}\\n\");")
        next_token
      else
        @emitter.emit('printf("%.2f\\n", (float)(')
        expression
        @emitter.emit_line('));')
      end
    when TokenType::IF
      next_token
      @emitter.emit('if(')
      comparison

      match(TokenType::THEN)
      nl
      @emitter.emit_line('){')

      statement until check_token(TokenType::ENDIF)

      match(TokenType::ENDIF)
      @emitter.emit_line('}')
    when TokenType::WHILE
      next_token
      @emitter.emit('while(')
      comparison

      match(TokenType::REPEAT)
      nl
      @emitter.emit_line('){')

      statement until check_token(TokenType::ENDWHILE)

      match(TokenType::ENDWHILE)
      @emitter.emit_line('}')
    when TokenType::LABEL
      next_token

      self.abort("Label '#{@cur_token.text}' already exists") if @labels_declared.includes?(@cur_token.text)
      @labels_declared.add(@cur_token.text)

      @emitter.emit_line?("#{@cur_token.text}:")
      match(TokenType::IDENT)
    when TokenType::GOTO
      next_token
      @labels_gotoed.add(@cur_token.text)
      @emitter.emit_line("goto #{@cur_token.text};")
      match(TokenType::IDENT)
    when TokenType::LET
      next_token

      unless @symbols.include?(@cur_token.text)
        @symbols.add(@cur_token.text)
        @emitter.header_line("float #{@cur_token.text};")
      end

      @emitter.emit("#{@cur_token.text} = ")
      match(TokenType::IDENT)
      match(TokenType::EQ)

      expression
      @emitter.emit_line(';')
    when TokenType::INPUT
      next_token

      unless @symbols.include?(@cur_token.text)
        @symbols.add(@cur_token.text)
        @emitter.header_line("float #{@cur_token.text};")
      end

      @emitter.emit_line("if(0 == scanf(\"%f\", &#{@cur_token.text})) {")
      @emitter.emit_line("#{@cur_token.text} = 0;")
      @emitter.emit_line('scanf("%*s");')
      @emitter.emit_line('}')

      match(TokenType::IDENT)
    else
      self.abort("Invalid statement at '#{@cur_token.text}' (#{@cur_token.kind})")
    end
    nl
  end

  def comparison
    expression
    if is_comparison_operator
      @emitter.emit(@cur_token.text)
      next_token
      expression
    else
      self.abort("Expected comparison operator at '#{@cur_token.text}'")
    end
    while is_comparison_operator
      @emitter.emit(@cur_token.text)
      next_token
      expression
    end
  end

  def is_comparison_operator
    check_token(TokenType::GT) or check_token(TokenType::GTEQ) or check_token(TokenType::LT) or check_token(TokenType::LTEQ) or check_token(TokenType::EQEQ) or check_token(TokenType::NOTEQ)
  end

  def expression
    term
    while check_token(TokenType::PLUS) || check_token(TokenType::MINUS)
      @emitter.emit(@cur_token.text)
      next_token
      term
    end
  end

  def term
    unary
    while check_token(TokenType::ASTERISK) || check_token(TokenType::SLASH)
      @emitter.emit(@cur_token.text)

      next_token
      unary
    end
  end

  def unary
    if check_token(TokenType::PLUS) || check_token(TokenType::MINUS)
      @emitter.emit(@cur_token.text)
      next_token
    end
    primary
  end

  def primary
    case @cur_token.kind
    when TokenType::NUMBER
      @emitter.emit(@cur_token.text)
      next_token
    when TokenType::IDENT
      unless @symbols.include?(@cur_token.text)
        self.abort("Referencing variable '#{@cur_token.text}' before assignment")
      end
      @emitter.emit(@cur_token.text)
      next_token
    else
      self.abort("Unexpected token at '#{@cur_token.text}'")
    end
  end

  def nl
    match(TokenType::NEWLINE)
    next_token while check_token(TokenType::NEWLINE)
  end

  def check_token(kind)
    kind == @cur_token.kind
  end

  def check_peek(_kind)
    kind == @peek_token.kind
  end

  def match(kind)
    self.abort("Expected '#{kind}', got '#{@cur_token.kind}'") unless check_token(kind)

    next_token
  end

  def next_token
    @cur_token = @peek_token
    @peek_token = @lexer.get_token
  end

  def abort(message)
    Kernel.abort('Error: ' + message)
  end
end
