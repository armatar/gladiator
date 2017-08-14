require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CastBuffSpellTest < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def test_set_buff_counter
    counter = {3 => ["spell1"], 4 => ["spell2"], 5 => ["spell3"]}
    spell = "spell4"
    time_to_expire = 4
    new_counter = {3 => ["spell1"], 4 => ["spell2", "spell4"], 5 => ["spell3"]}

    resulting_counter = @combat_session.set_buff_counter(counter, spell, time_to_expire)
    assert_equal(new_counter, resulting_counter,
      "When a buff spell is cast to expire at the same time as another spell, it should be added to the effect array.")

    counter = {3 => ["spell1"], 4 => ["spell2"], 5 => ["spell3"]}
    spell = "spell4"
    time_to_expire = 7
    new_counter = {3 => ["spell1"], 4 => ["spell2"], 5 => ["spell3"], 7 => ["spell4"]}

    resulting_counter = @combat_session.set_buff_counter(counter, spell, time_to_expire)
    assert_equal(new_counter, resulting_counter,
      "The buff spell should be appended to the end of the array.")
  end

  def test_restore_buff_counter
    counter = {4 => ["spell2", "spell4"], 5 => ["spell3"]}
    turn = 4
    counter_should_be = {5 => ["spell3"]}
    actual_counter = @combat_session.restore_buff_counter(counter, turn)
    assert_equal(counter_should_be, actual_counter,
      "The counter should remove the reference to the spell at the turn sent in.")
  end
end