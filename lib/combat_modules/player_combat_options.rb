module PlayerCombatOptions
  def player_turn
    answer = ask_question("What do you want to do?", false, "You can use the number if you want!")
    system "clear"
    if answer == "swing your #{@ally.equipped_weapon[:name]}" || answer == "1"
      #auto attack
      player_auto_attack
      return check_if_dead
    elsif answer == "use a skill" || answer == "2"
      # use a skill
      @message += "You can't use that option yet..."
      @turn -= 1
      return true
    elsif answer == "cast a spell" || answer == "3"
      # cast a spell
      return player_cast_spell
    elsif answer == "perform a combat maneuver" || answer == "4"
      # do cbm
      return player_do_cbm
    elsif answer == "use an item" || answer == "5"
      # use an item
      item_used = @ally.use_item
      if item_used
        result += item_used
        if !result
         @turn -= 1
        return true
        else
          @message = result
          return false
        end
      else
        @turn -= 1
        return true
      end
    elsif answer == "equip a weapon" || answer == "6"
      # equip a weapon
      changed = @ally.equip_weapon
      if changed
        @message += changed 
        return false
      else
        @turn -= 1
        return true
      end
    else 
      @message += "Please select a number from the list provided."
      @turn -= 1
      return true
    end
  end

  def player_cast_spell
    valid_answer = false
      while !valid_answer
        display_spell_list(@ally.known_spells)
        answer = ask_question("What spell do you wish to cast?", false, "Type 'back' to leave without casting a spell.")
        if answer == "back"
          system "clear"
          valid_answer = true
          @turn -= 1
          return true
        elsif @ally.known_spells[answer] && @ally.known_spells[answer][:mana_cost] > @ally.mana
          system "clear"
          print_line
          print_error_message("You don't have enough mana to cast #{answer}!")
        elsif @ally.known_spells[answer]
          spell = @ally.known_spells[answer]
          @ally.mana -= spell[:mana_cost]
          if check_if_overcome_spell_failure(@ally)
          system "clear"
            case spell[:type]
            when "damage"
              resisted = check_if_spell_is_resisted(spell, @ally, @enemy)
              if resisted
                @message += "#{@enemy.name} resisted the attack!\n\n"
                return false
              else
                @message += "The spell hits!\n"
                damage = cast_damage_spell(spell, @ally, @enemy)
                @enemy.hp -= damage
                return check_if_dead
              end
            when "healing"
              healing = cast_healing_spell(spell, @ally, @enemy)
              @message += "You heal for #{healing} health\n\n"
              @ally.hp += healing
              return false
            when "buff"
              time = cast_buff_spell(spell, "ally")
              time += @turn + 1
              @ally_buff_counter[time] = spell
              return false
            when "curse"
              resisted = check_if_spell_is_resisted(spell, @ally, @enemy)
              if resisted
                @message += "#{@enemy.name} resisted the curse!\n\n"
              else
                time = cast_curse_spell(spell, "enemy")
                time += @turn + 1
                @enemy_curse_counter[time] = spell
              end
              return false
            end
          else
            return false
          end
        else
          system "clear"
          print_line
          print_error_message("You don't have the spell #{answer}.")
        end
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

  def player_auto_attack
    damage = loop_through_attacks(@ally, @enemy, get_number_of_attacks(@ally))

    if damage
      @enemy.hp -= damage
    end
  end
end