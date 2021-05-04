require 'set'
require_relative 'lex'

class Parser
  def initialize(lexer)
    @lexer = lexer

    @symbols = Set.new
    @labels_declared = Set.new
    @labels_gotoed = Set.new

    @cur_token = nil
    @peek_token = nil
    next_token
    next_token
  end

  def program
    puts 'PROGRAM'

    next_token while check_token(TokenType::NEWLINE)

    statement until check_token(TokenType::EOF)

    @labels_gotoed.each do |label|
      self.abort("Attempting to GOTO to undeclared label '#{label}'") if @labels_declared.include?(label)
    end
  end

  def statement
    case @cur_token.kind
    when TokenType::PRINT
      puts 'STATEMENT-PRINT'
      next_token
      if check_token(TokenType::STRING)
        next_token
      else
        expression
      end
    when TokenType::IF
      puts 'STATEMENT-IF'
      next_token
      comparison
      match(TokenType::THEN)
      nl
      statement until check_token(TokenType::ENDIF)
      match(TokenType::ENDIF)
    when TokenType::WHILE
      puts 'STATEMENT-WHILE'
      next_token
      comparison
      match(TokenType::REPEAT)
      nl
      statement until check_token(TokenType::ENDWHILE)
      match(TokenType::ENDWHILE)
    when TokenType::LABEL
      puts 'STATEMENT-LABEL'
      next_token

      self.abort("Label '#{@cur_token.text}' already exists") if @labels_declared.includes?(@cur_token.text)
      @labels_declared.add(@cur_token.text)

      match(TokenType::IDENT)
    when TokenType::GOTO
      puts 'STATEMENT-GOTO'
      next_token
      @labels_gotoed.add(@cur_token.text)
      match(TokenType::IDENT)
    when TokenType::LET
      puts 'STATEMENT-LET'
      next_token

      @symbols.add(@cur_token.text) unless @symbols.include?(@cur_token.text)

      match(TokenType::IDENT)
      match(TokenType::EQ)
      expression
    when TokenType::INPUT
      puts 'STATEMENT-INPUT'
      next_token

      @symbols.add(@cur_token.text) unless @symbols.include?(@cur_token.text)

      match(TokenType::IDENT)
    else
      self.abort("Invalid statement at '#{@cur_token.text}' (#{@cur_token.kind})")
    end
    nl
  end

  def comparison
    puts 'COMPARISON'

    expression
    if is_comparison_operator
      next_token
      expression
    else
      self.abort("Expected comparison operator at '#{@cur_token.text}'")
    end
    while is_comparison_operator
      next_token
      expression
    end
  end

  def is_comparison_operator
    check_token(TokenType::GT) or check_token(TokenType::GTEQ) or check_token(TokenType::LT) or check_token(TokenType::LTEQ) or check_token(TokenType::EQEQ) or check_token(TokenType::NOTEQ)
  end

  def expression
    puts 'EXPRESSION'
    term
    while check_token(TokenType::PLUS) || check_token(TokenType::MINUS)
      next_token
      term
    end
  end

  def term
    puts 'TERM'

    unary
    while check_token(TokenType::ASTERISK) || check_token(TokenType::SLASH)
      next_token
      unary
    end
  end

  def unary
    puts 'UNARY'

    next_token if check_token(TokenType::PLUS) || check_token(TokenType::MINUS)
    primary
  end

  def primary
    puts "Primary (#{@cur_token.text})"

    case @cur_token.kind
    when TokenType::NUMBER
      next_token
    when TokenType::IDENT
      unless @symbols.include?(@cur_token.text)
        self.abort("Referencing variable '#{@cur_token.text}' before assignment")
      end
      next_token
    else
      self.abort("Unexpected token at '#{@cur_token.text}'")
    end
  end

  def nl
    puts 'NEWLINE'

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
