require_relative 'lex'

def main
  input = "+- */"
  lexer = Lexer.new(input)

  token = lexer.get_token()
  while token.kind != TokenType::EOF
    puts token.kind
    token = lexer.get_token()
  end
end

main()
