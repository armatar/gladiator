module PlayerCombat

  def attack
    answer = ask_question("What do you want to do?", false, "You can use the number if you want!")
    return get_which_action(answer)
  end

  def get_which_spell
    system "clear"
    display_spell_list(@known_spells)
    spell_name = ask_question("Which spell would you like to cast?", false, "Type 'back' to return to the menu.")

    if spell_name == "back"
      return false
    end

    spell = get_spell_if_exist(spell_name)
    if !spell
      return false
    else
      @spell_object = {
        message: ""
      }
      return spell_pre_checks(spell)
    end
  end

  def get_spell_if_exist(spell_name)
    spell = known_spells[spell_name]
    if !spell
      @spell_object[:message] += "You do not have the spell: #{spell_name}.\n"
      return false
    end
    return spell
  end
end