require_relative 'lex'

def main
  input = 'IF+-123 foo* THEN/'
  lexer = Lexer.new(input)
  # puts input
  token = lexer.get_token
  while token.kind != TokenType::EOF
    puts token.kind
    token = lexer.get_token
  end
end

main
