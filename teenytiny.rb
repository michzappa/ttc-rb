require_relative 'lex'
require_relative 'parse'

def main
  puts "Teeny Tiny Compiler"

  if ARGV.length != 1
    Kernel.abort("Error: Compiler needs source file as argument.")
  end
  input = File.open(ARGV[0]).read

  lexer = Lexer.new(input)
  parser = Parser.new(lexer)

  parser.program()
  puts "Parsing Completed"
end

main
