require 'paint'

module UI

  module DisplayShortcuts
    def print_line
      puts "-" * 68
    end

    def new_line
      print "\n"
    end

    def print_stat_and_label(label, stat)
      puts "#{Paint["#{label}", :white]}: ".ljust(28) + "[ #{stat} ]"
    end

    def print_error_message(string)
      puts Paint[string, :white]
    end

    def print_tooltip(string)
      puts Paint[string, :white]
    end

    def print_title(string)
      puts Paint[string, :white, :bold]
    end

    def print_basic_message(string)
      puts Paint[string, :white]
    end

    def write_to_screen(string)
      puts Paint[string, :white]
      print_line
      puts Paint["press [enter] to continue..."]
      gets.chomp
    end

    def roll_dice(min, max, number_of_dice)
      dice_roll = 0
      number_of_dice.times do
        dice_roll += rand(min..max)
      end
      return dice_roll
    end

  end

  module Interact
    include DisplayShortcuts

    def ask_question(question, options=false, tip=false)
      puts Paint[question]
      print_line
      if options != false
        options.each do | option |
          print Paint["[" + option + "]".ljust(5)]
        end
        puts ""
        print_line
      end
      if tip != false
        puts Paint["Tip! " + tip, :white]
        print_line
      end
      print "> "
      answer = gets.chomp
      print_line
      answer = answer.downcase
      return answer
    end

    def double_check
      options = ["yes", "no"]
      loop do
        confirm_answer = ask_question("Are you sure?", options, false)
        if confirm_answer == "yes" || confirm_answer == "y"
          return true
        elsif confirm_answer == "no" || confirm_answer == "n"
          creturn false
        else
          puts Paint["\nPlease answer 'yes', 'y', 'no', or 'n'.\n", :white]
        end
      end
    end

    def double_check_specific(string)
      options = ["yes", "no"]
      loop do
        confirm_answer = ask_question("Are you sure #{string}?", options, false)
        if confirm_answer == "yes" || confirm_answer == "y"
          return true
        elsif confirm_answer == "no" || confirm_answer == "n"
          return false
        else
          puts Paint["\nPlease answer 'yes', 'y', 'no', or 'n'.\n", :white]
        end
      end
    end
  end

  module ItemDisplay
    include DisplayShortcuts

    def display_item(item_key, item_value)
      count = 1
      dice = 0
      print_stat_and_label(Paint["Name: ", :white, :bold], item_key.capitalize)
      item_value.each do |key, value|
        if key == :dice
          dice = value
        elsif key == :number_of_dice
          print "#{Paint["Damage", :white]}: #{value}d#{dice}".ljust(30)
          if count.even?
            print "\n"
          end
          count += 1
        elsif key == :price
          print "#{Paint[key.capitalize, :white]}: $#{value.to_s.capitalize}".ljust(30)
          if count.even?
            print "\n"
          end
          count += 1
        elsif key == :enchantment
          if value == 0
          else
            print "#{Paint[key.capitalize, :white]}: +#{value.to_s.capitalize}".ljust(30)
            if count.even?
              print "\n"
            end
            count += 1
          end
        elsif key == :defense_bonus
          print "#{Paint["AC Bonus", :white]}: #{sprintf("%+d", value.to_s.capitalize)}".ljust(30)
          if count.even?
            print "\n"
          end
          count += 1
        elsif key == :name
        else
          print "#{Paint[key.capitalize, :white]}: #{value.to_s.capitalize}".ljust(30)
          if count.even?
            print "\n"
          end
          count += 1
        end
      end
      if count.even?
        print "\n"
      end
    end

    def display_list_of_items(item_list)
      item_list.each_pair do |key, value|
        print_line
        display_item(key, value)
        print_line
      end
    end

    def display_weapons(list_of_items)
      print_line
      print_title("W E A P O N S")
      print_line
      list_of_items.each_pair do |key, value|
        if value[:type] == "1-hand weapon" || value[:type] == "2-hand weapon" ||
           value[:type] == "unarmed weapon" || value[:type] == "staff" ||
           value[:type] == "dual wield weapon"
          display_item(key, value)
          print_line
        end
      end
    end

    def display_shields(list_of_items)
      print_line
      print_title("S H I E L D S")
      print_line
      list_of_items.each_pair do |key, value|
        if value[:type] == "shield"
          display_item(key, value)
          print_line
        end
      end
    end

    def display_usable_items(list_of_items)
      shield_counter = 0
      print_line
      print_title("I T E M S")
      print_line
      list_of_items.each_pair do |key, value|
        if value[:type] == "healing" || value[:type] == "utility"
          display_item(key, value)
          print_line
        elsif value[:type] == "shield"
          shield_counter += 1
        end
      end
      if shield_counter != 0
        puts Paint["Equip a Shield".ljust(20), :white] + "Shield Count: " + Paint["#{shield_counter}", :white]
        print_line
      end
    end
  end

  module CombatDisplay
    include DisplayShortcuts

    def display_combat_options(player_character)
      print_line
      print_title('F I G H T')
      print_line
      puts "1. [ swing your #{player_character.equipped_weapon[:name]} ] ".ljust(35) + "2. [ use a skill ]" 
      puts "3. [ cast a spell ] ".ljust(35) + "4. [ perform a combat maneuver ]"
      puts "5. [ use an item ] ".ljust(35) + "6. [ equip a weapon ]"
      print_line
    end

    def display_combat_info(player_character, enemy, turn)
      puts "Turn: " + Paint["#{turn}", :white]
      puts "#{player_character.name.capitalize}'s HP: " + Paint["#{player_character.hp}/#{player_character.max_hp}".ljust(25), :white] + 
           "#{player_character.name.capitalize}'s Mana: " + Paint["#{player_character.mana}/#{player_character.max_mana}", :white]
      puts "#{@enemy.name.capitalize}'s HP: " + Paint["#{enemy.hp}/#{enemy.max_hp}".ljust(25), :white] + 
           "#{@enemy.name.capitalize}'s Mana: " + Paint["#{enemy.mana}/#{enemy.max_mana}", :white]
      print_line
    end

    def display_spell_list(spell_list)
      print_line
      print_title("S P E L L S")
      print_line
      spell_list.each_pair do |key, value|
        puts Paint[key.ljust(25), :white] + Paint["Mana Cost: ", :underline] + Paint[value[:mana_cost].to_s, :underline]
        puts value[:description]
        new_line
      end
      print_line
    end

    def display_activity_log(message)
      print_line
      print_basic_message("Activity Log")
      print_line
      print_basic_message (message)
      message = ""
    end
  end

  module CharacterDisplay
    include DisplayShortcuts

    def display_character_sheet
      system "clear"
      print_line
      puts Paint[@name.capitalize, :white, :bold]
      print_line
      puts Paint["Race:".ljust(10), :white] + @race.capitalize
      puts Paint["HP: ".ljust(10), :white] + @hp.to_s + "/" + @max_hp.to_s.ljust(16) + 
          Paint["Mana: ".ljust(10), :white] + @mana.to_s + "/" + @max_mana.to_s
      puts Paint["AC: ".ljust(10), :white] + @ac.to_s
      #puts Paint["EXP: ".ljust(10), :white] + @current_exp.to_s + "/" + @exp_needed.to_s.ljust(14) +
           #Paint["Fame: ".ljust(10), :white] + @fame.to_s
      print_line
      display_ability_scores
      print_line
      display_proficiencies
      print_line
      puts Paint["BAB: ".ljust(15), :white] + sprintf("%+d", @bab.to_s)
      puts Paint["CBM: ".ljust(15), :white] + sprintf("%+d", @cbm.to_s)
      puts Paint["CBM Defense: ".ljust(15), :white] + sprintf("%+d", @cbm_def.to_s)
      puts Paint["Sword and Shield: ".ljust(20), :white] + "Attack: " + @one_hand_atk.to_s.ljust(10) + 
                                                           "Damage: " + @one_hand_damage.to_s
      puts Paint["Dual Wielding: ".ljust(20), :white] + "Attack: " + @dual_wield_atk.to_s.ljust(10) + 
                                                        "Damage: " + @dual_wield_damage.to_s
      puts Paint["Two Handed: ".ljust(20) , :white]+ "Attack: " + @two_hand_atk.to_s.ljust(10) + 
                                                      "Damage: " + @two_hand_damage.to_s
      puts Paint["Unarmed: ".ljust(20) , :white]+ "Attack: " + @unarmed_atk.to_s.ljust(10) + 
                                                  "Damage: " + @unarmed_damage.to_s                                                                                                                                                           
      print_line
      puts Paint["Magic Resist: ".ljust(10), :white] + sprintf("%+d", @mag_resist.to_s).ljust(10) +
           Paint["Spell Failure: ".ljust(10), :white] + @spell_failure_chance.to_s + "%"
      puts Paint["Magic DC: ".ljust(10), :white] + "Level 1: " + get_magic_dc(1).to_s.ljust(5) +
                                    "Level 2: " + get_magic_dc(2).to_s.ljust(5) +
                                    "Level 3: " + get_magic_dc(3).to_s.ljust(5) +
                                    "Level 4: " + get_magic_dc(4).to_s.ljust(5) +
                                    "Level 5: " + get_magic_dc(5).to_s
      print_line
      puts Paint["press [enter] to view spells and inventory..."]
      gets.chomp
      system "clear"
      print_line
      puts Paint["Spells", :white]
      print_line
      print_line
      puts Paint["Inventory", :white]
      print_line
      display_list_of_items(@inventory)
      print_line
      puts Paint["Wealth: ".ljust(10), :white] + @wealth.to_s
      print_line
      puts Paint["press [enter] to continue..."]
      gets.chomp
    end

    def display_proficiencies
      puts Paint["Skill".ljust(23) + "Proficency", :bold]
      puts "1. Sword and Shield: ".ljust(23) + "x " * @one_hand_prof + 
            "_ " * (@max_proficency - @one_hand_prof)
      puts "2. Dual Wielding: ".ljust(23) + "x " * @dual_wield_prof + 
           "_ " * (@max_proficency - @dual_wield_prof)
      puts "3. Two Handed: ".ljust(23) + "x " * @two_hand_prof + 
           "_ " * (@max_proficency - @two_hand_prof)
      puts "4. Magic: ".ljust(23) + "x " * @magic_prof + 
           "_ " * (@max_proficency - @magic_prof)
      puts "5. Unarmed: ".ljust(23) + "x " * @unarmed_prof + 
           "_ " * (@max_proficency - @unarmed_prof)
    end

    def display_ability_scores
      puts Paint["Attribute".ljust(18) + "Score".ljust(10) + "Modifier", :bold]
      puts "Strength: ".ljust(18) + @str.to_s.ljust(10) + sprintf("%+d", @str_modifier.to_s)
      puts "Dexterity: ".ljust(18) + @dex.to_s.ljust(10) + sprintf("%+d", @dex_modifier.to_s)
      puts "Constitution: ".ljust(18) + @con.to_s.ljust(10) + sprintf("%+d", @con_modifier.to_s)
      puts "Magic: ".ljust(18) + @mag.to_s.ljust(10) + sprintf("%+d", @mag_modifier.to_s)
      puts "Charisma: ".ljust(18) + @cha.to_s.ljust(10) + sprintf("%+d", @cha_modifier.to_s)
    end

    def assign_attributes_header(message)
      system "clear"
      puts message
      update_modifiers
      message = ""
      print_line
      print_title('A S S I G N  Y O U R  S T A T S')
      print_line
      display_ability_scores

      print_stat_and_label("\nCurrent Points to Assign: ", @available_attribute_points.to_s)
      print_line
    end

    def assign_proficiencies_header(message)
      system "clear"
      puts message
      print_line
      print_title('A S S I G N  Y O U R  P R O F I C I E N C I E S')
      print_line
      display_proficiencies
      message = ""

      print_stat_and_label("\nCurrent Points to Assign: ", @available_proficiency_points.to_s)
      print_line
    end
  end

  module StoryDisplay
    include DisplayShortcuts

    def print_main_menu(date, character, availble_points)
      system "clear"
      print_line
      print_title("M A I N  M E N U")
      print_line
      date += character.date
      puts "> " + Date::MONTHNAMES[date.month] + " " + date.day.to_s + ", Year " + date.year.to_s
      print_line
      puts "1. [ train ] ".ljust(35) + "2. [ check arena schedule ]" 
      puts "3. [ go into town ] ".ljust(35) + "4. [ not sure yet ]"
      puts "5. [ save your game ] ".ljust(35) + "6. [ load a save ]"
      if availble_points
        puts "7. [ " + Paint["level up !!", :red, :bold] + " ]"
      end
    end
  end

  module CBMDisplay
    include DisplayShortcuts

    def display_CBM(cbm_list, grappled)
      print_line
      print_title("Combat Maneuvers")
      print_line
      cbm_list.each_pair do |key, value|
        if grappled
          if key == "pin" || key == "release"
            print_stat_and_label(key, value[:description])
          end
        else
          if key == "pin" || key == "release"
          else
            print_stat_and_label(key, value[:description])
          end
        end
      end
      print_line
    end
  end

  module FinalScreens

    def death_screen
      system "clear"
      print_line
      puts "You have died! Your journey has come to an end."
      print_line
      gets.chomp
    end

    def victory_screen
    end
  end
end