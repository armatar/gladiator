require_relative "character.rb"

module Enemies
  include Character

  attr_accessor :attack, :damage
  attr_reader :skill, :items, :spell_failure_chance, :default_weapon, :known_spells
  attr_reader :proficiency, :gold_worth, :item_drop, :fame_worth, :exp_worth
  def initialize
    @items = Items.new
  end

  def create_test_enemy
    @name = "Bad Guy"
    @race = "Monster"
    @attack = 2
    @damage = 1
    @spell_failure_chance = 0
    @equipped_weapon = @items.default_weapon["fists"]
    test_character
  end

  def calculate_full_stats
    calculate_base_stats
    @attack = get_skill_atk(@proficiency)
    if @skill == "2-hand weapon"
      damage = get_skill_damage(@proficiency)
      @damage = (damage * 1.5).floor
    else
      @damage = get_skill_damage(@proficiency)
    end
    calculate_cbm
    calculate_magic_resist
    calculate_max_mana
  end

  def calculate_cbm
    if @skill == "unarmed"
      unarmed_proficiency = @proficiency
    else
      unarmed_proficiency = 0
    end
    @cbm = @bab + @str_modifier + unarmed_proficiency
    @cbm_def = 10 + @bab + @str_modifier + @dex_modifier + unarmed_proficiency
  end

  def calculate_magic_resist
    if @skill == "magic"
      magic_prof = @proficiency
    else
      magic_prof = 0
    end
    @mag_resist = @mag_modifier + magic_prof
  end

  def calculate_max_mana
    if @skill == "magic"
      magic_prof = @proficiency
    else
      magic_prof = 0
    end
    @max_mana = (magic_prof * 50 ) + (@mag_modifier * 40 ) + (@cha_modifier * 30) + (@level * 20)
    @mana = @max_mana
  end

end
