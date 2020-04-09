require_relative 'banners.rb'
require_relative 'game.rb'
require 'arg-parser'

class Minesweeper
  include Banners
  include ArgParser::DSL
  attr_accessor :game

  purpose <<-EOT
        === Minesweeper ===
        by Kurt Grafius
        Simple console version of the classic 60's single player Minesweeper game.
  EOT

  keyword_arg :rows, 'rows', default: 10
  keyword_arg :cols, 'cols', default: 10
  keyword_arg :difficulty, 'cols', default: 0.1


  def run
    `say "Welcome to Minesweeper"`
    puts welcome

    if opts = parse_arguments
      @game = ::Game.new(rows: opts.rows.to_i,
                         cols: opts.cols.to_i,
                         difficulty: opts.difficulty.to_f)
      @game.render(false)
      play
    else
      # False is returned if argument parsing was not completed
      # This may be due to an error or because the help command
      # was used (by specifying --help or /?). The #show_help?
      # method returns true if help was requested, otherwise if
      # a parse error was encountered, #show_usage? is true and
      # parse errors are in #parse_errors
      show_help? ? show_help : show_usage
    end
  end

  def play
    loop do
      input = STDIN.gets.chomp
      command, x, y = input.split /\s/
      case command.downcase
        when 'open', 'o'
          c = game.cell(x, y)
          if c.live
            puts "Position (#{x}, #{y}) was a live mine!"
            `say "Kabooooom"`
            puts game_over
            exit
          else
            c.visit
            game.clear_adjacent_cells(x, y)
            puts winner and exit if game.won?
          end
        when 'flag', 'f'
          game.cell(x, y).flag
        else
          puts 'Invalid command'
      end
      game.render
    end
  end


end

Minesweeper.new.run
