require_relative '../user_interface.rb'

module AutoAttack
  include UserInterface

  def auto_attack
    return attack_with_equipped_weapon
  end

  def attack_with_equipped_weapon
    damage = []
    attack = []
    number_of_attacks = @equipped_weapon[:number_of_attacks]
    message = "#{@name} attacks with their #{@equipped_weapon[:name]}! \n"
    number_of_attacks.times do
      attack.push(attempt_to_hit)
      damage.push(get_damage)
    end

    return create_auto_attack_object(attack, damage, message)
  end

  def create_auto_attack_object(attack, damage, message)
    auto_attack_object = {
      auto_attack: attack,
      auto_attack_damage: damage,
      message: message
    }

    return auto_attack_object
  end

  def attempt_to_hit(die_roll=roll_dice(1,20,1))
    attack = @attack + die_roll
    return attack
  end

  def get_damage
    dice_to_roll = @equipped_weapon[:dice]
    number_of_dice = @equipped_weapon[:number_of_dice]

    damage_roll = roll_damage(dice_to_roll, number_of_dice)
    damage = calculate_real_damage(@damage, damage_roll)

    return damage
  end

  def roll_damage(dice_to_roll, number_of_dice)
    return roll_dice(1, dice_to_roll, number_of_dice)
  end

  def calculate_real_damage(damage_bonus, damage_roll)
    damage = damage_roll + damage_bonus

    if damage < 0 
      damage = 0
    end
    return damage
  end

  def defend_from_auto_attack(attack, damage)
    count = 0
    message = ""
    attack.each do |attack|
      message += "Attack: (#{attack})\n"
      if attack >= @ac
        message += "Hit!\n"
        message += take_damage(damage[count])
      else
        message += "Miss!\n\n"
      end
      count += 1
    end
    return {message: message}
  end
end