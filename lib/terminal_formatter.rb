module TerminalFormatter
  ANSII_RESET = "\e[0m"
  ANSII_BOLD = "\e[1m"
  ANSII_UNDERLINE = "\e[4m"
  ANSII_BLINK = "\e[5m"
  ANSII_BLACK = "\e[30m"
  ANSII_RED = "\e[31m"
  ANSII_GREEN = "\e[32m"
  ANSII_YELLOW = "\e[33m"
  ANSII_BLUE = "\e[34m"
  ANSII_MAGENTA = "\e[35m"
  ANSII_CYAN = "\e[36m"
  ANSII_WHITE = "\e[37m"

  COLORS = %i[black red green yellow blue magenta cyan white].freeze
  COLORS.each do |color|
    define_method(color) do |str|
      "#{self.class.const_get("ANSII_#{color.upcase}")}#{str}#{ANSII_RESET}"
    end
  end
end