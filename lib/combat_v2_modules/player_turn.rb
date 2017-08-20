module PlayerTurn
  def player_turn
    if player_consider_cbm
      return player_active_cbm_combat_path
    else
      return player_typical_combat_path
    end
  end

  def player_consider_cbm
    if @player_cbm_status == "grappled"
      return true
    elsif @player_cbm_status == "tripped"
      return true
    elsif @enemy_cbm_status == "grappled"
      return true
    else
      return false
    end
  end

  def player_typical_combat_path
    player_consider_active_effects(@turn)
    player_combat_display
    @message = ""
    answer = ask_question("What do you want to do?", false, "You can use the number if you want!")
    system "clear"
    return player_verify_which_answer(answer)
  end

  def player_consider_active_effects(turn)
    expired_spells = check_for_effect_expiration(@player_buff_counter, turn)
    if expired_spells
      player_reverse_buff_spells_loop(expired_spells)
    end

    expired_spells = check_for_effect_expiration(@enemy_curse_counter, turn)
    if expired_spells
      player_reverse_curse_spells_loop(expired_spells)
    end
  end

  def player_combat_display
    system "clear"
    display_activity_log(@message)
    display_combat_options(@player_character)
    display_combat_info(@player_character, @enemy, @turn)
  end

  def player_verify_which_answer(answer)
  	if answer == "swing your #{@player_character.equipped_weapon[:name]}" || answer == "1"
      #auto attack
      player_auto_attack
      #turn has been taken -- returning true
      return true
    elsif answer == "use a skill" || answer == "2"
      # use a skill
      @message += "You can't use that option yet..."
      #turn has not been taken -- returning false
      return false
    elsif answer == "cast a spell" || answer == "3"
      # cast a spell
      return player_get_spell
    elsif answer == "perform a combat maneuver" || answer == "4"
      # do cbm
      return player_perform_cbm
    elsif answer == "use an item" || answer == "5"
      # use an item
      return player_use_item
    elsif answer == "equip a weapon" || answer == "6"
      # equip a weapon
      return player_equip_weapon
    else 
      @message += "#{answer} is not an option. Please select an answer from the list."
      return false
    end
  end

  def player_attack_of_opportunity
    system "clear"
    display_activity_log(@message)
    message = "#{@enemy.name.capitalize} has provoked an attack of opportunity. Attack?"
    answer = ask_question(message, ["attack", "relent"])
    if answer == "attack"
      @message += "#{@player_character.name.capitalize} takes the attack of opportunity."
      player_auto_attack
    else
      @message += "#{@player_character.name.capitalize} does not take the attack of opportunity."
    end
  end

  def player_auto_attack
    damage = attack_with_equipped_weapon(@player_character, @enemy)
    @enemy.update_stat("hp", -damage)
  end

  def player_use_item
  	item_used = @player_character.use_item
    if item_used
      @message += item_used
      return true
    else
      return false
    end
  end

  def player_equip_weapon
    response = @player_character.equip_weapon
    if response
      @message += response 
      return true
    else
      return false
    end
  end
end