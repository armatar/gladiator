require_relative 'user_interface.rb'
require_relative 'combat.rb'
require_relative 'saves.rb'
require_relative "characters/player_character.rb"
require_relative "factories/random_enemy_factory.rb"
require_relative "story_modules/specific_encountered_enemies.rb"

class Story
  include UserInterface
  include SpecificEncounteredEnemies

  def initialize
    @saves = Saves.new
    @date = Date.new(1,6,1)
    instantiate_enemies
  end

  def start_game
    continue = false
    while !continue
      system "clear"
      print_line
      print_title("W E L C O M E  to [ G L A D I A T O R ] !")
      print_line
      string = "[new game]".ljust(20) + "[load game]".ljust(20) + "[exit]"
      answer = ask_question(string, false, false)
      if answer == "new game" || answer == "new"
        system "clear"
        create_character
        system "clear"
        day_board
      elsif answer == "load game" || answer == "load"
        successful = @saves.load_character
        if successful
          @player_character = successful
          day_board
        else
        end
      elsif answer == "exit"
        continue = true
      else
        print_error_message("Please answer with either 'load', 'new', or 'exit'.")
      end
    end
  end

  def create_character
    name_and_race = get_name_and_race

    name = name_and_race[0]
    race = name_and_race[1]

    @player_character = PlayerCharacter.new(name, race)
    @player_character.create_character
    @player_character.set_stats
    @player_character.set_proficiencies
    @player_character.calculate_initial_stats
    @player_character.display_character_sheet_from_character
  end

  def get_name_and_race
    continue = false
    print_line
    print_title("C R E A T E  Y O U R  C H A R A C T E R")
    print_line
      while !continue
        name = ask_question("Gladiator, what is your name?", false, false)
        if name == ""
          print_error_message("You have to enter #{Paint["something", :bold]}.\n")
        else
          continue = true
        end
      end

      continue = false
      options = ["Drai", "Relic", "Tiersmen", "Aloiln"]
      tip = "Type 'help [race]' for details!"

      while !continue
        race = ask_question("From where do you hail?", options, tip)
          if race == "help [race]"
            string = "\n> Lol I didn't mean literally '[race]'. \n" +
                  "> Replace that with the race you want information for. \n" +
                  "> Example: help Islander \n"
            print_error_message(string)
          elsif race == "help aloiln"
            string = "\n> Some description here, idk yet. \n" +
                       "> +whatever, -whatever\n"
            print_tooltip(string)
          elsif race == "help tiersmen"
            string = "\n> Some description here, idk yet. \n" +
                       "> +whatever, -whatever\n"
            print_tooltip(string)
          elsif race == "help relic"
            string = "\n> Some description here, idk yet. \n" +
                       "> +whatever, -whatever\n"
            print_tooltip(string)
          elsif race == "help drai"
            string = "\n> Some description here, idk yet. \n" +
                       "> +whatever, -whatever\n"
            print_tooltip(string)
          elsif race == "drai" || race == "relic" || race == "tiersmen" || 
                        race =="aloiln"
            continue = true
          else
            print_error_message("\n> Please pick from the provided options. \n")
        end
      end
      
      continue = false
      system "clear"
    array_to_return = [name, race]
    return array_to_return
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
      when 2
        day_two
        continue = true
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

  def new_game
    system "clear"

    string = "One month ago to the date, the greatest prophet of this age, the seer, \n" +
             "Iluvia, became a vessel to the God of War, Mythros. He said that he had become \n" +
             "fond of the gladiator games that nobility played and wished to see more. \n" +
             "In order to facilite that, Mythros proclaimed that in three years time, he \n" +
             "would hold a tournament himself to find the greatest gladiator mankind had \n" +
             "to offer. The victor would win from him a boon -- whatever his heart desires. \n \n"

    case @player_character.race
    when "drai"
      string += "You are of the cunning Drai people from a town in the far east \n" +
               "where the deserts are trecherous and the sun is blistering. \n"
    when "relic"
      string += "You are one of the Relic -- a race of people who value the seeking \n" +
               "and preserving of knowledge over everything else. \n"
    when "tiersmen"
      string += "You a Tiersmen, proud and strong. The land you know is the frigid \n" +
               "north where the King's law is weak, and the rule of clans is the norm. \n"
    when "aloiln"
      string += "Your ancestors were sailors and pirates and so you too are called \n" +
               "Aloiln. The many islands to the west is where you grew up, but the \n" +
               "only place you'd truly call home is the sea. \n"
    end

    string += "You, like many others after hearing the Gladiator Promise, have \n" +
              "decided to begin your journey as a Gladiator in the hopes of winning \n" +
              "the Godly wish. Many will perish on the sands of the arena, a sacrifice \n" +
              "to the Bloody God Mythros himself.\n"   

    string += "But you -- you're special, aren't you? A unique among hordes of others? \n\n" +
              "Well, I suppose we'll see."

    write_to_screen(string)
  end

  def first_battle
    system "clear"

    string = "You stand under the blazing sun, the sand beneath your feet, as the roars \n" +
             "of the crowd around you ring in your ears. In the town of Leander, they do not care \n" +
             "if you have no coin or name for all they wish to see is blood. This is where all \n" +
             "gladiators must begin. Though this is only your first fight, you know well that it \n" +
             "may also be your last. \n\n"

    string += "On the other side of the arena, your opponent comes in to view. Like you, he \n" +
              "is ill equipped, perhaps as new to the arena as you. His eyes wander the crowd, \n" +
              "wide and nervous, but as he turns to look at you, he swallows and squares his \n" +
              "shoulders. His gaze seems to say that he will not die this day.\n\n"

    string += "A horn suddenly blares in the distance, signaling the beginning of the battle..."

    write_to_screen(string)

    first_fight = Combat.new(@player_character, @first_enemy)

    result = first_fight.turn_based_combat
    if result == "dead"
      @player_character.date = -1
      @player_character.hook = -1
      return false
    elsif result == "kill"
      system "clear"

      string = "Your enemy falls before you, food for the carrion that circle overhead. The crowd \n" +
               "cheers but his blood stains your hands.\n\n"
    elsif result == "spare"
      system "clear"

      string = "You allow your enemy to live, much to the displeasure of the crowd. But as the \n"
               "nameless man looks up at you, you find gratitude in his eyes.\n"
    end

    string += "Your head begins to swim, exhaustion and draining adrenline stealing the remainder \n" +
               "of your strength. You were victorious, but "

    write_to_screen(string)
    @player_character.hook += 1

  end

  def day_two
    main_menu
    gets.chomp
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