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

    piece = self[start]
    piece.update_moved #for the pawn class

    grid[x_end][y_end] = piece
    piece.update_pos(end_pos)

    grid[x_start][y_start] = EmptyPiece.new
  end

  def occupied?(pos)
    x, y = pos
    return !grid[x][y].empty?
  end

  def [](pos)
    x,y = pos
    return grid[x][y]
  end

  def populate_board
    #first fill the board with empty pieces
    grid.length.times do |row_idx|
      grid.length.times do |col_idx|
        grid[row_idx][col_idx] = EmptyPiece.new()
      end
    end

    # make the default rows and assign
    grid[0] = generate_start_row(:black)
    grid[1] = generate_pawns(:black)
    grid[6] = generate_pawns(:white)
    grid[7] = generate_start_row(:white)
  end

  def generate_pawns(color)
    pawns = []
    row = color == :white ? 6 : 1

    8.times do |x|
      pawns << Pawn.new([row,x],self, color, false)
    end

    pawns
  end

  def generate_start_row(color)
    row = []
    row_idx = color == :white ? 7 : 0
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
        if piece.king? && piece.color == color
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
    unsafe_positions =  []
    king_position = get_king_position(color)
    opponent_color = (color == :black) ? :white : :black

    get_all_pieces(opponent_color).each do |piece|
      unsafe_positions += piece.moves
    end

    unsafe_positions.include?(king_position)
  end

  def checkmate?(color)
    get_all_pieces(color).each do |piece|
      piece.moves.each do |move|
        #duplicate the board
        check_board = self.dup
        #make the current move on the new board
        check_board.move(piece.position, move)
        # check if there is a safe move to make
        return false unless check_board.in_check?(color)
      end
    end

    true
  end

  def dup
    new_board = Board.new(false) #don't repopulate the board

    grid.length.times do |row_idx|
      grid.length.times do |col_idx|
          current_piece = self[[row_idx, col_idx]]
          #duplicate the pieces for a deep dup
          new_piece = current_piece.dup(new_board)
          new_board.grid[row_idx][col_idx] = new_piece
      end
    end

    new_board
  end

  def get_out_of_check(current_piece)
    possible_moves = current_piece.moves

    current_piece.moves.each do |move|
      check_board = self.dup
      check_board.move(current_piece.position, move)
      if check_board.in_check?(current_piece.color)
        possible_moves.delete(move)
      end
    end

    possible_moves
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
