require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CombatMethodsV2 < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def test_attack_with_equipped_weapon
  	@enemy.ac = 0
    @player_character.damage = 2
    @player_character.equipped_weapon = @player_character.inventory["bronze sword"]
    possible_damage = [3, 4, 5, 6, 7, 8]

  	assert_includes(possible_damage, @combat_session.attack_with_equipped_weapon(@player_character, @enemy))

    @player_character.equipped_weapon = @player_character.inventory["bronze dual swords"]
    @mock.expect :call, 5, [@player_character, true]
    @mock.expect :call, 5, [@player_character, true]
    @combat_session.stub(:get_damage, @mock) do
      @combat_session.attack_with_equipped_weapon(@player_character, @enemy)
    end
    assert(@mock.verify)
  end

  def test_attempt_to_hit
    @enemy.ac = 0
    assert(@combat_session.attempt_to_hit(@player_character, @enemy), 
      "When the the attacker's attack is higher than the target's ac, the function should return true.")
    @enemy.ac = 100
    assert(!@combat_session.attempt_to_hit(@player_character, @enemy), 
      "When the the attacker's attack is lower than the target's ac, the function should return false.")
  end

  def test_get_damage
    @player_character.damage = 2
    @player_character.equipped_weapon = @player_character.inventory["bronze sword"]
    possible_damage = [3, 4, 5, 6, 7, 8]
    hit = true

    assert_includes(possible_damage, @combat_session.get_damage(@player_character, hit),
      "When the player's equipped weapon is a bronze sword and their damage bonus is 2, the possible damage outcomes are #{possible_damage}")

    hit = false
    assert_equal(0, @combat_session.get_damage(@player_character, hit),
      "When the variable 'hit' is false, the function should return 0 damage")
  end

  def test_roll_damage
    dice_to_roll = 4
    number_of_dice = 2
    possible_dice_roll = [2, 3, 4, 5, 6, 7, 8]

    assert_includes(possible_dice_roll, @combat_session.roll_damage(dice_to_roll, number_of_dice),
      "When the dice to roll is 4 and the number of dice is 2, this function should return one of these numbers: #{possible_dice_roll}")
  end

  def test_calculate_real_damage
    damage_bonus = 5
    damage_roll = 4

    assert_equal(9, @combat_session.calculate_real_damage(damage_bonus, damage_roll),
      "Function should add damage bonus (5) and damage roll (4) and return the sum (9)")
  end

end