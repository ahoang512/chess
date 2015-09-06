

class Piece
  attr_reader :value, :position, :board, :color

  def initialize(position, board, color, moved = false)
    @value = "   "
    @position = position
    @board = board
    @color = color
    @moved = moved
  end

  def update_pos(pos)
    @position = pos
  end

  def dup(new_board)
    new_position = position.dup
    self.class.new(new_position, new_board, color, @moved)
  end



end


class EmptyPiece
  attr_reader :value, :color

  def initialize
    @value = "   "
    @color = :blue
  end

  def dup(board)
    EmptyPiece.new
  end
end

class SlidingPiece < Piece
  def initialize(position, board, color, moved = false)
    super
  end

  def moves
    possible_moves = []
    x_cur, y_cur = position
    move_dirs.each do |vector|
      x_next = vector[0] + x_cur
      y_next = vector[1] + y_cur
      possible_pos = [x_next, y_next]

      #while board.in_bounds?(possible_pos)
      while move_valid?(possible_pos)
        possible_moves << possible_pos.dup
        possible_pos = [possible_pos[0] += vector[0],
                                possible_pos[1] += vector[1]]
      end

      if board.in_bounds?(possible_pos)
        possible_moves << possible_pos.dup if opponent_occupied?(possible_pos)
      end
    end
    possible_moves
  end

  # Condense/make more readable
  def move_valid?(pos)
    return false unless board.in_bounds?(pos)
    return false if board.occupied?(pos)

    true
  end

  def opponent_occupied?(pos)
    board.occupied?(pos) &&
              board.grid[pos[0]][pos[1]].color != self.color
  end
end

class SteppingPiece < Piece
  # def initialize(position, board, color, moved)
  #   super
  # end

  def moves
    possible_moves = []
    x_cur, y_cur = position
    move_dirs.each do |vector|
      x_next = vector[0] + x_cur
      y_next = vector[1] + y_cur
      possible_pos = [x_next, y_next]
      possible_moves << possible_pos if move_valid?(possible_pos)
    end
    possible_moves
  end

  # Condense /make more readable
  def move_valid?(pos)
    return false unless board.in_bounds?(pos)
    return false if board.occupied?(pos) && board.grid[pos[0]][pos[1]].color == self.color
    true
  end
end

class Pawn < Piece
  attr_accessor :moved

  def initialize(position, board, color, moved = false)
    super(position , board, color, moved)
    @value = " P "
  end

  def moves
    final_move_set = []
    move_dirs.each do |new_pos|
      if new_pos[1] == position[1] #moving up/down
        #move is allowed if new_pos is unoccupied
        final_move_set << new_pos unless board.occupied?(new_pos)

      else #move diagonal
        final_move_set << new_pos if board.occupied?(new_pos) &&
          self.color != board.grid[new_pos[0]][new_pos[1]].color

        #move is allowed if new_pos is occupied
      end
    end
    final_move_set
  end

  def move_dirs
    vectors = []
    if color == :black #assumes white starts at bottom
      vectors = [[0,1], [1,1], [-1, 1]]
      vectors << [0,2] unless moved
    else
      vectors = [[0, -1], [-1, -1], [1, -1]]
      vectors << [0, -2] unless moved
    end

    possible_moves = []
    x_cur, y_cur = position

    vectors.each do |vector|
      x_next = vector[1] + x_cur
      y_next = vector[0] + y_cur
      possible_pos = [x_next, y_next]
      possible_moves << possible_pos if board.in_bounds?(possible_pos)
    end
    possible_moves
  end

  def dup(new_board)
    new_position = position.dup
    Pawn.new(new_position, new_board, color, moved)
  end
end

class King < SteppingPiece
  def initialize(position, board, color, moved = false)
    super(position , board, color, moved)
    @value = " K "
  end

  #Refactor into class constant
  def move_dirs
    [[0,1], [1,0], [0,-1], [-1,0], [-1,1], [1,1], [1,-1], [-1,-1]]
  end
end

class Knight < SteppingPiece
  def initialize(position, board, color, moved = false)
    super(position , board, color, moved)
    @value = " N "
  end

  #Refactor into class constant
  def move_dirs
    [[-1,2], [1,2], [2,1], [2,-1], [1,-2], [-1,-2], [-2,-1], [-2,1]]
  end
end

class Rook < SlidingPiece
  def initialize(position, board, color, moved = false)
    super(position , board, color, moved)
    @value = " R "
  end

  #Refactor into class constant
  def  move_dirs
    [[0,1], [1,0], [0,-1], [-1,0]]
  end
end


class Bishop < SlidingPiece
  def initialize(position, board, color, moved = false)
    super(position , board, color, moved)
    @value = " B "
  end

  #Refactor into class constant
  def move_dirs
    [[-1,1], [1,1], [1,-1], [-1,-1]]
  end
end

class Queen < SlidingPiece
  def initialize(position, board, color, moved = false)
    super(position , board, color)
    @value = " Q "
  end

  #Refactor into class constant
  def move_dirs
    [[0,1], [1,0], [0,-1], [-1,0], [-1,1], [1,1], [1,-1], [-1,-1]]
  end
end
