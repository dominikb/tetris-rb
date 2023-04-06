require_relative 'lib/terminal'

terminal = Terminal.new do |key|
  case key
  when Key::UNKNOWN then nil
  when Key::SPACE then puts "SPACES"
  when Key::UP then puts 'UP'
  when Key::DOWN then puts 'DOWN'
  when Key::LEFT then puts 'LEFT'
  when Key::RIGHT then puts 'RIGHT'
  when Key::Q then puts 'Q'; exit
  else puts key.inspect
  end
end

terminal.start
terminal.wait
