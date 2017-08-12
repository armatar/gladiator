require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CastSpellTest < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def test_get_max_healing
    healing = 10
    hp = 5
    max_hp = 10

    assert_equal(5, @combat_session.get_max_healing(healing, hp, max_hp),
      "When a caster is being healed by 10 but their hp is 5 and their max hp is 10, then the function should return 5.")
    max_hp = 20

    assert_equal(10, @combat_session.get_max_healing(healing, hp, max_hp),
      "When a caster is being healed by 10 but their hp is 5 and their max hp is 20, then the function should return 10.")
  end
end