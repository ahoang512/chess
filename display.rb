require "colorize"
require_relative "cursorable"

class Display
  include Cursorable
  attr_reader :board

  def initialize(board)
    @board = board
    @cursor_pos = [0,1]
    #@selected = false
    @selected = nil
  end

  def reset_selected
    @selected = nil
  end

  # def render
  #   row_numbers = (1..8).to_a.reverse
  #   puts  "   a  b  c  d  e  f  g  h"
  #   board.grid.each_with_index do |row, idx|
  #     print "#{row_numbers[idx]}  "
  #     row.each {|piece| print "#{piece.value}  " }
  #     print "#{row_numbers[idx]}"
  #     puts
  #   end
  #   puts "   a  b  c  d  e  f  g  h"
  # end

  def build_grid
    @board.grid.each.map.with_index do |row , x|
      build_row(row, x)
    end
  end

  def build_row(row, x)
    row.map.with_index do |piece, y|
      color_options = colors_for(x, y)
      piece.value.colorize(color_options)
    end
  end

  def colors_for(i, j)

    highlight_coords = []
    if @selected
      highlight_coords = board.get_out_of_check(board[@selected])
    end

      if [i, j] == @cursor_pos
        #@selected ? bg = :light_red : bg = :yellow
        bg = :orange
      elsif highlight_coords.include?([i,j])
        bg = :magenta
      elsif [i, j] == @selected #&& board.grid[i][j].is_a?(Piece)
        bg = :light_red
      elsif (i + j).odd?
        bg = :light_blue
      else
        bg = :green
      end

      #if piece.selected? bg = :purple

      piece_color = @board.grid[i][j].color

      { background: bg, color: piece_color}
  end

  def render
    row_numbers = (1..8).to_a.reverse
    system("clear")

    puts  "   a  b  c  d  e  f  g  h"
    build_grid.each_with_index do |row, idx|
      puts "#{row_numbers[idx]} #{row.join} #{row_numbers[idx]}"
    end
    puts  "   a  b  c  d  e  f  g  h"
  end


end
