require_relative "../..//combat_maneuvers.rb"

module PlayerCombat

  def attack
    answer = ask_question("What do you want to do?", false, "You can use the number if you want!")
    return get_which_action(answer)
  end

  def get_which_spell
    system "clear"
    display_spell_list(@known_spells)
    spell_name = ask_question("Which spell would you like to cast?", false, "Type 'back' to return to the menu.")
    @spell_object = {message: ""}
    if spell_name == "back"
      @spell_object[:continue] = false
      return @spell_object
    end
    spell = get_spell_if_exist(spell_name)
    if !spell
      return @spell_object
    else
      return spell_pre_checks(spell)
    end
  end

  def get_spell_if_exist(spell_name)
    spell = known_spells[spell_name]
    if !spell
      @spell_object[:message] = "You do not have the spell: #{spell_name}.\n"
      @spell_object[:continue] = false
      return false
    end
    return spell
  end

  def player_perform_cbm
    system "clear"
    @cbm_object = {message: ""}
    display_CBM(CombatManeuvers.maneuvers, @cbm_status)
    answer = ask_question("Which Combat Maneuver would you like to preform?", false, "Type 'back' to return.")
    @cbm_object = {message: ""}
    if answer == "back"
      @cbm_object[:continue] = false
    else
      cbm = get_cbm_if_exist(answer)
      if cbm
        @cbm_object[:message] += "#{@name.capitalize} attempts to perform a #{cbm[:name]}!\n"
        player_attempt_to_cbm(cbm)
      end
    end
    return @cbm_object
  end

  def get_cbm_if_exist(cbm_name)
    cbm = CombatManeuvers.maneuvers[cbm_name]
    if !cbm
      @cbm_object[:message] += "#{cbm_name} is not a valid combat maneuver.\n"
      @cbm_object[:continue] = false
      return false
    end
    return cbm
  end
end