# frozen_string_literal: true

module Key
  UNKNOWN = nil
  ESC = "\e"
  UP = "\e[A"
  DOWN = "\e[B"
  RIGHT = "\e[C"
  LEFT = "\e[D"
  SPACE = ' '

  ('0'..'9').each do |k|
    Key.const_set("DIGIT_#{k}", k)
  end

  ('a'..'z').each do |k|
    Key.const_set(k.upcase, k)
  end
end
