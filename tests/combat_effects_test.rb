require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CombatEffectsTest < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def test_implement_status_effect
    effect = {name: "sickened", affected_stat: ["attack", "damage", "magic resist"], penalty: -2}
    target_name = @combat_session.enemy.name
    expected_attack = @combat_session.enemy.attack - 2
    expected_damage = @combat_session.enemy.damage - 2
    expected_magic_resist = @combat_session.enemy.mag_resist - 2
    @combat_session.implement_status_effect(effect, target_name)

    assert_equal(expected_attack, @combat_session.enemy.attack, 
      "When the enemy is sickened, his attack should be less two.")
    assert_equal(expected_damage, @combat_session.enemy.damage, 
      "When the enemy is sickened, his damage should be less two.")
    assert_equal(expected_magic_resist, @combat_session.enemy.mag_resist, 
      "When the enemy is sickened, his magic resist should be less two.")

    effect = {name: "blinded", affected_stat: ["attack", "ac"], penalty: -3}
    target_name = @combat_session.player_character.name
    expected_attack = @combat_session.player_character.attack - 3
    expected_ac = @combat_session.player_character.ac - 3
    expected_magic_resist = @combat_session.player_character.mag_resist
    @combat_session.implement_status_effect(effect, target_name)

    assert_equal(expected_attack, @combat_session.player_character.attack, 
      "When the player is blinded, his attack should be less three.")
    assert_equal(expected_ac, @combat_session.player_character.ac, 
      "When the player is blinded, his ac should be less three.")
    assert_equal(expected_magic_resist, @combat_session.player_character.mag_resist, 
      "When the player is blinded, his magic resist should not be changed.")
  end

  def test_reverse_status_effect
    effect = {name: "sickened", affected_stat: ["attack", "damage", "magic resist"], penalty: -2}
    target_name = @combat_session.enemy.name
    expected_attack = @combat_session.enemy.attack + 2
    expected_damage = @combat_session.enemy.damage + 2
    expected_magic_resist = @combat_session.enemy.mag_resist + 2
    @combat_session.reverse_status_effect(effect, target_name)

    assert_equal(expected_attack, @combat_session.enemy.attack, 
      "When the enemy is sickened, his attack should be greater two.")
    assert_equal(expected_damage, @combat_session.enemy.damage, 
      "When the enemy is sickened, his damage should be greater two.")
    assert_equal(expected_magic_resist, @combat_session.enemy.mag_resist, 
      "When the enemy is sickened, his magic resist should be greater two.")

    effect = {name: "blinded", affected_stat: ["attack", "ac"], penalty: -3}
    target_name = @combat_session.player_character.name
    expected_attack = @combat_session.player_character.attack + 3
    expected_ac = @combat_session.player_character.ac + 3
    expected_magic_resist = @combat_session.player_character.mag_resist
    @combat_session.reverse_status_effect(effect, target_name)

    assert_equal(expected_attack, @combat_session.player_character.attack, 
      "When the player is blinded, his attack should be greater three.")
    assert_equal(expected_ac, @combat_session.player_character.ac, 
      "When the player is blinded, his ac should be greater three.")
    assert_equal(expected_magic_resist, @combat_session.player_character.mag_resist, 
      "When the player is blinded, his magic resist should not be changed.")
  end

  def test_check_for_effect_expiration
    list_of_current_effects = {3 => ["spell1"], 4 => ["spell2", "spell4"], 5 => ["spell3"]}
    turn = 4
    assert_equal(["spell2", "spell4"], @combat_session.check_for_effect_expiration(list_of_current_effects, turn),
      "Function should return the spells that are expiring on the turn sent in.")

    turn = 2 
    assert(!@combat_session.check_for_effect_expiration(list_of_current_effects, turn),
      "Function should return false if there are no effects expiring this turn.")   
  end

  def test_set_list_of_effects
    counter = {3 => ["spell1"], 4 => ["spell2"], 5 => ["spell3"]}
    spell = "spell4"
    time_to_expire = 4
    new_counter = {3 => ["spell1"], 4 => ["spell2", "spell4"], 5 => ["spell3"]}

    resulting_counter = @combat_session.set_list_of_effects(counter, spell, time_to_expire)
    assert_equal(new_counter, resulting_counter,
      "When a buff spell is cast to expire at the same time as another spell, it should be added to the effect array.")

    counter = {3 => ["spell1"], 4 => ["spell2"], 5 => ["spell3"]}
    spell = "spell4"
    time_to_expire = 7
    new_counter = {3 => ["spell1"], 4 => ["spell2"], 5 => ["spell3"], 7 => ["spell4"]}

    resulting_counter = @combat_session.set_list_of_effects(counter, spell, time_to_expire)
    assert_equal(new_counter, resulting_counter,
      "The buff spell should be appended to the end of the array.")
  end

  def test_restore_list_of_effects
    counter = {4 => ["spell2", "spell4"], 5 => ["spell3"]}
    turn = 4
    counter_should_be = {5 => ["spell3"]}
    actual_counter = @combat_session.restore_list_of_effects(counter, turn)
    assert_equal(counter_should_be, actual_counter,
      "The counter should remove the reference to the spell at the turn sent in.")
  end
end