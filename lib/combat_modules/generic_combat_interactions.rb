require_relative "../user_interface.rb"

module GenericCombatInteractions
  def attack_of_opportunity(attacker)
    if attacker == "ally"
      player_auto_attack
      return check_if_dead
    elsif attacker == "enemy"
      return enemy_turn
    end
  end

  def get_number_of_attacks(attacker)
    number_of_attacks = 1
    if attacker.equipped_weapon[:type] == "dual wield weapon" || attacker.equipped_weapon[:type] == "unarmed weapon"
      number_of_attacks = 2
    end
    return number_of_attacks
  end

  def loop_through_attacks(attacker, target, number_of_attacks)
    damage = 0
    @message += "#{attacker.name} attacks!\n"
    number_of_attacks.times do
      hit = attack_with_weapon(attacker, target, roll_dice(1, 20, 1))
      if hit
        damage += get_damage(attacker, hit, 
          roll_dice(1, attacker.equipped_weapon[:dice], attacker.equipped_weapon[:number_of_dice]))
      end
    end
    return damage
  end

  def attack_with_weapon(attacker, target, die_roll)
    if die_roll >= attacker.equipped_weapon[:crit]
      @message += "#{attacker.name} crits with a #{die_roll}!"
      return "crit"
    else
      attack = die_roll + attacker.attack
      if attack >= target.ac
        @message += "Attack Roll: #{die_roll} + #{attacker.attack} = #{attack}, Target AC: #{target.ac}\n"
        @message += "#{attacker.name} hits!\n"
        return true
      else
        @message += "Attack Roll: #{die_roll} + #{attacker.attack} = #{attack}, Target AC: #{target.ac}\n"
        @message += "#{attacker.name} misses!\n\n"
        return false
      end
    end
  end

  def get_damage(attacker, hit, die_roll)
    damage = 0
    if hit == "crit"
      damage = (die_roll + attacker.damage) * attacker.equipped_weapon[:crit_damage]
      if damage < 0
        damage = 0
      end
      @message += "Crit Damage Roll: (#{die_roll} + #{attacker.damage}) * #{attacker.equipped_weapon[:crit_damage]} = #{damage}\n\n"
    else
      damage = die_roll + attacker.damage
      if damage < 0
        damage = 0
      end
      @message += "Damage Roll: #{die_roll} + #{attacker.damage} = #{damage}\n\n"
    end
    return damage
  end
end