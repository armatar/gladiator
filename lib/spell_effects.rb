require_relative "Interface"

module SpellEffects

  include Interface

  def check_if_spell_is_resisted(spell, caster, target)
    mag_dc = caster.get_magic_dc(spell[:level])
    target_roll = roll_dice(20, 1)
    @message += "Resist Attempt: #{target_roll} + #{target.mag_resist} = #{target_roll + target.mag_resist}, Target: #{mag_dc}\n"
    target_roll += target.mag_resist
    if target_roll < mag_dc
      return false
    else
      return true
    end
  end

  def check_if_overcome_spell_failure(caster)
    dice_roll = rand(1..100)
    if dice_roll > caster.spell_failure_chance
      return true
    else
      @message += "Spell Fail Chance(#{caster.spell_failure_chance}%): Your spell fizzles and dies...\n\n"
      return false
    end
  end

  def check_max_healing(healing, caster)
    if (caster.hp + healing) > caster.max_hp
      healing = caster.max_hp - caster.hp
      return healing
    else
      return healing
    end
  end

  def roll_dice(dice, number_of_dice)
    random_number = 0

    number_of_dice.times do
      random_number += rand(1..dice)
    end

    return random_number
  end

  def get_number_of_dice(spell, caster)
    number_of_dice = 0
    if spell[:number_of_dice_bonus]
      if spell[:number_of_dice_bonus] == "proficiency"
        number_of_dice = (caster.magic_prof + spell[:number_of_dice]) - 1
      elsif spell[:number_of_dice_bonus] == "level"
        number_of_dice = (caster.level + spell[:number_of_dice]) - 1
      elsif spell[:number_of_dice_bonus] == "magic"
        number_of_dice = (caster.mag_modifier + spell[:number_of_dice]) - 1
      end
    else
      number_of_dice = spell[:number_of_dice]
    end

    return number_of_dice
  end

  def cast_damage_spell(spell, caster, target)

    #name: "burning hands", level: 1, type: "damage", dice: 4, number_of_dice: 1, damage_bonus: "magic", number_of_dice_bonus: "proficiency"

    number_of_dice = get_number_of_dice(spell, caster)

    damage = roll_dice(spell[:dice], number_of_dice)

    if spell[:damage_bonus]
      if spell[:damage_bonus] == "proficiency"
        damage += @caster.magic_prof
        @message += "Damage: #{number_of_dice}d#{spell[:dice]} + #{caster.magic_prof} = #{damage}\n\n"
      elsif spell[:damage_bonus] == "level"
        damage += caster.level
        @message += "Damage: #{number_of_dice}d#{spell[:dice]} + #{caster.level} = #{damage} \n\n"
      elsif spell[:damage_bonus] == "magic"
        damage += caster.mag_modifier
        @message += "Damage: #{number_of_dice}d#{spell[:dice]} + #{caster.mag_modifier} = #{damage} \n\n"
      end
    else
      @message += "Damage: #{number_of_dice}d#{spell[:dice]} = #{damage} \n\n"
    end

    return damage
  end

  def cast_healing_spell(spell, caster, target)

    #name: "cure light wounds", level: 1, type: "healing", dice: 8, number_of_dice: 1, healing_bonus: "proficiency", number_of_dice_bonus: false

    number_of_dice = get_number_of_dice(spell, caster)
    healing = roll_dice(spell[:dice], number_of_dice)

    if spell[:healing_bonus]
      if spell[:healing_bonus] == "proficiency"
        healing += caster.magic_prof
        @message += "Healing: #{number_of_dice}d#{spell[:dice]} + #{caster.magic_prof} = #{healing}\n\n"
      elsif spell[:healing_bonus] == "level"
        healing += caster.level
        @message += "Healing: #{number_of_dice}d#{spell[:dice]} + #{caster.level} = #{healing} \n\n"
      elsif spell[:healing_bonus] == "magic"
        healing += caster.mag_modifier
        @message += "Healing: #{number_of_dice}d#{spell[:dice]} + #{caster.mag_modifier} = #{healing} \n\n"
      end
    else
      @message += "Healing: #{number_of_dice}d#{spell[:dice]} = #{healing} \n\n"
    end

    healing = check_max_healing(healing, caster)
    return healing
  end

  def get_buff_bonus(caster, bonus)
    case bonus
    when "cha"
      return caster.cha_modifier
    when "mag"
      return caster.mag_modifier
    when "level"
      return caster.level
    when "proficiency"
      return caster.magic_prof
    end
  end

  def get_spell_time(caster, time)
    if time == "level"
      return caster.level
    elsif time == "cha"
      return caster.cha_modifier
    elsif time == "mag"
      return caster.mag_modifier
    elsif time == "proficiency"
      return caster.magic_prof
    else
      return time
    end
  end

  def cast_buff_spell(spell, caster)
    #name: "beguiler's grace", level: 1, type: "buff", affected_stat: ["ac", "damage", "attack"], bonus: "cha", time: "level"
    if caster == "ally"
      updated_stat = 0
      bonus = get_buff_bonus(@ally, spell[:bonus])
      spell[:affected_stat].each do |stat|
        updated_stat = @ally.update_stat(stat, bonus)
        @message += "Ally #{stat} has been update to #{updated_stat}.\n"
      end
      @message += "\n"
      return get_spell_time(@ally, spell[:time])
    elsif caster == "enemy"
    end
  end

  def reverse_buff_spell(spell, caster)
    #name: "beguiler's grace", level: 1, type: "buff", affected_stat: ["ac", "damage", "attack"], bonus: "cha", time: "level"
    if caster == "ally"
      updated_stat = 0
      bonus = get_buff_bonus(@ally, spell[:bonus])
      spell[:affected_stat].each do |stat|
        updated_stat = @ally.update_stat(stat, -bonus)
        @message += "Ally #{stat} has been restored to #{updated_stat}.\n"
      end
      @message += "\n"
    elsif caster == "enemy"
    end
  end

  def cast_curse_spell(spell, target)
    if spell[:status]
      effect = spell[:status]
      effect = @status_effects[effect]
      implement_status_effect(target, effect)
      if target == "ally"
        @message += "Ally has been #{spell[:status]}\n\n"
        return get_spell_time(@enemy, spell[:time])
      elsif target == "enemy"
        @message += "Enemy has been #{spell[:status]}\n\n"
        return get_spell_time(@ally, spell[:time])
      end
    end
  end

  def reverse_curse_spell(spell, target)
    if spell[:status]
      effect = spell[:status]
      effect = @status_effects[effect]
      reverse_status_effect(target, effect)
    end
  end
end