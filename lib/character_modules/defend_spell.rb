module DefendSpell
  def defend_against_spell(spell_dc, spell)
    if !check_if_spell_is_resisted(spell_dc, @mag_resist)
      message = "#{@name} failed to resist the spell!\n"
      message += coordinate_defense(spell, spell[:type])
    else
      message = "#{@name} successfully resisted the spell!\n\n"
    end
    return message
  end

  def check_if_spell_is_resisted(spell_dc, magic_resist, dice_roll=roll_dice(1, 20, 1))
    dice_roll += magic_resist
    if dice_roll < spell_dc
      return false
    else
      return true
    end
  end

  def coordinate_defense(spell, type)
    if type == "damage"
      return take_damage(spell[:damage])
    elsif type == "buff"
      return "fail"
    elsif type == "curse"
      return "fail"
    elsif type == "hybrid"
      return "fail"
    end
  end
end