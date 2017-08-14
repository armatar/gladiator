require_relative '../user_interface.rb'

module AutoAttack
  include UserInterface

  def attack_with_equipped_weapon(attacker, target)
    damage = 0
    number_of_attacks = attacker.equipped_weapon[:number_of_attacks]

    number_of_attacks.times do
      @message += "#{attacker.name} attacks with their #{attacker.equipped_weapon[:name]}!\n"
      damage +=  get_damage(attacker, attempt_to_hit(attacker, target))
    end

    return damage
  end

  def attempt_to_hit(attacker, target, die_roll=roll_dice(1,20,1))
    attack = attacker.attack + die_roll
    @message += "Attack: #{attacker.attack} + #{die_roll} = #{attack}, Target: #{target.ac}\n"
    if attack >= target.ac
      @message += "#{attacker.name} hits!\n"
      return true
    else
      @message += "#{attacker.name} misses!\n\n"
      return false
    end
  end

  def get_damage(attacker, hit)
    if hit
      dice_to_roll = attacker.equipped_weapon[:dice]
      number_of_dice = attacker.equipped_weapon[:number_of_dice]

      damage_roll = roll_damage(dice_to_roll, number_of_dice)
      damage = calculate_real_damage(attacker.damage, damage_roll)

      return damage
    else
      return 0
    end
  end

  def roll_damage(dice_to_roll, number_of_dice)
    return roll_dice(1, dice_to_roll, number_of_dice)
  end

  def calculate_real_damage(damage_bonus, damage_roll)
    damage = damage_roll + damage_bonus
    @message += "Damage: #{damage_roll} + #{damage_bonus} = #{damage}\n\n"
    return damage
  end
end