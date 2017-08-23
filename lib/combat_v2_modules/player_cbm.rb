module PlayerCBM
  def player_active_cbm_combat_path
    system "clear"
    display_activity_log(@message)
    @message = ""
    if @enemy_cbm_status == "grappled"
      return player_has_enemy_grappled
    elsif @player_cbm_status == "tripped"
      return player_is_tripped
    elsif @player_cbm_status == "grappled"
      return player_is_grappled
    else
      @message += "Not sure what to do."
      return true
    end
  end

  def player_has_enemy_grappled
    display_options_when_grappling
    display_combat_info(@player_character, @enemy, @turn)
    answer = ask_question("You have the enemy grappled! \nWhat would you like to do?", false, "Pinning the enemy to the ground is an automatic victory!")
    if ensure_valid_answer(["pin", "release", "cast"], answer)
      return player_coordinate_actions_while_cbm(answer)
    else
      @message += "#{answer} is not a vaild action. Please try again."
      return false
    end
  end

  def player_is_tripped
    display_options_when_tripped
    display_combat_info(@player_character, @enemy, @turn)
    answer = ask_question("You have been tripped! \nWhat would you like to do?", false, "Standing will provoke an attack of opportunity!")
    if ensure_valid_answer(["stand", "cast"], answer)
      return player_coordinate_actions_while_cbm(answer)
    else
      @message += "#{answer} is not a vaild action. Please try again."
      return false
    end
  end

  def player_is_grappled
    display_options_when_grappled
    display_combat_info(@player_character, @enemy, @turn)
    answer = ask_question("You have been grappled! \nWhat would you like to do?", false, "The enemy has a +5 advantage to maintaining control of the grapple!")
    if ensure_valid_answer(["gain control", "escape", "cast"], answer)
      return player_coordinate_actions_while_cbm(answer)
    else
      @message += "#{answer} is not a vaild action. Please try again."
      return false
    end
  end

  def player_coordinate_actions_while_cbm(answer)
    system "clear"
    if answer == "pin"
      player_pin_enemy
      return true
    elsif answer == "release"
      player_release_enemy
      return true
    elsif answer == "cast"
      return player_get_spell
    elsif answer == "stand"
      player_stand_up
      return true
    elsif answer == "gain control"
      player_gain_control
      return true
    elsif answer == "escape"
      player_escape_grapple
      return true
    end
  end

  def player_escape_grapple
    @message += "#{@player_character.name.capitalize} attempts to escape the grapple!\n"
    if cbm_attack_attempt(@enemy, @player_character)
      @message += "#{@player_character.name.capitalize} escapes the grapple!\n"
      enemy_reverse_cbm(CombatManeuvers.maneuvers["grapple"])
    else
      @message += "#{@player_character.name.capitalize} fails to escape the grapple!\n"
    end
  end

  def player_gain_control
    @message += "#{@player_character.name.capitalize} attempts to gain control of the grapple!\n"
    if attempt_to_gain_control(@player_character, @enemy)
      @message += "#{@player_character.name.capitalize} gains control of the grapple!\n\n"
      enemy_reverse_cbm(CombatManeuvers.maneuvers["grapple"])
      player_cbm_lingering(CombatManeuvers.maneuvers["grapple"])
    else
      @message += "#{@player_character.name.capitalize} fails to gain control of the grapple!\n\n"
    end
  end

  def player_stand_up
    @message += "#{@player_character.name.capitalize} stands up, provoking an attack of opportunity!\n"
    enemy_attack_of_opportunity
    enemy_reverse_cbm(CombatManeuvers.maneuvers["trip"])
  end

  def player_pin_enemy
    if cbm_attack_attempt(@enemy, @player_character)
      @message += "#{@player_character.name.capitalize} successfully pins #{@enemy.name.capitalize}.\n\n"
      @enemy.hp = -1
    else
       @message += "#{@player_character.name.capitalize} fails to pin #{@enemy.name.capitalize}.\n\n"
    end
  end

  def player_release_enemy
    player_reverse_cbm(CombatManeuvers.maneuvers["grapple"])
    @message += "#{@player_character.name.capitalize} releases #{@enemy.name.capitalize} from the grapple.\n\n"
  end

  def player_perform_cbm
    display_CBM(CombatManeuvers.maneuvers, @grappled)
    answer = ask_question("Which Combat Maneuver would you like to preform?", false, "Type 'back' to return.")

    if answer == "back"
      return false
    else
      cbm = get_cbm_if_exist(answer)
      if cbm
        @message += "#{@player_character.name.capitalize} attempts to #{cbm[:name]} #{@enemy.name.capitalize}!\n"
        player_attempt_to_cbm(cbm)
        return true
      else
        return false
      end
    end
  end

  def player_attempt_to_cbm(cbm)
    if cbm_attack_attempt(@enemy, @player_character)
      player_implement_cbm(cbm)
    end
  end

  def player_implement_cbm(cbm)
    if cbm[:name] == "disarm"
      player_cbm_disarm
    else
      player_cbm_lingering(cbm)
    end
  end

  def player_cbm_disarm
    @enemy.equipped_weapon = @enemy.default_weapon
    @enemy.equipped_shield = false
    @enemy.calculate_all_variable_stats
    @message += "#{@enemy.name} has been disarmed!\n\n"
  end

  def player_cbm_lingering(cbm)
    effect = @status_effects[cbm[:status]]
    implement_status_effect(effect, @enemy.name)
    @message += "#{@enemy.name} has been #{cbm[:status]}\n\n"
    player_set_cbm_status(cbm[:status])
  end

  def player_reverse_cbm(cbm)
    effect = @status_effects[cbm[:status]]
    reverse_status_effect(effect, @enemy.name)
    @message += "#{@enemy.name} has recovered from being #{cbm[:status]}\n\n"
    player_reverse_cbm_status
  end

  def player_set_cbm_status(status)
    @enemy_cbm_status = status
  end

  def player_reverse_cbm_status
    @enemy_cbm_status = false
  end

end