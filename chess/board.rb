require './piece.rb'
require './display.rb'

class Board
  attr_reader :grid

  def initialize(setup = true)
    @grid = Array.new(8) {Array.new(8)}
    populate_board if setup
  end

  def move(start, end_pos)
    x_start, y_start = start
    x_end, y_end = end_pos
    piece = get_piece(start)

    # Delegate to piece class
    piece.moved = true if piece.is_a?(Pawn)

    grid[x_end][y_end] = piece
    piece.update_pos(end_pos)
    grid[x_start][y_start] = EmptyPiece.new
  end

  def occupied?(pos)
    x, y = pos
    # Duck type use .empty?
    return true if grid[x][y].is_a?(Piece)
    false
  end

  #Rename to []
  def get_piece(pos)
    x,y = pos
    return grid[x][y]
  end

  def populate_board
    grid.length.times do |row_idx|
      grid.length.times do |col_idx|
        grid[row_idx][col_idx] = EmptyPiece.new()
      end
    end
    grid[0] = generate_start_row(:black)
    grid[1] = generate_pawns(:black)
    grid[6] = generate_pawns(:white)
    grid[7] = generate_start_row(:white)
  end

  def generate_pawns(color)
    pawns = []

    if color == :white
      row = 6
    else
      row = 1
    end

    8.times do |x|
      pawns << Pawn.new([row,x],self, color, false)
    end
    pawns
  end

  def generate_start_row(color)
    row = []
    if color == :white
      row_idx = 7
    else
      row_idx = 0
    end
    row << Rook.new([row_idx,0], self,color)
    row << Knight.new([row_idx,1], self, color)
    row << Bishop.new([row_idx,2], self, color)
    row << Queen.new([row_idx,3], self, color)
    row << King.new([row_idx,4], self, color)
    row << Bishop.new([row_idx,5], self, color)
    row << Knight.new([row_idx,6], self, color)
    row << Rook.new([row_idx,7], self, color)

    row
  end

  def in_bounds?(pos)
    pos.all? { |coord| (0..7).include?(coord)}
  end

  def get_king_position(color)
    grid.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        # Use duck typing
        if piece.is_a?(King) && piece.color == color
          return [row_idx,col_idx]
        end
      end
    end
    raise "error no king found"
  end

  def get_all_pieces(color)
    pieces = []
    grid.each_with_index do |row, row_idx|
      row.each_with_index do |piece, col_idx|
        if piece.color == color
          pieces << piece
        end
      end
    end
    pieces
  end

  def in_check?(color)
    threaten_positions =  []
    king_position = get_king_position(color)
    opponent_color = (color == :black) ? :white : :black

    get_all_pieces(opponent_color).each do |piece|
      threaten_positions += piece.moves
    end
    # Condense into one line
    return true if threaten_positions.include?(king_position)
    false
  end

  def checkmate?(color)
    get_all_pieces(color).each do |piece|
      piece.moves.each do |move|
        check_board = self.dup
        check_board.move(piece.position, move)
        return false unless check_board.in_check?(color)
      end
    end
    true
  end

  def dup
    new_board = Board.new(false)
    grid.length.times do |row_idx|
      grid.length.times do |col_idx|
          current_piece = get_piece([row_idx, col_idx])
          new_piece = current_piece.dup(new_board)
          new_board.grid[row_idx][col_idx] = new_piece
      end
    end
    new_board
  end

  def get_out_of_check(current_piece)
    allowable_moves = current_piece.moves

    current_piece.moves.each do |move|
      check_board = self.dup
      check_board.move(current_piece.position, move)
      if check_board.in_check?(current_piece.color)
        allowable_moves.delete(move)
      end
    end

    allowable_moves
  end

end

if $PROGRAM_NAME == __FILE__
  b = Board.new
  d = Display.new(b)
  d.render
  sleep(5)
  b.move([0,0], [7,7])
  d.render
end
