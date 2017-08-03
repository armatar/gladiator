module PlayerCombatSpecificInteractions
  def clear_out_player_effects
    @ally.hp = @ally.max_hp
    @ally.mana = @ally.max_mana
    @ally_buff_counter.each_pair do |expire_turn, spell|
      @turn = expire_turn
      restore_buff_status(@ally_buff_counter, @turn, "ally")
    end

    @ally_curse_counter.each_pair do |expire_turn, spell|
      @turn = expire_turn
      restore_curse_status(@ally_curse_counter, @turn, "ally")
    end
  end
  
  def enemy_is_grappled
    display_CBM(@maneuvers, @grappled)
    answer = ask_question("#{@enemy.name.capitalize} is grappled -- what would you like to do?", false, "Pinning an enemy successfully will win the match.")

    if answer == "pin"
      attempt = cbm_attack_attempt(@enemy, @ally)
      if attempt
        print_basic_message("You pin #{@enemy.name.capitalize} to the ground!\n")
        @enemy.hp = -1
        result = check_if_dead
        return result
      else
        @message += "You fail to pin your enemy and they escape from your grasp.\n\n"
        reverse_cbm("enemy", @current_enemy_cbm)
        @current_enemy_cbm = false
        @grappled = false
        return false
      end
    elsif answer == "release"
      @message += "You release your enemy from your grapple.\n\n"
      reverse_cbm("enemy", @current_enemy_cbm)
      @current_enemy_cbm = false
      @grappled = false
      return false
    else
      print_error_message("Please type either 'pin' or 'release'.") 
    end
  end

  def check_if_dead
    if @enemy.hp <= 0
      kill = finish_him?(@enemy)
      if kill
        return "kill"
      else
        return "spare"
      end
    else
      return false
    end
  end

  def finish_him?(enemy)
    continue = false
    while !continue
      answer = ask_question("Kill him or spare his life?", ["kill", "spare"], 
                            "Think carefully about your decision as it may have lasting effects.")
      if answer == "kill"
        return true
      elsif answer == "spare"
        return false
      else
        error_message("Please type either 'kill' or 'spare'.")
      end
    end
  end
end