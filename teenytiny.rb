require_relative 'lex'
require_relative 'parse'
require_relative 'emit'

def main
  puts 'Teeny Tiny Compiler'

  Kernel.abort('Error: Compiler needs source file as argument.') if ARGV.length != 1
  input = File.open(ARGV[0]).read

  program_name = ARGV[0].split('.')[0]

  lexer = Lexer.new(input)
  emitter = Emitter.new("#{program_name}.c")
  parser = Parser.new(lexer, emitter)

  parser.program
  emitter.write_file
  puts 'Compiled to C'
  system("gcc -o #{program_name} #{program_name}.c")
  system("rm #{program_name}.c")
  puts 'Compiled Executable'
end

main
