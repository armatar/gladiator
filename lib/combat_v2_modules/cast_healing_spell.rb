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
    base_healing = get_base_spell_healing(spell, get_bonus(dice_bonus, caster))
    healing_bonus = spell[:healing_bonus]
    healing = get_full_spell_healing(base_healing, get_bonus(healing_bonus, caster))
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
    @message += " + #{bonus_healing} = #{healing}. \n\n"
    return healing
  end

  def get_max_healing(healing, hp, max_hp)
    if (hp + healing) > max_hp
      healing = max_hp - hp
      @message += "Actual healing due to current health: #{healing} \n\n"
    end
    return healing
  end

  def check_if_fully_healed(caster, attribute)
    if attribute == "hp"
      if caster.hp == caster.max_hp
        @message += "You are already fully healed!"
        return true
      else
        return false
      end
    elsif attribute == "mana"
      if caster.mana == caster.max_mana
        @message += "Your mana is already full!"
        return true
      else
        return false
      end
    end
  end
end