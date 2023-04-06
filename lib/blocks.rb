module Blocks

  module Rotation
    def rotate!
      @block = @block.transpose.map(&:reverse)
    end
  end

  module Initializer
    def initialize
      @block = self.class::BLOCK
    end
  end

  module Color
    def self.included(base)
      base.send(:attr_accessor, :color)
    end
    def initialize
      super
      @color = self.class::COLOR
    end
  end

  module Position
    def self.included(base)
      base.send(:attr_accessor, :x, :y)
    end

    def move_to!(x,y)
      @x, @y = x, y
    end
    def up! = @y += 1
    def down! = @y -= 1
    def left! = @x -= 1
    def right! = @x += 1

    # All coordinates given the lower left bound of the block
    def coordinates
      @block.reverse.each_with_index.map do |row, row_index|
        row.each_with_index.filter_map do |col, col_index|
          next unless col == '1'
          [x + col_index, y + row_index]
        end
      end.flatten(1)
    end
  end

  module BaseBlock
    include Rotation
    include Initializer
    include Position
    include Color

    def self.included(base)
      base.send(:attr_reader, :block)
    end

    def to_s
      @block.map { |row| row.join(' ') }.join("\n")
    end
  end

  class I
    include BaseBlock
    COLOR = :cyan
    BLOCK = [
      %w[0 0 0 0],
      %w[0 0 0 0],
      %w[1 1 1 1],
      %w[0 0 0 0],
    ].freeze
  end

  class O
    include BaseBlock
    COLOR = :yellow
    BLOCK = [
      %w[1 1],
      %w[1 1],
    ].freeze
  end

  class J
    include BaseBlock
    COLOR = :blue
    BLOCK = [
      %w[0 0 0],
      %w[1 1 1],
      %w[0 0 1],
    ].freeze
  end

  class L
    include BaseBlock
    COLOR = :white
    BLOCK = [
      %w[0 0 0],
      %w[1 1 1],
      %w[1 0 0],
    ].freeze
  end

  class S
    include BaseBlock
    COLOR = :green
    BLOCK = [
      %w[0 0 0],
      %w[0 1 1],
      %w[1 1 0],
    ].freeze
  end

  class T
    include BaseBlock
    COLOR = :magenta
    BLOCK = [
      %w[0 0 0],
      %w[1 1 1],
      %w[0 1 0],
    ].freeze
  end

  class Z
    include BaseBlock
    COLOR = :red
    BLOCK = [
      %w[0 0 0],
      %w[1 1 0],
      %w[0 1 1],
    ].freeze
  end

  ALL = [I, J, L, O, S, Z, T].freeze
end
