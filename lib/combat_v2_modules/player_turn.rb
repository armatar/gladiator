module PlayerTurn
  def player_turn
    player_combat_display
    @message = ""
    answer = ask_question("What do you want to do?", false, "You can use the number if you want!")
    system "clear"
    return verify_which_answer(answer)
  end

  def player_combat_display
    system "clear"
    display_activity_log(@message)
    display_combat_options(@player_character)
    display_combat_info(@player_character, @enemy, @turn)
  end

  def verify_which_answer(answer)
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
      #return player_do_cbm
      @message += "Currently disabled."
      return false
    elsif answer == "use an item" || answer == "5"
      # use an item
      return player_use_item
    elsif answer == "equip a weapon" || answer == "6"
      # equip a weapon
      return player_equip_weapon
    else 
      @message += "Please select a number from the list provided."
      return false
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

  def player_do_cbm
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