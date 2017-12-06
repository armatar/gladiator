require_relative "player_character_modules/level_up_calculations.rb"
require_relative "../character.rb"
require_relative "player_character_modules/player_combat.rb"

class PlayerCharacter < Character
  #the class that manages the actual player character

  include LevelUpCalculations
  include PlayerCombat

  attr_accessor :date, :hook, :sponsor
  attr_reader :current_exp, :exp_needed, :wealth, :fame, :available_proficiency_points
  attr_reader :total_proficiency_points, :available_attribute_points

  def initialize(name, race)
    super(name, race)
    @date = 1
    @hook = 1
  end

  #maybe I don't need this, idk. But it's here
  #so that I don't just start creating a character
  #in the initialize
  def create_character
    get_min_and_max_stats
    character_base
    player_base
    add_spell_to_known_spells("ear-piercing scream", @full_spell_list["ear-piercing scream"])
  end

  #base character stats so that every number that should 
  #be set to something is actually set.
  def player_base
    @wealth = 0
    @fame = 0
    @current_exp = 0
    @exp_needed = 100
    @available_attribute_points = 30
    @total_proficiency_points = 1
    @available_proficiency_points = 1
  end

  #makes sure that the adjustment you want to make to a stat is valid
  def get_updated_stat(stat_number, max, min, points)
    if add_or_subtract
      not_too_high = false
      number_to_adjust = get_number_to_adjust(true, points)
      while !not_too_high
        calculation = stat_number + number_to_adjust
        if calculation > max
          print_error_message("\nYour proficiency can't go that high.\nThe highest is #{max}\n")
          number_to_adjust = get_number_to_adjust(false, points)
        else
          return number_to_adjust
        end
      end
    else
      number_to_adjust = get_number_to_adjust(false, points)
      not_too_low = false
      while !not_too_low
        calculation = stat_number - number_to_adjust
        if calculation < min
          print_error_message("\nYour attribute can't go that low.\nThe lowest is #{min}\n")
          number_to_adjust = get_number_to_adjust(false, points)
        else
          return -(number_to_adjust)
        end
      end
    end
  end

  def set_proficiencies
    continue = false
    message = ""
    get_min_and_max_stats

    while !continue
      assign_proficiencies_header(message)
      tip = "Type the number of the skill you want to update.\n" +
            "Tip! Type 'confirm' to save changes."
      answer = ask_question("Which skill do you want to update?", false, tip)
      if answer == "confirm"
        if double_check
          continue = true
        end
      else
        message = update_proficiencies(answer)
      end
    end
  end

  def set_stats
    continue = false
    message = ""
    get_min_and_max_stats

    while !continue
      tip = ""
      assign_attributes_header(message)
      tip = "Type 'confirm' to save changes."
      if @level == 1
        tip += "\nTip! 8 low, 18 high -- this doesn't take into account racial bonuses"
      end
      answer = ask_question("Which attribute do you want to edit?", false, 
                   tip)
      if answer == "confirm"
        if double_check
          continue = true
        end
      else
        message = adjust_stats(answer)
      end
    end
  end

  #updates proficiencies.
  def update_proficiencies(proficiency)
    if proficiency == "1" || proficiency == "one"
      number_to_adjust = get_updated_stat(@one_hand_prof, @max_proficency, 
                       @min_one_hand, @available_proficiency_points)
      @one_hand_prof += number_to_adjust
      @available_proficiency_points -= number_to_adjust
    
    elsif proficiency == "2" || proficiency == "two"
      number_to_adjust = get_updated_stat(@dual_wield_prof, @max_proficency, 
                         @min_dual_wield, @available_proficiency_points)
      @dual_wield_prof += number_to_adjust
      @available_proficiency_points -= number_to_adjust
    elsif proficiency == "3" || proficiency == "three"
      number_to_adjust = get_updated_stat(@two_hand_prof, @max_proficency, 
                         @min_two_hand, @available_proficiency_points)
      @two_hand_prof += number_to_adjust
      @available_proficiency_points -= number_to_adjust
    elsif proficiency == "4" || proficiency == "four"
      number_to_adjust = get_updated_stat(@magic_prof, @max_proficency, 
                         @min_magic, @available_proficiency_points)
      @magic_prof += number_to_adjust
      @available_proficiency_points -= number_to_adjust
    elsif proficiency == "5" || proficiency == "five"
      number_to_adjust = get_updated_stat(@unarmed_prof, @max_proficency, 
                         @min_unarmed, @available_proficiency_points)
      @unarmed_prof += number_to_adjust
      @available_proficiency_points -= number_to_adjust
    else
      message = Paint["\nPlease type a number from the list.\nExample: 'one' or '1'", :white]
      return message
    end
    return ""
  end

  #making sure that you can't go too high with attributes on level one
  #and making sure that level ups ( not yet implemented ) won't just
  #let you take away previously allocated points.
  def get_min_and_max_stats
    @min_str = @str
    @min_dex = @dex
    @min_con = @con
    @min_mag = @mag
    @min_cha = @cha

    if level == 1
      @max_str = 18
      @max_dex = 18
      @max_con = 18
      @max_mag = 18
      @max_cha = 18
    else
      @max_str = 99
      @max_dex = 99
      @max_con = 99
      @max_mag = 99
      @max_cha = 99
    end
    @min_one_hand = @one_hand_prof
    @min_dual_wield = @dual_wield_prof
    @min_two_hand = @two_hand_prof
    @min_magic = @magic_prof
    @min_unarmed = @unarmed_prof
  end

  #class that actually updates attributes
  def adjust_stats(attribute)
    case @race
      when "aloiln"
      when "tiersmen"
      when "relic"
      when "drai"
    end
    message = ""

      if attribute == "strength" || attribute == "str"

        number_to_adjust = get_updated_stat(@str, @max_str, 
                           @min_str, @available_attribute_points)
        @str += number_to_adjust
        @available_attribute_points -= number_to_adjust

      elsif attribute == "dexterity" || attribute == "dex"
        number_to_adjust = get_updated_stat(@dex, @max_dex, 
                           @min_dex, @available_attribute_points)
        @dex += number_to_adjust
        @available_attribute_points -= number_to_adjust
      elsif attribute == "constitution" || attribute == "con"
        number_to_adjust = get_updated_stat(@con, @max_con, 
                           @min_con, @available_attribute_points)
        @con += number_to_adjust
        @available_attribute_points -= number_to_adjust
      elsif attribute == "magic" || attribute == "mag"
        number_to_adjust = get_updated_stat(@mag, @max_mag, 
                           @min_mag, @available_attribute_points)
        @mag += number_to_adjust
        @available_attribute_points -= number_to_adjust
      elsif attribute == "charisma" || attribute == "cha"
        number_to_adjust = get_updated_stat(@cha, @max_cha, 
                           @min_cha, @available_attribute_points)
        @cha += number_to_adjust
        @available_attribute_points -= number_to_adjust
      else
        message = Paint["\nYou didn't select a valid attribute.\n" +
                  "Example: Strength or str\n", :white]
        return message
      end
      return ""
  end

  def add_or_subtract
    continue = false
    while !continue
      answer = ask_question("Do you want to add or subtract stats?", false, false)
      if answer == "subtract"
        return false
      elsif answer == "add"
        return true
      else
        print_error_message("\nPlease answer 'add' or 'subtract'. \n")
      end
    end   
  end

  #makes sure the number that you'll be adjusting ( either attributes or proficiency points)
  #is valid.
  def get_number_to_adjust(add, points_to_assign)
    continue = false
    while !continue
      answer = ask_question("How many points do you want to adjust?", false, false)

      if answer == "0"
        answer = answer.to_i
        continue = true
      elsif answer.to_i == 0
        print_error_message("\nPlease enter a number...\n")
      elsif add
        if answer.to_i > points_to_assign
          print_error_message("\nYou only have #{points_to_assign} to assign.\n")
        elsif answer.to_i < 0
          print_error_message("\nPlease enter a positive number or 0.\n")
        else
          continue = true
        end
      else
        continue = true
      end
    end
    answer = answer.to_i
    return answer
  end

  def check_if_have_shield
    @inventory.each_pair do |key, value|
      if value[:type] == "shield"
        return true
      end
    end
    return false
  end

  def equip_shield
    system "clear"
    continue = false
    while !continue
      display_shields(@inventory)

      if !@equipped_shield
        currently_equipped_shield = "none"
      else
        currently_equipped_shield = @equipped_shield[:name].capitalize
      end

      print_stat_and_label("Current Equipped Shield", currently_equipped_shield)
      new_line
      new_line
      answer = ask_question("Which shield would you like to equip?", false, "Type 'back' to leave.")
      if answer == "back"
        return true
      else
        if !@inventory[answer]
          system "clear"
          print_error_message("You do not have a #{answer}...")
        elsif @inventory[answer][:type] != "shield"
          system "clear"
          print_error_message("That's not a shield...")
        elsif @equipped_weapon[:type] != "1-hand weapon"
          system "clear"
          print_error_message("You can only equip a shield when you are wielding a one handed weapon!")
        else
          confirm = double_check_specific("you want to equip #{answer}")
          if confirm
            @equipped_shield = @inventory[answer]
            calculate_all_variable_stats
            string = "You have equipped #{@equipped_shield[:name]}!\n"
            string += "Your new ac is: #{@ac}.\n\n"
            return string
          else
            system "clear"
          end
        end
      end
    end
  end

  def equip_weapon
    continue = false
    while !continue
      display_weapons(@inventory)
      print_stat_and_label("Current Equipped Weapon", @equipped_weapon[:name].capitalize)
      new_line
      new_line
      answer = ask_question("Which weapon would you like to equip?", false, "Type 'back' to leave.")
      if answer == "back"
        continue = true
        return false
      else
        if !@inventory[answer]
          system "clear"
          print_error_message("You do not have a #{answer}...")

        elsif @inventory[answer][:type] != "1-hand weapon" && @inventory[answer][:type] != "2-hand weapon" &&
           @inventory[answer][:type] != "unarmed weapon" && @inventory[answer][:type] != "staff" &&
           @inventory[answer][:type] != "dual wield weapon"
           system "clear"
           print_error_message("That's not a weapon...")
        else
          confirm = double_check_specific("you want to equip #{answer}")
          if confirm
            @equipped_weapon = @inventory[answer]
            string = "You have equipped #{@equipped_weapon[:name]}!\n"
            string += "Your new attack is: #{@attack}.\n"
            string += "Your new damage is: #{@equipped_weapon[:number_of_dice]}d#{@equipped_weapon[:dice]} + #{@damage}.\n"
            have_shield = check_if_have_shield
            if @equipped_weapon[:type] == "1-hand weapon" && !@equipped_shield && have_shield
              answer = ask_question("Would you like to equip a shield in your free hand?", ["yes", "no"], false)
              if answer == "yes"
                possible_string = equip_shield
                if possible_string
                  string += possible_string
                end
              end
            end
            calculate_all_variable_stats
            return string
          else
            system "clear"
          end
        end
      end
    end
  end

  def use_item
    system "clear"
    continue = false
    while !continue
      display_usable_items(@inventory)
      new_line
      new_line
      answer = ask_question("Which item would you like to use?", false, "Type 'back' to leave.")
      if answer == "back"
        continue = true
        return false
      else
        if answer == "shield" || answer == "shields" || answer == "equip a shield"
          if @equipped_weapon[:type] == "1-hand weapon"
            response = equip_shield
            if response == false
            else
              string = response
              return string
            end
          else
            system "clear"
            print_error_message("You can't equip a shield with anything but a 1 handed weapon in your dominant hand.")
          end
        elsif !@inventory[answer]
          system "clear"
          print_error_message("You do not have a #{answer}...")
        else
          confirm = double_check_specific("you want to use a #{answer}")
          if confirm
            string = "You have used a #{answer}!\n\n"
            implement_item_effect(@inventory[answer])
            calculate_all_variable_stats
            return string
          else
            system "clear"
          end
        end
      end
    end
  end

  def manual_level_up
    #display place to add attribute points
    #display place to add proficiency points
    #recalculate stats
  end

  def level_up
    #increase the level
    @level += 1
    #set new needed exp
    calculate_exp_needed_per_level
    #update fame?
    #get additional attribute and proficiency points if applicable
    check_for_new_attribute_points
    check_for_new_proficiency_points
    #recalculate stats
    calculate_all_variable_stats
  end

end