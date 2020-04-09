require 'colorize'
class Game
  attr_reader :grid, :rows, :cols, :mine_count

  def initialize(rows: 10, cols: 10, difficulty: 0.1)
    raise 'Hey Now! That is not a game.' unless rows > 1 && cols > 1

    @rows = rows
    @cols = cols
    @grid = Array.new(rows) { Array.new(cols) { Cell.new } }
    seed_grid(difficulty)
    calc_live_neighbors
  end

  def seed_grid(difficulty)
    @mine_count = (rows * cols * difficulty).to_i
    (0...mine_count).step do |_mc|
      cell(rand(0...rows), rand(0...cols)).live = true
    end
  end

  def calc_live_neighbors
    grid.each_with_index do |r, r_idx|
      r.each_with_index do |cell, c_idx|
        live_neighbor_count = 0
        ([0, r_idx - 1].max..[r_idx + 1, rows - 1].min).each do |x|
          ([0, c_idx - 1].max..[c_idx + 1, cols - 1].min).each do |y|
            live_neighbor_count += 1 if cell(x, y).live
          end
          cell.live_neighbors = live_neighbor_count
        end
      end
    end
  end

  def clear_adjacent_cells(start_x, start_y)
    start_x = start_x.to_i
    start_y = start_y.to_i
    ([0, start_x - 1].max..[start_x + 1, rows - 1].min).each do |x|
      ([0, start_y - 1].max..[start_y + 1, cols - 1].min).each do |y|
        c = cell(x, y)
        if !c.live? && !c.visited?
          c.visit
          clear_adjacent_cells(x, y) unless c.live_neighbors > 0
        end
      end
    end
  end

  def render(clearscreen = true)
    clear if clearscreen

    # draw a simple header
    print "y".ljust(20)
    (0...cols).step { |c| print " #{c}".ljust(4) }
    puts
    puts 'x'
    puts

    # draw the current state of each row
    grid.each_with_index do |r, i|
      print i.to_s.ljust(20)
      r.each { |c| print format_cell(c) }
      puts ''
    end
    puts
    status
    prompt
  end

  def format_cell(cell)
    str = " #{cell.display_value} ".ljust(4).black.on_white
    if cell.visited?
      case cell.live_neighbors
      when 0
        str = str.white.on_black
      when 1
        str = str.light_blue.on_black
      when 2
        str = str.green.on_black
      else
        str = str.red.on_black
      end
    end
    str = str.white.on_blue if cell.flagged?
    str
  end

  def status
    puts "(#{unvisited_count}) unvisited cells and (#{mine_count}) mines.".yellow
  end

  def prompt
    print "mode(open|flag) x y >".green
  end

  def clear
    system "clear" #|| system "cls"
  end

  def cell(x, y)
    grid[x.to_i][y.to_i]
  end

  def won?
    mine_count >= unvisited_count
  end

  def unvisited_count
    grid.map { |r| r.map { |c| c.unvisited? ? 1 : 0 }.sum }.sum
  end
end

class Cell
  attr_accessor :live, :state, :live_neighbors

  %i{unvisited visited flagged}.each do |state|
    self.const_set(state.upcase, state)
  end

  def initialize(live: false, state: UNVISITED)
    @live = live
    @live_neighbors = 0
    @state = state
  end

  def display_value
    return 'F' if state == FLAGGED
    return live_neighbors > 0 ? live_neighbors.to_s : '-' if state == VISITED
    'D'
  end

  def flag
    self.state = FLAGGED
  end

  def visit
    self.state = VISITED
  end

  def visited?
    state == VISITED
  end

  def unvisited?
    state == UNVISITED
  end

  def flagged?
    state == FLAGGED
  end

  def live?
    live
  end
end