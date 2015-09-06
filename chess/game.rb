require './board.rb'
require './player.rb'
require 'byebug'

class Game
  attr_reader :board, :display, :player1, :player2, :current_player

  def initialize
    @board = Board.new
    @display = Display.new(@board)
    @player1 = Player.new("Player 1", @display, @board, :white)
    @player2 = Player.new("Player 2", @display, @board, :black)
    @current_player  = player1
   end

  def run
    until board.checkmate?(current_player.color)
      begin
        take_turn(current_player)

        switch_player


      rescue InvalidMoveError => e
        puts e.message
        sleep(3)
        retry
      end
    end
    puts "game over!"
  end

  def switch_player
    (current_player == player1) ?
      @current_player = player2 : @current_player = player1
  end

  def take_turn(player)
    display.render
    print current_player.name
    puts "'s turn!"
    puts
    puts "In check!" if board.in_check?(current_player.color)

    begin
      start_pos = player.get_move
      if (board[start_pos].color != player.color)
        raise InvalidMoveError.new("Not your piece!")
      end
    rescue InvalidMoveError => e
      display.reset_selected
      puts e.message
      sleep(1)
      retry
    end

    end_pos = player.get_move
    move(start_pos, end_pos) if valid_move?(start_pos, end_pos)
  end



  def valid_move?(start_pos, end_pos)
    current_piece = board[start_pos]

    # get current_piece.moves if in_check? remove moves that still result
    #in_check
    #if result of above is [], raise moves error and end game

    allowable_moves = current_piece.moves

    if !allowable_moves.include?(end_pos)
      raise InvalidMoveError.new("Can't move there")
    end

    allowable_moves = board.get_out_of_check(current_piece)
    # current_piece.moves.each do |move|
    #   check_board = board.dup
    #   check_board.move(current_piece.position, move)
    #   if check_board.in_check?(current_piece.color)
    #     allowable_moves.delete(move)
    #   end
    # end

    if !allowable_moves.include?(end_pos)
      raise InvalidMoveError.new("Still in check!")
    end

    true
  end

  def move(start_pos, end_pos)
    board.move(start_pos, end_pos)
  end
end

class InvalidMoveError < StandardError
end



if $PROGRAM_NAME == __FILE__
  g = Game.new
  g.run
end
