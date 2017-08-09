require_relative '../user_interface.rb'

module CombatMethods
  include UserInterface

  def attack_with_equipped_weapon(attacker, target)
    number_of_attacks = attacker.equipped_weapon[:number_of_attacks]
    return loop_through_attacks(attacker, target, number_of_attacks)
  end

  def loop_through_attacks(attacker, target, number_of_attacks)
    damage = 0

    number_of_attacks.times do
      hit = attempt_to_hit(attacker, target)
      damage += get_damage(attacker, hit)
    end
    
    return damage
  end

  def attempt_to_hit(attacker, target, die_roll=roll_dice(1,20,1))
    attack = attacker.attack + die_roll
    if attack >= target.ac
      return true
    else
      return false
    end
  end

  def get_damage(attacker, hit)
    if hit
      damage_roll = roll_damage(attacker.equipped_weapon[:dice], attacker.equipped_weapon[:number_of_dice])
      return calculate_real_damage(attacker.damage, damage_roll)
    else
      return 0
    end
  end

  def roll_damage(dice_to_roll, number_of_dice)
    return roll_dice(1, dice_to_roll, number_of_dice)
  end

  def calculate_real_damage(damage_bonus, damage_roll)
    damage = damage_roll + damage_bonus
    return damage
  end
end