require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CombatV2Test < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def test_player_goes_first
    player_character_init = 10
    enemy_init = 5
    assert(@combat_session.player_goes_first?(player_character_init, enemy_init), 
      "When the player's initiative is higher than the enemy's, function should return true.")

    player_character_init = 5
    enemy_init = 10
    assert(!@combat_session.player_goes_first?(player_character_init, enemy_init), 
      "When the player's initiative is lower than the enemy's, function should return false.")
  end

  def test_turn_based_combat
    @mock.expect :call, nil, [true]
    @mock.expect :call, nil, [false]
    @combat_session.stub(:combat_phase, @mock) do
      @combat_session.turn_based_combat(true)
    end

    @mock.expect :call, false, [@player_character.hp, @enemy.hp]
    @mock.expect :call, false, [@player_character.hp, @enemy.hp]
    @combat_session.stub(:check_for_death, @mock) do
      @combat_session.turn_based_combat(true)
    end

    assert(@mock.verify)
  end

  def test_combat_phase
    @mock.expect :call, nil
    @combat_session.stub(:player_phase, @mock) do
      @combat_session.combat_phase(true)
    end
    assert(@mock.verify)

    @mock.expect :call, nil
    @combat_session.stub(:enemy_phase, @mock) do
      @combat_session.combat_phase(false)
    end
    assert(@mock.verify)
  end
end
