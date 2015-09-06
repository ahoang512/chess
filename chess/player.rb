class Player
  include Cursorable

  attr_reader :display, :board, :color, :name

  def initialize(name, display, board, color)
    @name = name
    @display = display
    @board = board
    @color = color
  end

  def get_move
    move = nil
    until move
      move = display.get_input
    #  debugger
    #  move = nil unless valid_piece?(move)
      display.render
      print name
      puts "'s turn!"
      puts
      puts "In check!" if board.in_check?(color)
      #end_pos = display.get_input
      #move = [start_pos, end_pos]
    end
    move
  end


end
