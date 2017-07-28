require 'byebug'
require_relative 'interface.rb'
require_relative 'items.rb'
require_relative "spells.rb"
require_relative 'character_calculations.rb'

class Character
  # character module is a basis for what any character ( player or enemy ) should be.
  include Interface
  include CharacterCalculations

  attr_accessor :hp, :mana, :equipped_weapon, :equipped_shield
  attr_reader :max_hp, :max_mana, :str, :dex, :con, :mag, :cha
  attr_reader :name, :race, :level, :str_modifier, :dex_modifier, :con_modifier, :mag_modifier, :cha_modifier 
  attr_reader :ac, :mag_resist, :cbm, :cbm_def, :bab, :item_list
  attr_reader :items, :shield_bonus, :armor_bonus
  attr_reader :attack, :one_hand_atk, :dual_wield_atk, :two_hand_atk, :unarmed_atk, :staff_atk
  attr_reader :damage, :one_hand_damage, :dual_wield_damage, :unarmed_damage, :two_hand_damage, :staff_damage
  attr_reader :spell_failure_chance, :inventory
  attr_reader :one_hand_prof, :two_hand_prof, :dual_wield_prof, :unarmed_prof, :magic_prof
  attr_reader :assign_attribute_points, :assign_proficiency_points, :max_proficency
  attr_reader :known_spells, :default_weapon, :full_spell_list, :spells_class

  def initialize(name, race)
    @items = Items.new
    @spells_class = Spells.new

    @name = name
    @race = race

    character_base
  end

  def character_base
    @level = 1
    spell_base
    inventory_base
    attribute_base
    prof_base

    @spell_failure_chance = 0
    @armor_bonus = 0
    @shield_bonus = 0
    @max_dex_bonus_for_ac = false
    @max_proficency = 10
  end

  def prof_base
    @one_hand_prof = 0
    @dual_wield_prof = 0
    @two_hand_prof = 0
    @magic_prof = 0
    @unarmed_prof = 0
  end

  def display_character_sheet_from_character
    display_character_sheet
  end

  def attribute_base
    @str = 8 # affects sword/unarmed attack, cbm, cbm_def
    @dex = 8 # affects ac, cbm_def
    @con = 8 # affects hp
    @mag = 8 # affects mag_resist, mag_dc
    @cha = 8 # affects crowd
    update_modifiers
  end

  def spell_base
    @spells_class.create_spell_list
    @full_spell_list = @spells_class.spells
    @known_spells = {}
  end

  def inventory_base
    @item_list = @items.item_list
    @inventory = {}
    add_item("fists", @items.default_weapon["fists"])
    @default_weapon = @inventory["fists"]
    @equipped_weapon = @default_weapon
    @equipped_shield = false
  end

  def add_spell_to_known_spells(spell_key, spell_value)
    @known_spells[spell_key] = spell_value
  end

  def add_item(key, value)
    @inventory[key] = value
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

  def set_level(level)
    @level = level
  end

  def set_base_attributes(str, dex, con, mag, cha )
    @str = str
    @dex = dex
    @con = con
    @mag = mag
    @cha = cha
  end

  def set_base_proficiency_points(one_hand_prof, two_hand_prof, dual_wield_prof, magic_prof, unarmed_prof)
    @one_hand_prof = one_hand_prof
    @two_hand_prof = two_hand_prof
    @dual_wield_prof = dual_wield_prof
    @magic_prof = magic_prof
    @unarmed_prof = unarmed_prof
  end

  #way to update stats that are read only. used when affected by spells/skills
  def update_stat(stat, points_to_update)
    case stat
    when "ac"
      @ac += points_to_update
      return @ac
    when "attack"
      @attack += points_to_update
      return @attack
    when "damage"
      @damage += points_to_update
      return @damage
    when "hp"
      @hp += points_to_update
      return @hp
    when "magic resist"
      @mag_resist += points_to_update
      return @mag_resist
    when "spell failure"
      @spell_failure_chance += points_to_update
      return @spell_failure_chance
    when "dex modifier"
      @dex_modifier += points_to_update
      calculate_all_variable_stats
      return @dex_modifier
    when "str modifier"
      @str_modifier += points_to_update
      calculate_all_variable_stats
      return @str_modifier
    when "con modifier"
      @con_modifier += points_to_update
      calculate_all_variable_stats
      return @con_modifier
    when "mag modifier"
      @mag_modifier += points_to_update
      calculate_all_variable_stats
      return @mag_modifier
    when "cha modifier"
      @cha_modifier += points_to_update
      calculate_all_variable_stats
      return @cha_modifier
    end
  end

end