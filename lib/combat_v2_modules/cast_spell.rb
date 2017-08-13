require_relative '../user_interface.rb'

module CastSpell
  include UserInterface

  def get_spell_if_exist(spell_name)
    spell = player_character.known_spells[spell_name]
    if !spell
      @message += "You do not have the spell: #{spell_name}.\n"
    end
    return spell
  end

  def check_if_overcome_spell_failure(spell_failure_chance, percent_roll=roll_dice(1, 100, 1))
    if percent_roll > spell_failure_chance
      return true
    else
      @message += "Spell Fail Chance(#{spell_failure_chance}%): The spell fizzles and dies...\n\n"
      return false
    end
  end

  def check_if_spell_is_resisted(spell_dc, target_magic_resist, target_roll=roll_dice(1, 20, 1))
    @message += "Resist Attempt: #{target_roll} + #{target_magic_resist} = #{target_roll + target_magic_resist}, Target: #{spell_dc}\n"
    target_roll += target_magic_resist
    if target_roll < spell_dc
      @message += "Resist attempt failed!\n"
      return false
    else
      @message += "Resist attempt succeded!\n\n"
      return true
    end
  end

  def has_enough_mana?(mana, spell)
    if mana >= spell[:mana_cost]
      return true
    else
      @message += "Not enough mana to cast #{spell[:name]}!\n"
      return false
    end
  end

  def get_bonus(bonus_to_get, caster)
    if bonus_to_get == "proficiency"
      return caster.magic_prof
    elsif bonus_to_get == "level"
      return caster.level
    elsif bonus_to_get == "magic"
      return caster.mag_modifier
    elsif bonus_to_get == false
      return 0
    end
  end
end