require_relative "character.rb"
require_relative "spells.rb"

class PlayerCharacter
  #the class that manages the actual player character
  include Character

  attr_accessor :date, :hook
  attr_reader :current_exp, :exp_needed, :wealth, :fame
  attr_reader :attack, :one_hand_atk, :dual_wield_atk, :two_hand_atk, :unarmed_atk
  attr_reader :damage, :one_hand_damage, :dual_wield_damage, :unarmed_damage, :two_hand_damage
  attr_reader :spell_failure_chance
  attr_reader :one_hand_prof, :two_hand_prof, :dual_wield_prof, :unarmed_prof, :magic_prof
  attr_reader :assign_attribute_points, :assign_proficiency_points, :max_proficency
  attr_reader :known_spells, :default_weapon

  def initialize(name, race)
    @items = Items.new
    @full_spell_list = Spells.new
    @full_spell_list.create_spell_list
    @full_spell_list = @full_spell_list.spells
    @date = 1
    @hook = 1
    @max_proficency = 4
    @name = name
    @race = race
    @inventory = {}
    @known_spells = {}
    add_item("fists", @items.default_weapon["fists"])
    @default_weapon = @inventory["fists"]
    @equipped_weapon = @default_weapon
    @equipped_shield = false
  end

  #maybe I don't need this, idk. But it's here
  #so that I don't just start creating a character
  #in the initialize
  def create_character
    initial_character
  end

  #base character stats so that every number that should 
  #be set to something is actually set.
  def initial_character
    @wealth = 0
    @fame = 0
    @current_exp = 0
    @exp_needed = 100
    @str = 8 # affects sword/unarmed attack, cbm, cbm_def
    @dex = 8 # affects ac, cbm_def
    @con = 8 # affects hp
    @mag = 8 # affects mag_resist, mag_dc
    @cha = 8 # affects crowd
    @spell_failure_chance = 0
    @armor_bonus = 0
    @shield_bonus = 0
    @one_hand_prof = 0
    @dual_wield_prof = 0
    @two_hand_prof = 0
    @magic_prof = 0
    @unarmed_prof = 0
    update_modifiers
    @level = 1
    @assign_attribute_points = 30
    @assign_proficiency_points = 1
  end

  #makes sure all player-character based stats are calculated
  def calculate_full_stats
    calculate_shield_bonus
    calculate_base_stats
    calculate_weapon_stats
    calculate_magic_resist
    calculate_cbm
    calculate_mana
  end

  #this feeds in to the test character from character.rb
  #enables testing combat/unit tests
  def create_test_character
    test_character

    @spell_failure_chance = 0
    @one_hand_prof = 2
    @dual_wield_prof = 2
    @two_hand_prof = 3
    @magic_prof = 2
    @unarmed_prof = 1

    calculate_magic_resist
    calculate_cbm
    calculate_weapon_stats
    calculate_mana

    add_spell_to_known_spells("cure light wounds", @full_spell_list["cure light wounds"])
    add_spell_to_known_spells("magic missle", @full_spell_list["magic missle"])
    add_spell_to_known_spells("beguiler's grace", @full_spell_list["beguiler's grace"])
    add_spell_to_known_spells("shock weapon", @full_spell_list["shock weapon"])
    add_spell_to_known_spells("ray of sickening", @full_spell_list["ray of sickening"])

    add_item("bronze sword", @items.item_list["bronze sword"])
    add_item("bronze dual swords", @items.item_list["bronze dual swords"])
    add_item("health potion", @items.item_list["health potion"])
    add_item("bronze shield", @items.item_list["bronze shield"])
  end

  def add_spell_to_known_spells(spell_key, spell_value)
    @known_spells[spell_key] = spell_value
  end

  def add_item(key, value)
    @inventory[key] = value
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

  #updates proficiencies.
  def update_proficiencies(proficiency)
    if proficiency == "1" || proficiency == "one"
      number_to_adjust = get_updated_stat(@one_hand_prof, @max_proficency, 
                       @min_one_hand, @assign_proficiency_points)
      @one_hand_prof += number_to_adjust
      @assign_proficiency_points -= number_to_adjust
    
    elsif proficiency == "2" || proficiency == "two"
      number_to_adjust = get_updated_stat(@dual_wield_prof, @max_proficency, 
                         @min_dual_wield, @assign_proficiency_points)
      @dual_wield_prof += number_to_adjust
      @assign_proficiency_points -= number_to_adjust
    elsif proficiency == "3" || proficiency == "three"
      number_to_adjust = get_updated_stat(@two_hand_prof, @max_proficency, 
                         @min_two_hand, @assign_proficiency_points)
      @two_hand_prof += number_to_adjust
      @assign_proficiency_points -= number_to_adjust
    elsif proficiency == "4" || proficiency == "four"
      number_to_adjust = get_updated_stat(@magic_prof, @max_proficency, 
                         @min_magic, @assign_proficiency_points)
      @magic_prof += number_to_adjust
      @assign_proficiency_points -= number_to_adjust
    elsif proficiency == "5" || proficiency == "five"
      number_to_adjust = get_updated_stat(@unarmed_prof, @max_proficency, 
                         @min_unarmed, @assign_proficiency_points)
      @unarmed_prof += number_to_adjust
      @assign_proficiency_points -= number_to_adjust
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

    get_min_and_max_stats

      if attribute == "strength" || attribute == "str"

        number_to_adjust = get_updated_stat(@str, @max_str, 
                           @min_str, @assign_attribute_points)
        @str += number_to_adjust
        @assign_attribute_points -= number_to_adjust

      elsif attribute == "dexterity" || attribute == "dex"
        number_to_adjust = get_updated_stat(@dex, @max_dex, 
                           @min_dex, @assign_attribute_points)
        @dex += number_to_adjust
        @assign_attribute_points -= number_to_adjust
      elsif attribute == "constitution" || attribute == "con"
        number_to_adjust = get_updated_stat(@con, @max_con, 
                           @min_con, @assign_attribute_points)
        @con += number_to_adjust
        @assign_attribute_points -= number_to_adjust
      elsif attribute == "magic" || attribute == "mag"
        number_to_adjust = get_updated_stat(@mag, @max_mag, 
                           @min_mag, @assign_attribute_points)
        @mag += number_to_adjust
        @assign_attribute_points -= number_to_adjust
      elsif attribute == "charisma" || attribute == "cha"
        number_to_adjust = get_updated_stat(@cha, @max_cha, 
                           @min_cha, @assign_attribute_points)
        @cha += number_to_adjust
        @assign_attribute_points -= number_to_adjust
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
        else
          confirm = double_check_specific("you want to equip #{answer}")
          if confirm
            @equipped_shield = @inventory[answer]
            calculate_full_stats
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
            calculate_full_stats
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
            calculate_full_stats
            return string
          else
            system "clear"
          end
        end
      end
    end
  end

  #still very much under construction. now can only implement healing effects 
  def implement_item_effect(item)
    case item[:type]
    when "healing"
      if item[:stat] == "hp"
        calculation = @hp + item[:bonus]
        if calculation > @max_hp
          @hp = @max_hp
        else
          @hp = calculation
        end
      end
    end
  end

  def calculate_magic_resist
    @mag_resist = @mag_modifier + @magic_prof
  end

  #cbm stands for combat maneuver
  def calculate_cbm
    @cbm = @bab + @str_modifier + @unarmed_prof
    @cbm_def = 10 + @bab + @str_modifier + @dex_modifier + @unarmed_prof
  end

  def calculate_one_hand
    @one_hand_atk = get_skill_atk(@one_hand_prof)
    @one_hand_damage = get_skill_damage(@one_hand_prof)
  end

  def calculate_dual_wield
    @dual_wield_atk = get_skill_atk(@dual_wield_prof)
    @dual_wield_damage = get_skill_damage(@dual_wield_prof)
  end

  def calculate_two_hand
    @two_hand_atk = get_skill_atk(@two_hand_prof)
    damage = get_skill_damage(@two_hand_prof)
    @two_hand_damage = (damage * 1.5).floor
  end

  def calculate_shield_bonus
    if @equipped_shield
      @shield_bonus = @equipped_shield[:defense_bonus] + @equipped_shield[:enchantment]
    else
      @shield_bonus = 0
    end
  end

  def calculate_mana
    @max_mana = (@magic_prof * 50 ) + (@mag_modifier * 40 ) + (@cha_modifier * 30) + (@level * 20)
    @mana = @max_mana
    # Level 1, 16 + 3 mag, 14 + 2 cha, 1 prof = 250 mana
    # Level 2, 16 + 3 mag, 14 + 2 cha, 2 prof = 320 mana
    # Level 3, 16 + 3 mag, 14 + 2 cha, 2 prof = 340 mana
    # Level 4, 16 + 3 mag, 14 + 2 cha, 2 prof = 360 mana
    # Level 5, 16 + 3 mag, 14 + 2 cha, 3 prof = 430 mana

    # Level 1, 14 + 2 mag, 12 + 1 cha, 1 prof = 180 mana
    # Level 2, 16 + 3 mag, 14 + 2 cha, 2 prof = 250 mana
    # Level 3, 16 + 3 mag, 14 + 2 cha, 2 prof = 270 mana
    # Level 4, 16 + 3 mag, 14 + 2 cha, 2 prof = 290 mana
    # Level 5, 16 + 3 mag, 14 + 2 cha, 3 prof = 360 mana

    # Level 1, 1 prof = 70 mana  | max of 280 points from modifiers together
    # Level 2, 2 prof = 140 mana | max of 160 points from magic
    # Level 3, 2 prof = 160 mana | max of 120 points from cha
    # Level 4, 2 prof = 180 mana | max of 350 mana at level 1
    # Level 5, 3 prof = 250 mana
  end
  def calculate_unarmed
    @unarmed_atk = get_skill_atk(@unarmed_prof)
    @unarmed_damage = get_skill_damage(@unarmed_prof)
  end

  def calculate_auto_attack
    @weapon_enchantment = @equipped_weapon[:enchantment]

    if @equipped_weapon[:type] == "1-hand weapon"
      @attack = @one_hand_atk + @weapon_enchantment
      @damage = @one_hand_damage + @weapon_enchantment
    elsif @equipped_weapon[:type] == "2-hand weapon"
      @attack = @two_hand_atk + @weapon_enchantment
      @damage = (@one_hand_damage * 1.5).floor + @weapon_enchantment
    elsif @equipped_weapon[:type] == "unarmed weapon"
      @attack = @unarmed_atk + @weapon_enchantment
      @damage = @unarmed_damage + @weapon_enchantment
    end
  end

  def calculate_weapon_stats
    calculate_one_hand

    calculate_dual_wield
    
    calculate_two_hand

    calculate_unarmed

    calculate_auto_attack
  end

end