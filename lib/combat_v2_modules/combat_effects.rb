module CombatEffects
  def set_buff_counters(player_buff_counters, enemy_buff_counters)
    if player_buff_counters
      @player_buff_counter = set_list_of_effects(@player_buff_counter, player_buff_counters[:spell], 
        calculate_expiration_turn(player_buff_counters[:time], @turn))
    end
    if enemy_buff_counters
      @enemy_buff_counter = set_list_of_effects(@enemy_buff_counter, enemy_buff_counters[:spell], 
        calculate_expiration_turn(enemy_buff_counters[:time], @turn))
    end
  end

  def set_curse_counters(player_curse_counters, enemy_curse_counters)
    if player_curse_counters
      @player_curse_counter = set_list_of_effects(@player_curse_counter, player_curse_counters[:spell], 
        calculate_expiration_turn(player_curse_counters[:time], @turn))
    end
    if enemy_curse_counters
      @enemy_curse_counter = set_list_of_effects(@enemy_curse_counter, enemy_curse_counters[:spell], 
        calculate_expiration_turn(enemy_curse_counters[:time], @turn))
    end
  end

  def player_pre_combat_considerations
    expired_spells = check_for_effect_expiration(@player_buff_counter, @turn)
    if expired_spells
      @message += @player_character.reverse_buff_spells_loop(expired_spells)
      @player_buff_counter = restore_list_of_effects(@player_buff_counter, @turn)
    end

    expired_spells = check_for_effect_expiration(@enemy_curse_counter, @turn)
    if expired_spells
      @message += @enemy.reverse_curse_spells_loop(expired_spells)
      @enemy_buff_counter = restore_list_of_effects(@enemy_buff_counter, @turn)
    end
  end

  def enemy_pre_combat_considerations
    expired_spells = check_for_effect_expiration(@enemy_buff_counter, @turn)
    if expired_spells
      @message += @enemy.reverse_buff_spells_loop(expired_spells)
      @enemy_buff_counter = restore_list_of_effects(@enemy_buff_counter, @turn)
    end

    expired_spells = check_for_effect_expiration(@player_curse_counter, @turn)
    if expired_spells
      @message += @player_character.reverse_curse_spells_loop(expired_spells)
      @player_buff_counter = restore_list_of_effects(@player_buff_counter, @turn)
    end
  end


  def calculate_expiration_turn(time, turn)
    expiration_turn = turn + time + 1
    @message += "Spell will expire on turn #{expiration_turn}.\n"
    return expiration_turn
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
      list_of_effects.each_pair do |expire_time, spells|
        spells.each do |effect|
          if effect[:name] == spell[:name]
            list_of_effects[expire_time].delete(effect)
            if list_of_effects[expire_time].length == 0
              list_of_effects.delete(expire_time)
            end
          end
        end
      end
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