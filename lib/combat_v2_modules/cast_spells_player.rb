require_relative '../user_interface.rb'

module CastSpellsPlayer
  include UserInterface

  def player_get_spell
    display_spell_list(@player_character.known_spells)
    spell_name = ask_question("Which spell would you like to cast?", false, "Type 'back' to return to the menu.")

    if spell_name == "back"
      return false
    end

    spell = get_spell_if_exist(spell_name)
    if !spell
      return false
    else
      return player_spell_pre_checks(spell)
    end
  end

  def player_spell_pre_checks(spell)
    if spell[:type] == "healing"
      if !check_if_fully_healed(@player_character, spell[:attribute])
        return player_account_for_cost(spell)
      else
        return false
      end
    else
      return player_account_for_cost(spell)
    end
  end

  def player_account_for_cost(spell)
    if has_enough_to_cast?(@player_character, spell)
      if spell[:cost_pool] == "mana"
        @player_character.mana -= spell[:casting_cost]
      elsif spell[:cost_pool] == "hp"
        @player_character.hp -= spell[:casting_cost]
      end
      player_cast_spell(spell)
      return true
    else
      @message += "Not enough #{spell[:cost_pool]} to cast #{spell[:name]}!\n"
      return false
    end
  end

  def player_cast_spell(spell)
    if check_if_overcome_spell_failure(@player_character.spell_failure_chance)
      @message += "#{@player_character.name} casts #{spell[:name]}!\n"
      player_coordinate_cast(spell, spell[:type])
    end
  end

  def player_coordinate_cast(spell, type)
    if type == "damage"
      player_cast_damage_spell(spell)
    elsif type == "healing"
      player_cast_healing_spell(spell)
    elsif type == "buff"
      player_cast_buff_spell(spell, get_bonus(spell[:bonus], @player_character))
    elsif type == "curse"
      player_cast_curse_spell(spell, get_bonus(spell[:bonus], @player_character))
    elsif type == "hybrid"
      player_cast_hybrid_spell(spell)
    end
  end

  def player_cast_hybrid_spell(spell)
    spell[:hybrid_types].each do |type|
      player_coordinate_cast(spell, type)
    end
  end

  def player_cast_damage_spell(spell)
    if !check_if_spell_is_resisted(@player_character.get_magic_dc(spell[:level]), @enemy.mag_resist)
      damage = cast_damage_spell(spell, @player_character)
      @enemy.hp -= damage
    else
      @message += "You are already fully healed!\n"
    end
  end

  def player_cast_healing_spell(spell)
    healing = cast_healing_spell(spell, @player_character)
    @player_character.hp += healing
  end

  def player_cast_buff_spell(spell, bonus)
    spell[:affected_stat].each do |stat|
      updated_stat = @player_character.update_stat(stat, bonus)
      @message += "#{@player_character.name}'s #{stat} has been updated to #{updated_stat}.\n"
    end
    @message += "\n"
    @player_buff_counter = set_list_of_effects(@player_buff_counter, spell, get_spell_time(@player_character, spell[:time], @turn),)
  end

  def player_reverse_buff_spells_loop(spells_to_reverse)
    spells_to_reverse.each do |spell|
      bonus = get_bonus(spell[:bonus], @player_character)
      player_reverse_buff_spell(spell, bonus)
    end
    @message += "\n"
    @player_buff_counter = restore_list_of_effects(@player_buff_counter, @turn)
  end

  def player_reverse_buff_spell(spell, bonus)
    spell[:affected_stat].each do |stat|
      updated_stat = @player_character.update_stat(stat, -bonus)
      @message += "#{@player_character.name}'s #{stat} has been restored to #{updated_stat}.\n"
    end
  end

  def player_cast_curse_spell(spell, bonus)
    if !check_if_spell_is_resisted(@player_character.get_magic_dc(spell[:level]), @enemy.mag_resist)
      if spell[:status_effect]
        @message += "#{@enemy.name} has been #{spell[:status_effect]}\n\n"
        effect = StatusEffects.status_effects[spell[:status_effect]]
        implement_status_effect(effect, @enemy.name)
      else
        spell[:affected_stat].each do |stat|
          updated_stat = @enemy.update_stat(stat, -bonus)
          @message += "#{@enemy.name}'s #{stat} has been updated to #{updated_stat}.\n"
        end
      end
      @message += "\n"
      @enemy_curse_counter = set_list_of_effects(@enemy_curse_counter, spell, get_spell_time(@player_character, spell[:time], @turn),)
    end
  end

  def player_reverse_curse_spells_loop(spells_to_reverse)
    spells_to_reverse.each do |spell|
      bonus = get_bonus(spell[:bonus], @player_character)
      player_reverse_curse_spell(spell, bonus)
    end
    @message += "\n"
    @enemy_curse_counter = restore_list_of_effects(@enemy_curse_counter, @turn)
  end

  def player_reverse_curse_spell(spell, target)
    if spell[:status_effect]
      effect = StatusEffects.status_effects[spell[:status_effect]]
      reverse_status_effect(effect, @enemy.name)
      @message += "#{@enemy.name} has recovered from being #{spell[:status_effect]}\n\n"
    else
      spell[:affected_stat].each do |stat|
        updated_stat = @enemy.update_stat(stat, -bonus)
        @message += "#{@enemy.name}'s #{stat} has been restored to #{updated_stat}.\n"
      end
    end
  end
end