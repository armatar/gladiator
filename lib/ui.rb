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
  end

  module Interact
    include DisplayShortcuts

    def ask_question(question, options, tip)
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

    def display_combat_options(ally)
      print_line
      print_title('F I G H T')
      print_line
      puts "1. [ swing your #{ally.equipped_weapon[:name]} ] ".ljust(35) + "2. [ use a skill ]" 
      puts "3. [ cast a spell ] ".ljust(35) + "4. [ perform a combat maneuver ]"
      puts "5. [ use an item ] ".ljust(35) + "6. [ equip a weapon ]"
      print_line
    end

    def display_combat_info(ally, enemy, turn)
      puts "Turn: " + Paint["#{turn}", :white]
      puts "#{@ally.name.capitalize}'s HP: " + Paint["#{ally.hp}/#{ally.max_hp}".ljust(25), :white] + 
           "#{@ally.name.capitalize}'s Mana: " + Paint["#{ally.mana}/#{ally.max_mana}", :white]
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

    def display_activity_log
      print_line
      print_basic_message("Activity Log")
      print_line
      print_basic_message (@message)
      @message = ""
    end
  end

  module CharacterDisplay
    include DisplayShortcuts

    def display_character_sheet(character)
      system "clear"
      print_line
      puts Paint[character.name.capitalize, :white, :bold]
      print_line
      puts Paint["Race:".ljust(10), :white] + character.race.capitalize
      puts Paint["HP: ".ljust(10), :white] + character.hp.to_s.ljust(16) + Paint["AC: ".ljust(10), :white] + character.ac.to_s
      puts Paint["EXP: ".ljust(10), :white] + character.current_exp.to_s + "/" + character.exp_needed.to_s.ljust(14) +
           Paint["Fame: ".ljust(10), :white] + character.fame.to_s
      print_line
      display_ability_scores(character)
      print_line
      display_proficiencies(character)
      print_line
      puts Paint["BAB: ".ljust(15), :white] + sprintf("%+d", character.bab.to_s)
      puts Paint["CBM: ".ljust(15), :white] + sprintf("%+d", character.cbm.to_s)
      puts Paint["CBM Defense: ".ljust(15), :white] + sprintf("%+d", character.cbm_def.to_s)
      puts Paint["Sword and Shield: ".ljust(20), :white] + "Attack: " + character.one_hand_atk.to_s.ljust(10) + 
                                                           "Damage: " + character.one_hand_damage.to_s
      puts Paint["Dual Wielding: ".ljust(20), :white] + "Attack: " + character.dual_wield_atk.to_s.ljust(10) + 
                                                        "Damage: " + character.dual_wield_damage.to_s
      puts Paint["Two Handed: ".ljust(20) , :white]+ "Attack: " + character.two_hand_atk.to_s.ljust(10) + 
                                                      "Damage: " + character.two_hand_damage.to_s
      puts Paint["Unarmed: ".ljust(20) , :white]+ "Attack: " + character.unarmed_atk.to_s.ljust(10) + 
                                                  "Damage: " + character.unarmed_damage.to_s                                                                                                                                                           
      print_line
      puts Paint["Magic Resist: ".ljust(10), :white] + sprintf("%+d", character.mag_resist.to_s).ljust(10) +
           Paint["Spell Failure: ".ljust(10), :white] + character.spell_failure_chance.to_s + "%"
      puts Paint["Magic DC: ".ljust(10), :white] + "Level 1: " + character.get_magic_dc(1).to_s.ljust(5) +
                                    "Level 2: " + character.get_magic_dc(2).to_s.ljust(5) +
                                    "Level 3: " + character.get_magic_dc(3).to_s.ljust(5) +
                                    "Level 4: " + character.get_magic_dc(4).to_s.ljust(5) +
                                    "Level 5: " + character.get_magic_dc(5).to_s
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
      puts Paint["Wealth: ".ljust(10), :white] + @wealth.to_s
      print_line
      puts Paint["press [enter] to continue..."]
      gets.chomp
    end

    def display_proficiencies(character)
      puts Paint["Skill".ljust(23) + "Proficency", :bold]
      puts "1. Sword and Shield: ".ljust(23) + "x " * character.one_hand_prof + 
            "_ " * (character.max_proficency - character.one_hand_prof)
      puts "2. Dual Wielding: ".ljust(23) + "x " * character.dual_wield_prof + 
           "_ " * (character.max_proficency - character.dual_wield_prof)
      puts "3. Two Handed: ".ljust(23) + "x " * character.two_hand_prof + 
           "_ " * (character.max_proficency - character.two_hand_prof)
      puts "4. Magic: ".ljust(23) + "x " * character.magic_prof + 
           "_ " * (character.max_proficency - character.magic_prof)
      puts "5. Unarmed: ".ljust(23) + "x " * character.unarmed_prof + 
           "_ " * (character.max_proficency - character.unarmed_prof)
    end

    def display_ability_scores(character)
      puts Paint["Attribute".ljust(18) + "Score".ljust(10) + "Modifier", :bold]
      puts "Strength: ".ljust(18) + character.str.to_s.ljust(10) + sprintf("%+d", character.str_modifier.to_s)
      puts "Dexterity: ".ljust(18) + character.dex.to_s.ljust(10) + sprintf("%+d", character.dex_modifier.to_s)
      puts "Constitution: ".ljust(18) + character.con.to_s.ljust(10) + sprintf("%+d", character.con_modifier.to_s)
      puts "Magic: ".ljust(18) + character.mag.to_s.ljust(10) + sprintf("%+d", character.mag_modifier.to_s)
      puts "Charisma: ".ljust(18) + character.cha.to_s.ljust(10) + sprintf("%+d", character.cha_modifier.to_s)
    end

    def update_stats(character, message)
      system "clear"
      puts message
      character.update_modifiers
      message = ""
      print_line
      print_title('A S S I G N  Y O U R  S T A T S')
      print_line
      display_ability_scores(character)

      print_stat_and_label("\nCurrent Points to Assign: ", character.assign_attribute_points.to_s)
      print_line
    end

    def assign_proficiencies(character, message)
      system "clear"
      puts message
      print_line
      print_title('A S S I G N  Y O U R  P R O F I C I E N C I E S')
      print_line
      display_proficiencies(character)
      message = ""

      print_stat_and_label("\nCurrent Points to Assign: ", character.assign_proficiency_points.to_s)
      print_line
    end
  end

  module StoryDisplay
    include DisplayShortcuts

    def print_main_menu(date, character)
      print_line
      print_title("M A I N  M E N U")
      print_line
      date += character.date
      puts "> " + Date::MONTHNAMES[date.month] + " " + date.day.to_s + ", Year " + date.year.to_s
      print_line
      puts "1. [ train ] ".ljust(35) + "2. [ check arena schedule ]" 
      puts "3. [ cast a spell ] ".ljust(35) + "4. [ perform a combat maneuver ]"
      puts "5. [ save your game ] ".ljust(35) + "6. [ load a save ]"
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