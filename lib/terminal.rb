# frozen_string_literal: true

require 'io/console'
require_relative 'key'

# This class handles writing the terminal screen and reading input from the user.
# Register a callback to handle input.
class Terminal
  attr_accessor :key_handler

  def initialize(&key_handler)
    @key_handler = key_handler
    @key_handler ||= proc do |key|
      puts "DefaultKeyHandler. Key pressed: #{key.inspect}"
    end
  end

  def clear_screen
    system('clear') || system('cls')
  end

  def write(string)
    print(string)
  end

  def start
    spawn_io_thread
  end

  def wait
    @io.join
  end

  def stop!
    Thread.kill(@io)
    # @io.kill
  end

  private def spawn_io_thread
    @io = Thread.new do
      STDIN.echo = false
      input_to_key_type = proc do |buffer|
        # Handle escaped characters
        case buffer[0]
        in Key::ESC
          case buffer[1]
          when '['
            case buffer[2]
            when 'A' then [Key::UP, buffer[3..]]
            when 'B' then [Key::DOWN, buffer[3..]]
            when 'C' then [Key::RIGHT, buffer[3..]]
            when 'D' then [Key::LEFT, buffer[3..]]
            when nil then [Key::UNKNOWN, buffer] # accumulate more keystrokes
            else [Key::UNKNOWN, []]
            end
          when nil then [Key::UNKNOWN, buffer] # accumulate more keystrokes
          else [Key::UNKNOWN, []]
          end
        in 'a'..'z' => key then [Key.const_get(key.upcase), buffer[1..]]
        in '0'..'9' => key then [Key.const_get("DIGIT_#{key}"), buffer[1..]]
        in Key::SPACE then [Key::SPACE, buffer[1..]]
        else [Key::UNKNOWN, []]
        end
      end

      buffer = []
      loop do
        buffer << STDIN.getch(intr: true)
        # puts "Buffer: #{buffer.inspect}"
        key, buffer = input_to_key_type.call(buffer)
        handle_key_stroke(key)
      end
    ensure
      STDIN.echo = true
    end
  end

  private def handle_key_stroke(key)
    return unless key_handler

    key_handler.call(key)
  end
end
