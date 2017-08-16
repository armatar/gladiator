module EnemyTurn
  def enemy_turn
    enemy_consider_active_effects(@turn)
    action = rand(1..3)
    return enemy_verify_which_answer(action.to_s)
  end

  def enemy_consider_active_effects(turn)
    expired_spells = check_for_effect_expiration(@enemy_buff_counter, turn)
    if expired_spells
      enemy_reverse_buff_spells_loop(expired_spells)
    end

    expired_spells = check_for_effect_expiration(@player_curse_counter, turn)
    if expired_spells
      enemy_reverse_curse_spells_loop(expired_spells)
    end
  end

  def enemy_combat_display
    system "clear"
    display_activity_log(@message)
    display_combat_options(@enemy)
    display_combat_info(@enemy, @enemy, @turn)
  end

  def enemy_verify_which_answer(answer)
    if answer == "swing your #{@enemy.equipped_weapon[:name]}" || answer == "1"
      #auto attack
      enemy_auto_attack
      #turn has been taken -- returning true
      return true
    elsif answer == "use a skill" || answer == "2"
      # use a skill
      #@message += "You can't use that option yet..."
      #turn has not been taken -- returning false
      return false
    elsif answer == "cast a spell" || answer == "3"
      # cast a spell
      return enemy_get_spell
    elsif answer == "perform a combat maneuver" || answer == "4"
      # do cbm
      #return enemy_do_cbm
      #@message += "Currently disabled."
      return false
    elsif answer == "use an item" || answer == "5"
      # use an item
      return enemy_use_item
    elsif answer == "equip a weapon" || answer == "6"
      # equip a weapon
      return enemy_equip_weapon
    else 
      #@message += "#{answer} is not an option. Please select an answer from the list."
      return false
    end
  end

  def enemy_auto_attack
    damage = attack_with_equipped_weapon(@enemy, @player_character)
    @player_character.update_stat("hp", -damage)
  end

  def enemy_use_item
    item_used = @enemy.use_item
    if item_used
      @message += item_used
      return true
    else
      return false
    end
  end

  def enemy_equip_weapon
    response = @enemy.equip_weapon
    if response
      @message += response 
      return true
    else
      return false
    end
  end

  def enemy_do_cbm
    valid_answer = false

    while !valid_answer
      display_CBM(@maneuvers, @grappled)
      answer = ask_question("Which Combat Maneuver would you like to preform?", false, "Type 'back' to return.")

      if answer == "back"
        @turn -= 1
        return true
      elsif !@maneuvers[answer]
        print_error_message("That's not a valid combat maneuver. Try again.")
      else
        success = cbm_attack_attempt(@enemy, @ally)
        if success
          if answer == "grapple"
            @grappled = true
          end
          implement_cbm("enemy", @maneuvers[answer])
          @current_enemy_cbm = @maneuvers[answer]
          return false
        else
          return false
        end
      end
    end
  end
end