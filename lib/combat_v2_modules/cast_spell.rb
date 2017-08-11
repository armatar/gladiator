require_relative '../user_interface.rb'

module CastSpell
  include UserInterface

  def determine_if_user_has_spell(spell)
    return player_character.known_spells[spell]
  end

  def determine_type_of_spell(spell)
    if spell[:type] == "damage"
      cast_damage_spell(spell)
    elsif spell[:type] == "healing"
      cast_healing_spell(spell)
    end
  end

  def cast_damage_spell(spell)
  end

  def cast_healing_spell(spell)
  end
end