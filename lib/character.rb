require 'byebug'
require_relative 'interface.rb'
require_relative 'items.rb'

module Character
  # character module is a basis for what any character ( player or enemy ) should be.
  include Interface

  attr_accessor :hp, :mana
  attr_reader :max_hp, :max_mana, :str, :dex, :con, :mag, :cha
  attr_reader :name, :race, :level, :str_modifier, :dex_modifier, :con_modifier, :mag_modifier, :cha_modifier 
  attr_reader :ac, :mag_resist, :cbm, :cbm_def, :bab
  attr_reader :items, :shield_bonus, :armor_bonus, :equipped_weapon, :equipped_shield

  # this function is just so I can use pre-generated character for unit tests and for testing combat. see testing_combat.rb
  def test_character
    @level = 3
    @str = 10 # affects sword/unarmed attack, cbm, cbm_def
    @dex = 18 # affects ac, cbm_def
    @con = 14 # affects hp
    @mag = 15 # affects mag_resist, mag_dc
    @cha = 16 # affects crowd
    @armor_bonus = 0
    @shield_bonus = 0
    @max_dex_bonus = 2
    update_modifiers
    calculate_first_hp
    calculate_base_stats
  end

  def calculate_base_stats
    calculate_bab
    calculate_ac
  end

  def calculate_bab
    @bab = (@level/2) + 1
  end

  def calculate_ac
    if !@max_dex_bonus
      allowed_dex = @dex_modifier
    else
      allowed_dex = @max_dex_bonus
    end
    if !@shield_bonus
      @shield_bonus = 0
    end

    if !@armor_bonus
      @armor_bonus = 0
    end

    @ac = allowed_dex + @shield_bonus + @armor_bonus + 10
  end

  def calculate_first_hp
    hp = 0
    @level.times do
      if @con_modifier + 1 < 2
        max = 6
      else
        max = 6 * (@con_modifier+1)
      end
      min = max/2
      hp += rand(min..max) + @con_modifier
    end
    @hp = hp
    @max_hp = hp
  end

  def get_magic_dc(spell_level)
    mag_dc = 10 + @mag_modifier + @magic_prof + spell_level
    return mag_dc
  end

  def get_skill_atk(skill)
    attack = @bab + @str_modifier + skill
    return attack
  end

  def get_skill_damage(skill)
    damage = @str_modifier + skill
    return damage
  end

  def update_modifiers
    @str_modifier = (@str - 10) / 2
    @dex_modifier = (@dex - 10) / 2
    @con_modifier = (@con - 10) / 2
    @mag_modifier = (@mag - 10) / 2
    @cha_modifier = (@cha - 10) / 2
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
      calculate_full_stats
      return @dex_modifier
    when "str modifier"
      @str_modifier += points_to_update
      calculate_full_stats
      return @str_modifier
    when "con modifier"
      @con_modifier += points_to_update
      calculate_full_stats
      return @con_modifier
    when "mag modifier"
      @mag_modifier += points_to_update
      calculate_full_stats
      return @mag_modifier
    when "cha modifier"
      @cha_modifier += points_to_update
      calculate_full_stats
      return @cha_modifier
    end
  end

end