require_relative '../user_interface.rb'

module CastDamageSpell
  include UserInterface

  def get_spell_damage(spell)
    bonus_missles = spell[:bonus_missles]
    damage = loop_through_missles(spell, get_bonus(bonus_missles))
    return damage
  end

  def get_base_spell_damage(spell, bonus)
    number_of_dice = spell[:number_of_dice] + bonus
    damage = roll_dice(1, spell[:dice], number_of_dice)
    return damage
  end

  def get_full_spell_damage(base_damage, bonus_damage)
    damage = base_damage + bonus_damage
    return damage
  end

  def ensure_damage_is_positive(damage)
    if damage < 0
      return 0
    else
      return damage
    end
  end

  def coordinate_damage(spell)
    dice_bonus = spell[:number_of_dice_bonus]
    base_damage = get_base_spell_damage(spell, get_bonus(dice_bonus))
    damage_bonus = spell[:damage_bonus]
    damage = get_full_spell_damage(base_damage, get_bonus(damage_bonus))
    damage = ensure_damage_is_positive(damage)
    return damage
  end

  def loop_through_missles(spell, number_of_missles)
    damage = 0
    if number_of_missles == 0
      number_of_missles = 1
    end
    number_of_missles.times do
      damage += coordinate_damage(spell)
    end
    return damage
  end
end