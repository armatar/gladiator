module CombatEffects
  def implement_status_effect(effect, target_name)
    if target_name == @enemy.name
      effect[:affected_stat].each do | stat |
        updated_stat = @enemy.update_stat(stat, effect[:penalty])
        @message += "#{target_name}'s #{stat} has been updated to #{updated_stat}.\n"
      end
    else
      effect[:affected_stat].each do | stat |
        updated_stat = @player_character.update_stat(stat, effect[:penalty])
        @message += "#{target_name}'s #{stat} has been updated to #{updated_stat}.\n"
      end
    end
  end

  def reverse_status_effect(effect, target_name)
    if target_name == @enemy.name
      effect[:affected_stat].each do | stat |
        updated_stat = @enemy.update_stat(stat, -effect[:penalty])
        @message += "#{target_name}'s #{stat} has been restored to #{updated_stat}.\n"
      end
    else
      effect[:affected_stat].each do | stat |
        updated_stat = @player_character.update_stat(stat, -effect[:penalty])
        @message += "#{target_name}'s #{stat} has been restored to #{updated_stat}.\n"
      end
    end
  end

  def calculate_expiration_turn(time, turn)
    return turn + time + 1
  end

  def check_for_effect_expiration(list_of_current_effects, turn)
    list_of_current_effects.each_pair do |expire_turn, spells|
      if expire_turn == turn
        return list_of_current_effects[expire_turn]
      end
    end
    return false
  end

  def set_list_of_effects(list_of_effects, spell, time_to_expire)
    if list_of_effects[time_to_expire]
      value = list_of_effects[time_to_expire]
      value.push(spell)
      list_of_effects[time_to_expire] = value
    else
      list_of_effects[time_to_expire] = [spell]
    end
    return list_of_effects
  end

  def restore_list_of_effects(list_of_effects, turn)
    list_of_effects.each_pair do |time_to_expire, spells|
      if time_to_expire == turn
        list_of_effects.delete(time_to_expire)
      end
    end
    return list_of_effects
  end
end