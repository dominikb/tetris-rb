require_relative 'lib/tetris'
require_relative 'lib/terminal'

if __FILE__  == $0
  terminal = Terminal.new
  tetris = Tetris.new(terminal)
  tetris.run
end