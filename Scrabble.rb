

require 'minitest/autorun'

#This set of two classes will implement and test methods for calculating the score of the game "Scrabble"


class ScrabbleTest < Minitest::Test
# This class will test if the written methods are working accordingly. 

  def test_counts_points_word
    #This method tests if the counts method is working properly
    scrabble = Scrabble.new
    assert_equal scrabble.counts("cabbage", "1005", "horizontal") , 14 
  end

  def test_score_table_is_empty
    #This method tests if SCORETABLE is empty
    refute_empty Scrabble::SCORETABLE
  end

  def test_word_is_nil
    #This method tests what happens if the player tries to play nil as a word
    scrabble = Scrabble.new
    assert_equal scrabble.counts(nil, "0000", "vertical"), 0
  end

  def test_word_is_empty_string
    #This method tests what happens if the player tries to play an empty string
    scrabble = Scrabble.new
    assert_equal scrabble.counts("", "0000", "horizontal"),0
  end

  def test_character_not_in_scoretable
    #This method tests what happens if the player tries to play a word with a character not contained in SCORETABLE
    scrabble = Scrabble.new
    assert_equal scrabble.counts("a$$$", "0000", "vertical"), 0
  end	
  
  def test_argument_is_not_string
    #This method tests what happens if the player tries to play something other than a String as a word
    scrabble = Scrabble.new
    assert_equal scrabble.counts(8.43, "0000", "vertical"),0
  end

  def test_counts_according_to_board
    #This method tests placing different words in different positions of the board that contain different combinations
    #of word and letter multipliers.
    scrabble = Scrabble.new
    assert_equal scrabble.counts_according_to_board("paramedic", "0000", "horizontal"),153
    assert_equal scrabble.counts_according_to_board("cabbage", "0707", "horizontal"),30
    assert_equal scrabble.counts_according_to_board("almond", "0507", "horizontal"),15
    assert_equal scrabble.counts_according_to_board("almond", "0003", "vertical"),18
  end

end

class Scrabble 
  #This class contains methods to calculate the scoring of the game Scrabble based on the value associated with each letter, 
  #the position it was placed on the board, and the positions where other letters were placed before in the same game.
  
  @@wordmultipliers_used #This variable will store the positions played in each game of Scrabble. 
                         #It is important to store them because the position-based multipliers only work at the first 
                         #time letters are placed in each position.

  def initialize
    @@wordmultipliers_used = Array.new
  end
  
  #positions that multiply word score by two
  WORDMULTIPLIERS2 = 	
    [
      "0101" , "0202"  , "0303" , "0404" , "0410" , "0311" ,"0212" ,"0113" ,"0707" , "1004" ,"1103" ,"1202" ,"1301" ,"1010" ,"1111" ,"1212" ,"1313" 	
    ]

  #positions that multiply word score by three
  WORDMULTIPLIERS3 = 
    [
      "0000" , "0007" , "0014" , "0700" , "0714" , "1400" , "1407" , "1414"  
    ]
  #positions that multiply letter score by two  
  LETTERMULTIPLIERS2 = 
    [
      "0003" , "0011" , "0206" ,"0208" , "0300" , "0307" , "0314" ,"0602" ,"0606" ,"0608" ,"0612" ,"0703" ,"0711" ,"0802" ,"0806" ,"0808" ,"0812" ,"1100" ,"1107" ,"1114" ,"1206" ,"1208" ,"1403" ,"1411" 
    ]
  #positions that multiply word score by three
  LETTERMULTIPLIERS3 = 
    [
      "0105" , "0109" , "0501" , "0505" , "0509" ,"0513" , "0901" ,"0905" ,"0909" ,"0913" ,"1305" ,"1309" 
    ]

  #hash with the values for each letter
  SCORETABLE =  
    {
      "A" => 1, "B" => 3, "C" => 3, "D" => 2,
      "E" => 1, "F" => 4, "G" => 2, "H" => 4,
      "I" => 1, "J" => 8, "K" => 5, "L" => 1,
      "M" => 3, "N" => 1, "O" => 1, "P" => 3,
      "Q" => 10, "R" => 1, "S" => 1, "T" => 1,
      "U" => 1, "V" => 4, "W" => 4, "X" => 8,
      "Y" => 4, "Z" => 10
    }

  def counts_according_to_board(word, position, orientation)
  	#This method assumes the player is sure the chosen word fits in the board in the chosen orientation.
    #The score for the word placed is calculated based on whether the positions it's been placed on contains any 
    #word multipliers. If they do and it's the first time placing letters on them, the word score is multiplied. 

    @@wordmultipliers_used
    word_multiplier = 1
    initial_position = position
    @position = position
    word.length.times do
      if WORDMULTIPLIERS2.include?(position) && ( @@wordmultipliers_used.include?(position) == false)
        word_multiplier *= 2
        @@wordmultipliers_used.push(position)
      end
      if WORDMULTIPLIERS3.include?(position) && (@@wordmultipliers_used.include?(position) == false)
        word_multiplier *= 3
        @@wordmultipliers_used.push(position)
      end
      position = update(position,orientation)
 
    end 
    return counts(word, initial_position, orientation)*word_multiplier
  end	

  def counts(word, position, orientation)
    #This method counts how many points each word is worth based on the score hash 
    #and whether the letters have been placed on letter multipliers for the first time.

    @@wordmultipliers_used
    sum = 0
    if (word != nil) && (word != "") && (word.is_a? String)
      word = word.upcase
      characters = word.split("")
      characters.each do |i|
        if SCORETABLE.key?(i)
          sum += (SCORETABLE[i] * finds_letter_multiplier(position))
          position = update(position, orientation)
        else
          puts "The character #{i} is invalid"
          sum = 0
          break
        end
      end   	  
    elsif ((word.is_a? String) == false)	
      puts "The argument was not a String"
    end
    return sum		
  end

  def finds_letter_multiplier(position)
    #This method returns a multiplier according to which position the letter has been placed and whether it's the 
    #first time putting a letter on it in this game.
    @@wordmultipliers_used
    if (LETTERMULTIPLIERS2.include? position) && (@@wordmultipliers_used.include?(position) == false)
      @@wordmultipliers_used.push(position)
      return 2
    elsif (LETTERMULTIPLIERS3.include? position) && (@@wordmultipliers_used.include?(position) == false)
      @@wordmultipliers_used.push(position)	
      return 3
    else
      return 1
    end  	
  end	

  def update(position, orientation)
    #This method updates the position in which the next letter will be placed according to the position of the 
    #previous letter and to the orientation chosen by the player.
    x = position[0..1].to_i
    y = position[2..3].to_i
    position_x = ""
    position_y = ""

    if (orientation.casecmp "horizontal") == 0
      y += 1
    else
      x +=1
    end

    if x<10
      position_x = "0" + x.to_s
    else
      position_x = x.to_s 
    end
      
    if y<10
      position_y = "0" + y.to_s
    else
      position_y = y.to_s
    end
      
    position = position_x + position_y

    return position
  end
end

