require_relative '../user_interface.rb'

module CastHealingSpell
  include UserInterface

  def cast_healing_spell(spell, caster)
    healing = coordinate_healing(caster, spell)
    healing = get_max_healing(healing, caster.hp, caster.max_hp)
    return healing
  end

  def coordinate_healing(caster, spell)
    dice_bonus = spell[:number_of_dice_bonus]
    base_healing = get_base_spell_damage(spell, get_bonus(dice_bonus, caster))
    healing_bonus = spell[:healing_bonus]
    healing = get_full_spell_damage(base_healing, get_bonus(healing_bonus, caster))
    return healing
  end

  def get_base_spell_healing(spell, bonus)
    number_of_dice = spell[:number_of_dice] + bonus
    @message += "Healing: #{number_of_dice}d#{spell[:dice]}"
    healing = roll_dice(1, spell[:dice], number_of_dice)
    return healing
  end

  def get_full_spell_healing(base_healing, bonus_healing)
    healing = base_healing + bonus_healing
    @message += " + #{bonus_healing} = #{healing}. \n"
    return healing
  end

  def get_max_healing(healing, hp, max_hp)
    if (hp + healing) > max_hp
      healing = max_hp - hp
    end
    return healing
  end
end