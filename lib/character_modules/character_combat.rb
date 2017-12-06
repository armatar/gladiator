require_relative "../status_effects.rb"

module CharacterCombat

    def create_attack_object
    attack_object = {
      auto_attack: nil,
      auto_attack_damage: nil,
      cbm_attack: nil,
      cbm: nil,
      spell_dc: nil,
      spell: nil,
      player_buff_counters: nil,
      enemy_buff_counters: nil,
      continue: true,
      message: ""
    }

    return attack_object
  end

  def create_defense_object
    defense_object = {
      message: "",
      player_curse_counters: nil, 
      enemy_curse_counters: nil
    }
    return defense_object
  end

  def update_object(update_hash, object)
    update_hash.each_pair do |key, value|
      if key == :message
        object[key] += value
      else
        object[key] = value
      end
    end

    return object
  end

  def get_which_action(action)
    if action == "swing your #{equipped_weapon[:name]}" || action == "1"
      #auto attack
      return update_object(auto_attack, create_attack_object)
    elsif action == "use a skill" || action == "2"
      # use a skill
      #turn has not been taken -- returning false
      return update_object({message: "Can't use this action yet.", continue: false}, create_attack_object)
    elsif action == "cast a spell" || action == "3"
      # cast a spell
      return update_object(get_which_spell, create_attack_object)
    elsif action == "perform a combat maneuver" || action == "4"
      # do cbm
      return update_object(player_perform_cbm, create_attack_object)
    elsif action == "use an item" || action == "5"
      # use an item
      #return player_use_item
      return update_object({message: "Can't use this action yet.", continue: false}, create_attack_object)
    elsif action == "equip a weapon" || action == "6"
      # equip a weapon
      #return player_equip_weapon
      return update_object({message: "Can't use this action yet.", continue: false}, create_attack_object)
    else 
      return update_object({message: "Invalid answer.", continue: false}, create_attack_object)
    end
  end

  def defend(attack_object)
    return update_object(decode_attack_object(attack_object), create_defense_object)
  end

  def decode_attack_object(attack_object)
    defense_hash = {message: ""}
    if attack_object[:auto_attack]
      defense_hash = update_object(defend_from_auto_attack(attack_object[:auto_attack], attack_object[:auto_attack_damage]), defense_hash)
    end
    if attack_object[:cbm]
    end
    if attack_object[:spell]
      defense_hash = update_object(defend_against_spell(attack_object[:spell_dc], attack_object[:spell]), defense_hash)
    end
    return defense_hash
  end

  def take_damage(damage)
    message = "#{@name} takes #{damage} points of damage.\n\n"
    @hp -= damage
    return message
  end
end