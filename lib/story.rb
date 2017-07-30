require_relative 'all_days.rb'
require_relative 'user_interface.rb'
require_relative 'combat.rb'
require_relative 'saves.rb'
require_relative "characters/player_character.rb"
require_relative "factories/random_enemy_factory.rb"
require_relative "story_modules/specific_encountered_enemies.rb"
require_relative "story_modules/pre_game_functions.rb"

class Story
  include UserInterface
  include SpecificEncounteredEnemies
  include AllDays
  include PreGameFunctions

  def initialize
    @saves = Saves.new
    @date = Date.new(1,6,1)
    instantiate_enemies
  end

  def day_board
    continue = false

    while !continue
      case @player_character.date
      when -1
        death_screen
        continue = true
      when 1
        case @player_character.hook
        when 1
          new_game
          @player_character.hook += 1
          @saves.autosave(@date, @player_character)
        when 2
        first_battle
        when 3
        new_day

        end
      #when 2
      #  day_two
      #  continue = true
      else
        main_menu
        puts "made it to else statement"
        gets.chomp
      end
    end
  end

  def new_day
    system "clear"
    print_line
    print_title("N E W  D A Y")
    print_line
    print_basic_message("#{@player_character.date} => #{@player_character.date + 1}")
    @date += @player_character.date
    @saves.autosave(@date, @player_character)
    @player_character.date += 1
    @player_character.hook = 1
  end

  def main_menu
    if @player_character.available_proficiency_points > 0 || @player_character.available_attribute_points > 0
      available_level_up = true
    else
      available_level_up = false
    end

    print_main_menu(@date, @player_character, available_level_up)
  end


end

=begin
character = Character.new("Audra", "Islander")
character.test_character
story = Story.new(character)
story.print_main_menu
=end