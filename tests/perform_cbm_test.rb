require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'
require_relative '../lib/combat_maneuvers.rb'

class PerformCBMTest < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def test_cbm_attack_attempt
    dice_roll = 1
    @player_character.cbm = 1
    @enemy.cbm_def = 10
    assert(!@combat_session.cbm_attack_attempt(@player_character, @enemy, dice_roll), 
      "When the dice role plus the attacker's cbm bonus does not equal the cbm defence of the target, the function should return false.")

    dice_roll = 20
    assert(@combat_session.cbm_attack_attempt(@player_character, @enemy, dice_roll), 
      "When the dice role plus the attacker's cbm bonus is greater than the cbm defence of the target, the function should return true.")

  end

  def test_get_cbm_if_exist
    valid_maneuver = CombatManeuvers.maneuvers["grapple"]
    cbm_name = "grapple"
    assert_equal(valid_maneuver, @combat_session.get_cbm_if_exist(cbm_name),
      "When #{cbm_name} is sent in, the function should return the full maneuver.")

    cbm_name = "not a valid cbm"
    assert(!@combat_session.get_cbm_if_exist(cbm_name),
      "When an invalid CBM is sent in, the function should return false.")
  end

  def test_attempt_to_gain_control
    dice_roll = 14
    @player_character.cbm = 1
    @enemy.cbm_def = 10
    assert(@combat_session.attempt_to_gain_control(@player_character, @enemy, dice_roll), 
      "Die roll + grappled person's cbm needs to be higher than the enemy's cbm defense plus 5 to gain control of a grapple.")

    dice_roll = 9
    assert(!@combat_session.attempt_to_gain_control(@player_character, @enemy, dice_roll), 
      "Grappled person has to have a score higher than the grappler's cbm defense plus 5.")

  end
end