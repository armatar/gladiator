require_relative '../user_interface.rb'

module CastSpellsEnemy
  include UserInterface

  def enemy_get_spell
    spell = @enemy.known_spells[@enemy.known_spells.keys.sample]
    return enemy_spell_pre_checks(spell)
  end

  def enemy_spell_pre_checks(spell)
    if spell[:type] == "healing"
      if !check_if_fully_healed(@enemy, spell[:attribute])
        return enemy_account_for_cost(spell)
      else
        return false
      end
    else
      return enemy_account_for_cost(spell)
    end
  end

  def enemy_account_for_cost(spell)
    if has_enough_to_cast?(@enemy, spell)
      if spell[:cost_pool] == "mana"
        @enemy.mana -= spell[:casting_cost]
      elsif spell[:cost_pool] == "hp"
        @enemy.hp -= spell[:casting_cost]
      end
      enemy_cast_spell(spell)
      return true
    else
      return false
    end
  end

  def enemy_cast_spell(spell)
    if check_if_overcome_spell_failure(@enemy.spell_failure_chance)
      @message += "#{@enemy.name} casts #{spell[:name]}!\n"
      enemy_coordinate_cast(spell, spell[:type])
    end
  end

  def enemy_coordinate_cast(spell, type)
    if type == "damage"
      enemy_cast_damage_spell(spell)
    elsif type == "healing"
      enemy_cast_healing_spell(spell)
    elsif type == "buff"
      enemy_cast_buff_spell(spell, get_bonus(spell[:bonus], @enemy))
    elsif type == "curse"
      enemy_cast_curse_spell(spell, get_bonus(spell[:bonus], @enemy))
    elsif type == "hybrid"
      enemy_cast_hybrid_spell(spell)
    end
  end

  def enemy_cast_hybrid_spell(spell)
    spell[:hybrid_types].each do |type|
      enemy_coordinate_cast(spell, type)
    end
  end

  def enemy_cast_damage_spell(spell)
    if !check_if_spell_is_resisted(@enemy.get_magic_dc(spell[:level]), @enemy.mag_resist)
      damage = cast_damage_spell(spell, @enemy)
      @player_character.hp -= damage
    end
  end

  def enemy_cast_healing_spell(spell)
    healing = cast_healing_spell(spell, @enemy)
    @enemy.hp += healing
  end

  def enemy_cast_buff_spell(spell, bonus)
    spell[:affected_stat].each do |stat|
      updated_stat = @enemy.update_stat(stat, bonus)
      @message += "#{@enemy.name}'s #{stat} has been updated to #{updated_stat}.\n"
    end
    @message += "\n"
    @enemy_buff_counter = set_list_of_effects(@enemy_buff_counter, spell, get_spell_time(@enemy, spell[:time], @turn),)
  end

  def enemy_reverse_buff_spells_loop(spells_to_reverse)
    spells_to_reverse.each do |spell|
      bonus = get_bonus(spell[:bonus], @enemy)
      enemy_reverse_buff_spell(spell, bonus)
    end
    @message += "\n"
    @enemy_buff_counter = restore_list_of_effects(@enemy_buff_counter, @turn)
  end

  def enemy_reverse_buff_spell(spell, bonus)
    spell[:affected_stat].each do |stat|
      updated_stat = @enemy.update_stat(stat, -bonus)
      @message += "#{@enemy.name}'s #{stat} has been restored to #{updated_stat}.\n"
    end
  end

  def enemy_cast_curse_spell(spell, bonus)
    if !check_if_spell_is_resisted(@enemy.get_magic_dc(spell[:level]), @player_character.mag_resist)
      if spell[:status_effect]
        @message += "#{@player_character.name} has been #{spell[:status_effect]}\n\n"
        effect = StatusEffects.status_effects[spell[:status_effect]]
        implement_status_effect(effect, @player_character.name)
      else
        spell[:affected_stat].each do |stat|
          updated_stat = @player_character.update_stat(stat, -bonus)
          @message += "#{@player_character.name}'s #{stat} has been updated to #{updated_stat}.\n"
        end
      end
      @message += "\n"
      @player_curse_counter = set_list_of_effects(@player_curse_counter, spell, get_spell_time(@enemy, spell[:time], @turn),)
    end
  end

  def enemy_reverse_curse_spells_loop(spells_to_reverse)
    spells_to_reverse.each do |spell|
      bonus = get_bonus(spell[:bonus], @enemy)
      enemy_reverse_curse_spell(spell, bonus)
    end
    @message += "\n"
    @player_curse_counter = restore_list_of_effects(@player_curse_counter, @turn)
  end

  def enemy_reverse_curse_spell(spell, target)
    if spell[:status_effect]
      effect = StatusEffects.status_effects[spell[:status_effect]]
      reverse_status_effect(effect, @player_character.name)
      @message += "#{@player_character.name} has recovered from being #{spell[:status_effect]}\n\n"
    else
      spell[:affected_stat].each do |stat|
        updated_stat = @player_character.update_stat(stat, -bonus)
        @message += "#{@player_character.name}'s #{stat} has been restored to #{updated_stat}.\n"
      end
    end
  end
end