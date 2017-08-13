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

  def player_get_spell
    display_spell_list(@player_character.known_spells)
    spell_name = ask_question("Which spell would you like to cast?")
    spell = get_spell_if_exist(spell_name)
    if !spell
      return false
    else
      return player_account_for_mana(spell)
    end
  end

  def player_account_for_mana(spell)
    if has_enough_mana?(@player_character.mana, spell)
      @player_character.mana -= spell[:mana_cost]
      player_cast_spell(spell)
      return true
    else
      return false
    end
  end

  def player_cast_spell(spell)
    if check_if_overcome_spell_failure(@player_character.spell_failure_chance)
      @message += "#{@player_character.name} casts #{spell[:name]}!\n"
      player_coordinate_cast(spell)
    end
  end

  def player_coordinate_cast(spell)
    if spell[:type] == "damage"
      player_cast_damage_spell(spell)
    elsif spell[:type] == "healing"
      player_cast_healing_spell(spell)
    end
  end

  def player_cast_damage_spell(spell)
    if !check_if_spell_is_resisted(@player_character.get_magic_dc(spell[:level]), @enemy.mag_resist)
      damage = cast_damage_spell(spell, @player_character)
      @enemy.hp -= damage
    end
  end

  def player_cast_healing_spell(spell)
    healing = cast_healing_spell(spell, caster)
    @player_character.hp += healing
  end

  def player_cast_buff_spell(spell)
  end

  def player_cast_curse_spell(spell)
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