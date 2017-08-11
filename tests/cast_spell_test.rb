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

  def test_determine_if_user_has_spell
    spell_name = "magic missle"
    assert(@combat_session.determine_if_user_has_spell(spell_name), 
      "Player has '#{spell_name}'' in their list of known spells so the function should return true.")

    spell_name = "spell that doesn't exist"
    assert(!@combat_session.determine_if_user_has_spell(spell_name), 
      "'#{spell_name}' does not exist in player's known spells so the function should turn false.")
  end

  def test_determine_type_of_spell
    spell = @combat_session.player_character.known_spells["magic missle"]
    @mock.expect :call, nil, [spell]
    @combat_session.stub(:cast_damage_spell, @mock) do
      @combat_session.determine_type_of_spell(spell)
    end

    spell = @combat_session.player_character.known_spells["cure light wounds"]
    @mock.expect :call, nil, [spell]
    @combat_session.stub(:cast_healing_spell, @mock) do
      @combat_session.determine_type_of_spell(spell)
    end
  end

end