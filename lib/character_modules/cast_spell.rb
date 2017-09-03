require_relative '../user_interface.rb'

module CastSpell
  include UserInterface

  def spell_pre_checks(spell)
    if spell[:type] == "healing"
      if !check_if_fully_healed(spell[:attribute])
        return account_for_cost(spell)
      else
        return false
      end
    else
      return account_for_cost(spell)
    end
  end

  def account_for_cost(spell)
    if has_enough_to_cast?(spell)
      if spell[:cost_pool] == "mana"
        @mana -= spell[:casting_cost]
      elsif spell[:cost_pool] == "hp"
        @hp -= spell[:casting_cost]
      end
      cast_spell(spell)
      return @spell_object
    else
      @spell_object[:message] += "Not enough #{spell[:cost_pool]} to cast #{spell[:name]}!\n"
      return false
    end
  end

  def cast_spell(spell)
    if check_if_overcome_spell_failure(@spell_failure_chance)
      @spell_object[:message] += "#{@name} casts #{spell[:name]}! \n"
      coordinate_cast(spell, spell[:type])
    end
  end

  def coordinate_cast(spell, type)
    if type == "damage"
      cast_damage_spell(spell)
    elsif type == "healing"
      cast_healing_spell(spell)
    elsif type == "buff"
      cast_buff_spell(spell, get_bonus(spell[:bonus], @player_character))
    elsif type == "curse"
      cast_curse_spell(spell, get_bonus(spell[:bonus], @player_character))
    elsif type == "hybrid"
      cast_hybrid_spell(spell)
    end
  end

  def player_cast_hybrid_spell(spell)
    spell[:hybrid_types].each do |type|
      player_coordinate_cast(spell, type)
    end
  end

  def cast_damage_spell(spell)
    @spell_object[:spell_dc] = get_spell_dc(spell[:level])
    damage = get_spell_damage(spell)
    @spell_object[:spell] = {name: spell[:name], type: spell[:type], damage: damage}
  end

  def cast_healing_spell(spell)
    healing = get_healing(spell)
    @hp += healing
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

  def check_if_overcome_spell_failure(spell_failure_chance, percent_roll=roll_dice(1, 100, 1))
    if percent_roll > spell_failure_chance
      return true
    else
      @spell_object[:message] += "Spell Fail Chance(#{spell_failure_chance}%): The spell fizzles and dies...\n\n"
      return false
    end
  end

  def has_enough_to_cast?(spell)
    if spell[:cost_pool] == "mana"
      if @mana >= spell[:casting_cost]
        return true
      else
        return false
      end
    elsif spell[:cost_pool] == "hp"
      if @hp >= spell[:casting_cost]
        return true
      else
        return false
      end
    end
  end

  def get_bonus(bonus_to_get)
    if bonus_to_get == "proficiency"
      return @magic_prof
    elsif bonus_to_get == "level"
      return @level
    elsif bonus_to_get == "magic"
      return @mag_modifier
    elsif bonus_to_get == "charisma"
      return @cha_modifier
    elsif bonus_to_get == false
      return 0
    end
  end

  def get_spell_time(time, turn)
    if time == "level"
      return calculate_expiration_turn(@level, turn)
    elsif time == "charisma"
      return calculate_expiration_turn(@cha_modifier, turn)
    elsif time == "magic"
      return calculate_expiration_turn(@mag_modifier, turn)
    elsif time == "proficiency"
      return calculate_expiration_turn(@magic_prof, turn)
    else
      return calculate_expiration_turn(time, turn)
    end
  end
end