module CharacterCombat
    def create_attack_object
    attack_object = {
      auto_attack: nil,
      auto_attack_damage: nil,
      cbm_attack: nil,
      cbm: nil,
      spell_dc: nil,
      spell: nil,
      message: ""
    }

    return attack_object
  end

  def update_attack_object(attack_hash, attack_object)
    attack_hash.each_pair do |key, value|
      if key == :message
        attack_object[key] += value
      else
        attack_object[key] = value
      end
    end

    return attack_object
  end

  def get_which_action(action)
    if action == "swing your #{equipped_weapon[:name]}" || action == "1"
      #auto attack
      return update_attack_object(auto_attack, create_attack_object)
    elsif action == "use a skill" || action == "2"
      # use a skill
      @message += "You can't use that option yet..."
      #turn has not been taken -- returning false
      return false
    elsif action == "cast a spell" || action == "3"
      # cast a spell
      return get_which_spell
    elsif action == "perform a combat maneuver" || action == "4"
      # do cbm
      #return player_perform_cbm
      return false
    elsif action == "use an item" || action == "5"
      # use an item
      #return player_use_item
      return false
    elsif action == "equip a weapon" || action == "6"
      # equip a weapon
      #return player_equip_weapon
      return false
    else 
      @message += "#{action} is not an option. Please select an action from the list."
      return false
    end
  end

  def defend(attack_object)
    return decode_attack_object(attack_object)
  end

  def decode_attack_object(attack_object)
    message = ""
    if attack_object[:auto_attack]
      message += defend_from_auto_attack(attack_object[:auto_attack], attack_object[:auto_attack_damage])
    end
    if attack_object[:cbm]
    end
    if attack_object[:spell]
      message += defend_against_spell(attack_object[:spell_dc], attack_object[:spell])
    end
    return message
  end

  def take_damage(damage)
    message = "#{@name} takes #{damage} points of damage.\n\n"
    @hp -= damage
    return message
  end
end