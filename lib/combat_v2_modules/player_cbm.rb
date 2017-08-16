module PlayerCBM
  def player_perform_cbm
    display_CBM(@maneuvers, @grappled)
    answer = ask_question("Which Combat Maneuver would you like to preform?", false, "Type 'back' to return.")

    if answer == "back"
      return false
    else
      cbm = get_cbm_if_exist(answer)
      if cbm
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
    @message += "#{@enemy.name} has been disarmed!\n\n"
  end

  def player_cbm_lingering(cbm)
    effect = @status_effects[cbm[:status]]
    implement_status_effect(effect, @enemy.name)
    @message += "#{@enemy.name} has been #{cbm[:status]}\n\n"
  end

  def player_reverse_cbm(cbm)
    effect = @status_effects[cbm[:status]]
    reverse_status_effect(effect, @enemy.name)
    @message += "#{@enemy.name} has recovered from being #{cbm[:status]}\n\n"
  end

  def player_set_cbm_status(status)
    @player_cbm_status = cbm[:status]
  end

end