require_relative '../user_interface.rb'

module CastHealingSpell
  include UserInterface

  def cast_healing_spell(spell, caster)
  end

  def get_max_healing(healing, hp, max_hp)
    if (hp + healing) > max_hp
      healing = max_hp - hp
    end
    return healing
  end
end