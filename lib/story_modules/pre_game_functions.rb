module PreGameFunctions
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
end