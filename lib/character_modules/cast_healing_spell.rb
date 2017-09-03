module CastHealingSpell

  def get_healing(spell)
    healing = coordinate_healing(spell)
    healing = get_max_healing(healing, @hp, @max_hp)
    return healing
  end

  def coordinate_healing(spell)
    dice_bonus = spell[:number_of_dice_bonus]
    base_healing = get_base_spell_healing(spell, get_bonus(dice_bonus))
    healing_bonus = spell[:healing_bonus]
    healing = get_full_spell_healing(base_healing, get_bonus(healing_bonus))
    return healing
  end

  def get_base_spell_healing(spell, bonus)
    number_of_dice = spell[:number_of_dice] + bonus
    @spell_object[:message] += "Healing: #{number_of_dice}d#{spell[:dice]}"
    healing = roll_dice(1, spell[:dice], number_of_dice)
    return healing
  end

  def get_full_spell_healing(base_healing, bonus_healing)
    healing = base_healing + bonus_healing
    @spell_object[:message] += " + #{bonus_healing} = #{healing}. \n\n"
    return healing
  end

  def get_max_healing(healing, hp, max_hp)
    if (hp + healing) > max_hp
      healing = max_hp - hp
      @spell_object[:message] += "Actual healing due to current health: #{healing} \n\n"
    end
    return healing
  end

  def check_if_fully_healed(attribute)
    if attribute == "hp"
      if @hp >= @max_hp
        return true
      else
        return false
      end
    elsif attribute == "mana"
      if @mana >= @max_mana
        return true
      else
        return false
      end
    end
  end
end