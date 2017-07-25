require_relative "player_character.rb"
require_relative 'interface.rb'
require_relative "story.rb"
require_relative "saves.rb"

class Main
  include Interface

  def initialize
    @saves = Saves.new
  end

  def start
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
        @story = Story.new(@player_character)
        @story.day_board
      elsif answer == "load game" || answer == "load"
        successful = @saves.load_character
        if successful
          @player_character = successful
          @story = Story.new(@player_character)
          @story.day_board
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
    @player_character.initial_character
    set_stats
    set_proficiencies
    @player_character.update_modifiers
    @player_character.calculate_first_hp
    @player_character.calculate_full_stats
    display_character_sheet(@player_character)


  end

  def set_proficiencies
    continue = false
    message = ""
    @player_character.get_min_and_max_stats

    while !continue
      assign_proficiencies(@player_character, message)
      tip = "Type the number of the skill you want to update.\n" +
            "Tip! Type 'confirm' to save changes."
      answer = ask_question("Which skill do you want to update?", false, tip)
      if answer == "confirm"
        if double_check
          continue = true
        end
      else
        message = @player_character.update_proficiencies(answer)
      end
    end
  end

  def set_stats
    continue = false
    message = ""
    while !continue
      tip = ""
      update_stats(@player_character, message)
      tip = "Type 'confirm' to save changes."
      if @player_character.level == 1
        tip += "\nTip! 8 low, 18 high -- this doesn't take into account racial bonuses"
      end
      answer = ask_question("Which attribute do you want to edit?", false, 
                   tip)
      if answer == "confirm"
        if double_check
          continue = true
        end
      else
        message = @player_character.adjust_stats(answer)
      end
    end
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
end