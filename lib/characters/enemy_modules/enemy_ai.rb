module EnemyAI

  def decide_on_an_action(enemy)
    case enemy.skill
    when "magic"
      valid_action = false
      while !valid_action
        # 30% chance to auto attack, 70% chance to cast a spell
        action_number = get_weighted_random([1, 3], ["30", "70"])
        valid_action = numbered_actions(action_number)
      end
    when "1-hand weapon"
      valid_action = false
      while !valid_action
        # 30% chance to auto attack, 50% chance to use a skill, 20% chance to do a cbm
        action_number = get_weighted_random([1, 2, 4], ["30", "50", "20"])
        numbered_actions(action_number)
      end
    when "dual wield weapon"
      valid_action = false
      while !valid_action
        # 70% chance to auto attack, 20% chance to use a skill, 10% chance to perform a cbm
        action_number = get_weighted_random([1, 2, 4], ["70", "20", "10"])
        numbered_actions(action_number)
      end
    when "2-hand weapon"
      valid_action = false
      while !valid_action
        # 70% chance to auto attack, 20% chance to use a skill, 10% chance to perform a cbm
        action_number = get_weighted_random([1, 2, 4], ["60", "30", "10"])
        numbered_actions(action_number)
      end
    when "unarmed weapon"
      valid_action = false
      while !valid_action
        # 30% chance to auto attack, 70% chance to perform a cbm
        action_number = get_weighted_random([1, 4], ["30", "70"])
        numbered_actions(action_number)
      end
    end
  end

  def numbered_actions(action_number, enemy)
    case action_number
    when "1"
      # auto attack
    when "2"
      # use a skill
    when "3"
      # cast a spell
      if enemy.mana <= 0
        # no mana -- can't cast a spell
        return false
      elsif !check_if_enough_mana_for_any_spell(enemy)
        # not enough mana for any known spell
        return false
      else
        valid_spell = false
        while !valid_spell
          spell_count = enemy.known_spells.length
          if spell_count == 0
            # doesn't know any spells!
            return false
          end
          random_spell = rand(1..spell_count)
          random_spell = enemy.known_spells[enemy.known_spells.keys.sample]
          if random_spell[:mana_cost] <= enemy.mana
            # cast the spell
          else
            # can't cast spell -- try to get another random spell.
          end
        end
      end
    when "4"
      # do a cbm
    when "5"
      # use an item
    end 
  end

  def check_if_enough_mana_for_any_spell(enemy)
    enemy.known_spells.each_pair do |key, value|
      if value[:mana_cost] <= enemy.mana
        return true
      end
    end
    return false
  end

  def enemy_cast_spell(spell, enemy)
    case spell[:type]
    when "damage"
    when "healing"
    when "buff"
    when "curse"
    end
  end

  def get_weighted_random(which_numbers, number_weight)
    # which_numbers = [1, 3]  
    # number_weight = [3, 7]
    # random_number_array = [1, 1, 1, 3, 3, 3, 3, 3, 3, 3]
    # random_number_array.sample = weighted_random_number
    # return weighted_random_number
    count = 0
    random_number_array = []
    which_numbers.each do |number|
      number_weight[count].times do
        random_number_array.push(number)
      end
      count += 1
    end
    weighted_random_number = random_number_array.sample
    return weighted_random_number
  end

end