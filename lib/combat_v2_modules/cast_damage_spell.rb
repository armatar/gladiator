require_relative '../user_interface.rb'

module CastDamageSpell
  include UserInterface

  def cast_damage_spell(spell, caster)
    bonus_missles = spell[:bonus_missles]
    damage = loop_through_missles(caster, spell, get_bonus(bonus_missles, caster))
    return damage
  end

  def get_base_spell_damage(spell, bonus)
    number_of_dice = spell[:number_of_dice] + bonus
    @message += "Damage: #{number_of_dice}d#{spell[:dice]}"
    damage = roll_dice(1, spell[:dice], number_of_dice)
    return damage
  end

  def get_full_spell_damage(base_damage, bonus_damage)
    damage = base_damage + bonus_damage
    @message += " + #{bonus_damage} = #{damage}. \n"
    return damage
  end

  def coordinate_damage(caster, spell)
    dice_bonus = spell[:number_of_dice_bonus]
    base_damage = get_base_spell_damage(spell, get_bonus(dice_bonus, caster))
    damage_bonus = spell[:damage_bonus]
    damage = get_full_spell_damage(base_damage, get_bonus(damage_bonus, caster))
    return damage
  end

  def loop_through_missles(caster, spell, number_of_missles)
    damage = 0
    number_of_missles.times do
      damage += coordinate_damage(caster, spell)
    end
    return damage
  end
end