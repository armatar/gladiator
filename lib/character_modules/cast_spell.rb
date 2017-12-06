require_relative '../user_interface.rb'

module CastSpell
  include UserInterface

  def spell_pre_checks(spell)
    @spell_object = {
        message: ""
      }
    if spell[:type] == "healing"
      if !check_if_fully_healed(spell[:attribute])
        return account_for_cost(spell)
      else
        return false
      end
    else
      return account_for_cost(spell)
    end
  end

  def account_for_cost(spell)
    if has_enough_to_cast?(spell)
      if spell[:cost_pool] == "mana"
        @mana -= spell[:casting_cost]
      elsif spell[:cost_pool] == "hp"
        @hp -= spell[:casting_cost]
      end
      cast_spell(spell)
      return @spell_object
    else
      @spell_object[:message] += "Not enough #{spell[:cost_pool]} to cast #{spell[:name]}!\n"
      return false
    end
  end

  def cast_spell(spell)
    if check_if_overcome_spell_failure(@spell_failure_chance)
      @spell_object[:message] += "#{@name} casts #{spell[:name]}! \n"
      @spell_object[:spell_dc] = get_spell_dc(spell[:level])
      @spell_object[:spell] = {}
      coordinate_cast(spell, spell[:type])
    end
  end

  def coordinate_cast(spell, type)
    if type == "damage"
      cast_damage_spell(spell)
    elsif type == "healing"
      cast_healing_spell(spell)
    elsif type == "buff"
      cast_buff_spell(spell, get_bonus(spell[:bonus]))
    elsif type == "curse"
      cast_curse_spell(spell, get_bonus(spell[:bonus]))
    elsif type == "hybrid"
      cast_hybrid_spell(spell)
    end
  end

  def cast_hybrid_spell(spell)
    spell[:hybrid_types].each do |type|
      coordinate_cast(spell, type)
    end
    @spell_object[:spell][:hybrid_types] = spell[:hybrid_types]
  end

  def cast_damage_spell(spell)
    damage = get_spell_damage(spell)
    @spell_object[:spell] = update_object({name: spell[:name], type: spell[:type], damage: damage}, @spell_object[:spell])
  end

  def cast_healing_spell(spell)
    healing = get_healing(spell)
    @hp += healing
  end

  def cast_buff_spell(spell, bonus)
    spell[:affected_stat].each do |stat|
      updated_stat = update_stat(stat, bonus)
      @spell_object[:message] += "#{@name}'s #{stat} has been updated to #{updated_stat}.\n"
    end
    @spell_object[:message] += "\n"
    @spell_object[:player_buff_counters] = {time: get_spell_time(spell[:time]), spell: spell}
  end

  def cast_curse_spell(spell, bonus)
    @spell_object[:spell] = update_object({name: spell[:name], type: spell[:type], bonus: bonus,
      status_effect: spell[:status_effect], time: get_spell_time(spell[:time])}, @spell_object[:spell])
  end

  def reverse_buff_spells_loop(spells_to_reverse)
    message = ""
    spells_to_reverse.each do |spell|
      bonus = get_bonus(spell[:bonus])
      message += reverse_buff_spell(spell, bonus)
    end
    message += "\n"
    return message
  end

  def reverse_buff_spell(spell, bonus)
    message = ""
    spell[:affected_stat].each do |stat|
      updated_stat = update_stat(stat, -bonus)
      message += Paint["#{@name}'s #{stat} has been restored to #{updated_stat}.\n", :red, :bold]
    end
    return message
  end

  def reverse_curse_spells_loop(spells_to_reverse)
    message = ""
    spells_to_reverse.each do |spell|
      bonus = get_bonus(spell[:bonus])
      message += reverse_curse_spell(spell, bonus)
    end
    message += "\n"
    return message
  end

  def reverse_curse_spell(spell, bonus)
    message = ""
    if spell[:status_effect]
      effect = StatusEffects.status_effects[spell[:status_effect]]
      reverse_status_effect(effect)
      message += Paint["#{@name} has recovered from being #{spell[:status_effect]}\n\n", :red, :bold]
    else
      spell[:affected_stat].each do |stat|
        updated_stat = update_stat(stat, -bonus)
        message += Paint["#{@name}'s #{stat} has been restored to #{updated_stat}.\n", :red, :bold]
      end
    end
    return message
  end

  def check_if_overcome_spell_failure(spell_failure_chance, percent_roll=roll_dice(1, 100, 1))
    if percent_roll > spell_failure_chance
      return true
    else
      @spell_object[:message] += "Spell Fail Chance(#{spell_failure_chance}%): The spell fizzles and dies...\n\n"
      return false
    end
  end

  def has_enough_to_cast?(spell)
    if spell[:cost_pool] == "mana"
      if @mana >= spell[:casting_cost]
        return true
      else
        return false
      end
    elsif spell[:cost_pool] == "hp"
      if @hp >= spell[:casting_cost]
        return true
      else
        return false
      end
    end
  end

  def get_bonus(bonus_to_get)
    if bonus_to_get == "proficiency"
      return @magic_prof
    elsif bonus_to_get == "level"
      return @level
    elsif bonus_to_get == "magic"
      return @mag_modifier
    elsif bonus_to_get == "charisma"
      return @cha_modifier
    elsif bonus_to_get == false
      return 0
    end
  end

  def get_spell_time(time)
    if time == "level"
      return @level
    elsif time == "charisma"
      return @cha_modifier
    elsif time == "magic"
      return @mag_modifier
    elsif time == "proficiency"
      return @magic_prof
    else
      return time
    end
  end

  def implement_status_effect(effect)
    message = ""
    if @current_status_effects.include?(effect[:name])
      message += "#{@name}'s #{effect[:name]} status has been extended!"
    else
      effect[:affected_stat].each do | stat |
        updated_stat = update_stat(stat, effect[:penalty])
        message += "#{@name}'s #{stat} has been updated to #{updated_stat}.\n"
      end
      @current_status_effects.push(effect[:name])
    end
    return message
  end

  def reverse_status_effect(effect)
    message = ""
    effect[:affected_stat].each do | stat |
      updated_stat = update_stat(stat, -effect[:penalty])
      message += Paint["#{@name}'s #{stat} has been restored to #{updated_stat}.\n", :red, :bold]
    end
    @current_status_effects.delete(effect[:name])
    return message
  end
end