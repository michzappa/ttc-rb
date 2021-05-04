require_relative 'lex'

class Parser
  def initialize(lexer)
    @lexer = lexer

    @cur_token = nil
    @peek_token = nil
    next_token
    next_token
  end

  def program
    puts 'PROGRAM'

    next_token while check_token(TokenType::NEWLINE)

    statement until check_token(TokenType::EOF)
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
      statment until check_token(TokenType::ENDWHILE)
      match(TokenType::ENDWHILE)
    when TokenType::LABEL
      puts 'STATEMENT-LABEL'
      next_token
      match(TokenType::IDENT)
    when TokenType::GOTO
      puts 'STATEMENT-GOTO'
      next_token
      match(TokenType::IDENT)
    when TokenType::LET
      puts 'STATEMENT-LET'
      next_token
      match(TokenType::IDENT)
      match(TokenType::EQ)
      expression
    when TokenType::INPUT
      puts 'STATEMENT-INPUT'
      next_token
      match(TokenType::IDENT)
    else
      self.abort("Invalid statement at #{@cur_token.text} (#{@cur_token.kind})")
    end
    nl
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
    self.abort("Expected #{kind}, got #{@cur_token.kind}") unless check_token(kind)

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
