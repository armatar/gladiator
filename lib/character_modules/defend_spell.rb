module DefendSpell
  def defend_against_spell(spell_dc, spell)
    defend_hash = {}
    if !check_if_spell_is_resisted(spell_dc, @mag_resist)
      defend_hash[:message] = "#{@name} failed to resist the spell!\n"
      defend_hash = update_object(coordinate_defense(spell, spell[:type]), defend_hash)
    else
      defend_hash[:message] = "#{@name} successfully resisted the spell!\n\n"
    end
    return defend_hash
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
      message = take_damage(spell[:damage])
      return {message: message}
    elsif type == "curse"
      return implement_curse_spell(spell)
    elsif type == "hybrid"
      return implement_hybrid_spell(spell)
    end
  end

  def implement_hybrid_spell(spell)
    defend_hash = {message: ""}
    spell[:hybrid_types].each do |type|
      if type == "damage" || type == "curse"
        defend_hash = update_object(coordinate_defense(spell, type), defend_hash)
      end
    end
    return defend_hash
  end

  def implement_curse_spell(spell)
    message = ""
    if spell[:status_effect]
      message += "#{@name} has been #{spell[:status_effect]}\n\n"
      effect = StatusEffects.status_effects[spell[:status_effect]]
      message += implement_status_effect(effect)
    else
      spell[:affected_stat].each do |stat|
        updated_stat = update_stat(stat, -bonus)
        message += "#{@name}'s #{stat} has been updated to #{updated_stat}.\n"
      end
    end
    message += "\n"
    enemy_curse_counter = {spell: spell, time: spell[:time]}
    return {message: message, enemy_curse_counters: enemy_curse_counter}
  end
end