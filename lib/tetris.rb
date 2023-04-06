require_relative 'key'
require_relative 'blocks'
require_relative 'string_extensions'
require_relative 'terminal_formatter'

class Tetris
  using StringExtensions
  include TerminalFormatter

  CURRENT_BLOCK_SYMBOL = 'O' #"\u25A3"
  FALLEN_BLOCK_SYMBOL = 'X' #"\u23F9"
  EMPTY_BLOCK_SYMBOL = '.'

  def initialize(terminal, width = 10, height = 20)
    @terminal = terminal
    @terminal.key_handler = method(:handle_input)

    @width = width
    @height = height

    reset!
  end

  def run
    @terminal.start
    game_loop
    @terminal.wait
  end

  def stop!
    @terminal.stop!
    puts 'Stopped'
  end

  def print
    @terminal.clear_screen
    @terminal.write(heading)
    @terminal.write(board)
  end

  def game_loop
    last_tick = Time.now
    loop do
      if @tick_now || (last_tick + @speed) < Time.now
        next if @paused

        handle_current_block!
        clear_lines!
        last_tick = Time.now
        @tick_now = false
      end
      clear_board!
      render_current_block!
      render_fallen_blocks!
      print
      sleep 1 / 30.0 # 30 fps
    end
  end

  def heading
    <<~HEADING
      Tetris: #{@paused ? 'Paused' : 'Running'} | Score: #{@score} | Speed: #{(0.5 / @speed).truncate(2)}
      Press 'q' to quit, 'r' to reset, 'p' to pause
      #{'-' * (@width * 3)}
    HEADING
  end

  def board
    (@height.downto(1)).map do |y|
      (1.upto(@width)).map do |x|
        case @board[y - 1][x - 1]
        in nil then " #{EMPTY_BLOCK_SYMBOL} "
        in x then " #{x} "
        end
      end.join
    end.join("\n")
  end

  def spawn_block
    Blocks::ALL.sample.new.tap do |block|
      block.move_to!(@width / 2 - 1, @height)

      if illegal_position?(block)
        block.down! while illegal_position?(block)
      end
    end
  end

  def handle_current_block!
    @current_block.down!
    return unless illegal_position?(@current_block)

    @current_block.up!
    @current_block.coordinates.each do |x, y|
      @fallen_blocks[y][x] = @current_block.color
    end
    @current_block = spawn_block
  end

  def render_current_block!
    @current_block.coordinates.each do |x, y|
      @board[y][x] = send(@current_block.color, CURRENT_BLOCK_SYMBOL)
    end
  end

  def clear_board!
    @board = @height.times.map { Array.new(@width) }
  end

  def illegal_position?(block)
    out_of_board_bounds?(block) || collision?(block)
  end

  def collision?(block)
    block.coordinates.any? do |x, y|
      !@fallen_blocks[y][x].nil?
    end
  end

  def out_of_board_bounds?(block)
    block.coordinates.any? do |x, y|
      x < 0 || x >= @width || y < 0 || y >= @height
    end
  end

  def clear_lines!
    lines_cleared = 0;
    # clear filled lines
    # move all lines above down
    ((@height - 1).downto(0)).each do |y|
      next unless @fallen_blocks[y].all?

      lines_cleared += 1
      @fallen_blocks.delete_at(y)
      @fallen_blocks.push(Array.new(@width))
    end

    if lines_cleared > 0
      @score += 10 * lines_cleared
      @speed *= 0.9
    end
  end

  def reset!
    @tick_now = true
    clear_board!
    @fallen_blocks = @board.dup
    @speed = 0.5
    @score = 0
    @paused = false
    @current_block = spawn_block
  end

  def render_fallen_blocks!
    @fallen_blocks.each_with_index do |_row, y|
      @fallen_blocks[y].each_with_index do |cell, x|
        next if cell.nil?

        @board[y][x] = send(cell, FALLEN_BLOCK_SYMBOL)
      end
    end
  end

  def handle_input(key)
    prev_block = @current_block.dup
    case key
    when Key::UP then @current_block.rotate!
    when Key::DOWN then @current_block.down!
    when Key::LEFT then @current_block.left!
    when Key::RIGHT then @current_block.right!
    when Key::SPACE
      @current_block.down! until (illegal_position?(@current_block))
      @current_block.up!
      @tick_now = true
    when Key::Q then stop!
    when Key::R then reset!
    when Key::P then @paused = !@paused
    end

    return unless @paused || illegal_position?(@current_block)
    @current_block = prev_block

  end
end