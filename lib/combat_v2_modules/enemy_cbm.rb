module EnemyCBM
  def enemy_active_cbm_combat_path
    if @player_cbm_status == "grappled"
      return enemy_has_player_grappled
    elsif @enemy_cbm_status == "tripped"
      return enemy_is_tripped
    elsif @enemy_cbm_status == "grappled"
      return enemy_is_grappled
    end
  end

  def enemy_has_player_grappled
    random_option = rand(1..3)
    return enemy_coordinate_actions_while_cbm(random_option)
  end

  def enemy_is_tripped
    random_option = rand(3..4)
    return enemy_coordinate_actions_while_cbm(random_option)
  end

  def enemy_is_grappled
    random_option = [3,5,6].sample
    return enemy_coordinate_actions_while_cbm(random_option)
  end

  def enemy_coordinate_actions_while_cbm(answer)
    if answer == 1
      enemy_pin_player
      return true
    elsif answer == 2
      enemy_release_player
      return true
    elsif answer == 3
      return enemy_get_spell
    elsif answer == 4
      enemy_stand_up
      return true
    elsif answer == 5
      enemy_gain_control
      return true
    elsif answer == 6
      enemy_escape_grapple
    end
  end

  def enemy_escape_grapple
    @message += "#{@enemy.name.capitalize} attempts to escape the grapple!\n"
    if cbm_attack_attempt(@player_character, @enemy)
      @message += "#{@enemy.name.capitalize} escapes the grapple!\n"
      player_reverse_cbm(CombatManeuvers.maneuvers["grapple"])
    else
      @message += "#{@enemy.name.capitalize} fails to escape the grapple!\n"
    end
  end

  def enemy_gain_control
    @message += "#{@enemy.name.capitalize} attempts to gain control of the grapple!\n"
    if attempt_to_gain_control(@enemy, @player_character)
      @message += "#{@enemy.name.capitalize} gains control of the grapple!\n"
      player_reverse_cbm(CombatManeuvers.maneuvers["grapple"])
      enemy_cbm_lingering(CombatManeuvers.maneuvers["grapple"])
    else
      @message += "#{@enemy.name.capitalize} fails to gain control of the grapple!\n"
    end
  end

  def enemy_stand_up
    @message = "#{@enemy.name.capitalize} stands up, provoking an attack of opportunity!\n"
    player_attack_of_opportunity
    player_reverse_cbm(CombatManeuvers.maneuvers["trip"])
  end

  def enemy_pin_player
    @message += "#{@enemy.name.capitalize} attempts to pin #{@player_character.name.capitalize}!\n"
    if cbm_attack_attempt(@player_character, @enemy)
      @message += "#{@enemy.name.capitalize} successfully pins #{@player_character.name.capitalize}.\n\n"
      @enemy.hp = -1
    else
      @message += "#{@enemy.name.capitalize} fails to pin #{@player_character.name.capitalize}.\n\n"
    end

  end

  def enemy_release_player
    enemy_reverse_cbm(CombatManeuvers.maneuvers["grapple"])
    @message += "#{@enemy.name.capitalize} releases #{@player_character.name.capitalize} from the grapple.\n\n"
  end

  def enemy_perform_cbm
    cbm = CombatManeuvers.actionable_maneuvers[CombatManeuvers.actionable_maneuvers.keys.sample]
    @message += "#{@enemy.name.capitalize} attempts to #{cbm[:name]} #{@player_character.name.capitalize}! \n"
    enemy_attempt_to_cbm(cbm)
    return true
  end

  def enemy_attempt_to_cbm(cbm)
    if cbm_attack_attempt(@player_character, @enemy)
      enemy_implement_cbm(cbm)
    end
  end

  def enemy_implement_cbm(cbm)
    if cbm[:name] == "disarm"
      enemy_cbm_disarm
    else
      enemy_cbm_lingering(cbm)
    end
  end

  def enemy_cbm_disarm
    @player_character.equipped_weapon = @player_character.default_weapon
    @player_character.equipped_shield = false
    @player_character.calculate_all_variable_stats
    @message += "#{@player_character.name} has been disarmed!\n\n"
  end

  def enemy_cbm_lingering(cbm)
    effect = @status_effects[cbm[:status]]
    implement_status_effect(effect, @player_character.name)
    @message += "#{@player_character.name} has been #{cbm[:status]}\n\n"
    enemy_set_cbm_status(cbm[:status])
  end

  def enemy_reverse_cbm(cbm)
    effect = @status_effects[cbm[:status]]
    reverse_status_effect(effect, @player_character.name)
    @message += "#{@player_character.name} has recovered from being #{cbm[:status]}\n\n"
    enemy_reverse_cbm_status
  end

  def enemy_set_cbm_status(status)
    @player_cbm_status = status
  end

  def enemy_reverse_cbm_status
    @player_cbm_status = false
  end

end