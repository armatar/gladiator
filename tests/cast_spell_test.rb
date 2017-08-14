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

  def test_get_spell_if_exist
    spell_name = "magic missle"
    retrieved_spell = @combat_session.get_spell_if_exist(spell_name)
    assert_equal(spell_name, retrieved_spell[:name], 
      "Player has '#{spell_name}'' in their list of known spells so the function should return true")

    spell_name = "spell that doesn't exist"
    assert(!@combat_session.get_spell_if_exist(spell_name), 
      "'#{spell_name}' does not exist in player's known spells so the function should turn false")
  end

  def test_check_if_overcome_spell_failure
    spell_failure_chance = 100
    assert(!@combat_session.check_if_overcome_spell_failure(spell_failure_chance),
      "When spell failure chance is 100%, the spell will fail and the function should return false")

    spell_failure_chance = 0
    assert(@combat_session.check_if_overcome_spell_failure(spell_failure_chance),
      "When spell failure chance is 0%, the spell should succeed and the function should return true")
  end

  def test_check_if_spell_is_resisted
    spell_dc = 21
    target_magic_resist =22
    message = "When the target's base magic resist is higher than the spell_dc, they should resist " +
    "the spell and the function should return true."
    assert(@combat_session.check_if_spell_is_resisted(spell_dc, target_magic_resist), message)
  
    target_magic_resist = 0
    message = "When the target's base magic resist is 0 and the spell dc is 21, they should never " +
    "resist the spell and the function should return false."
    assert(!@combat_session.check_if_spell_is_resisted(spell_dc, target_magic_resist), message)
  end

  def test_get_bonus
    bonus = "proficiency"
    @player_character.magic_prof = 5

    assert_equal(5, @combat_session.get_bonus(bonus, @player_character),
      "Function should return the character's magic proficiency when the dice bonus is proficiency.")
  end

  def test_get_spell_time
    @player_character.cha_modifier = 4
    time = "charisma"
    assert_equal(4, @combat_session.get_spell_time(@player_character, time),
      "When the time is 'charisma', the function should return the caster's charisma modifier.")

    time = 5
    assert_equal(5, @combat_session.get_spell_time(@player_character, time),
      "When the time is an integer, the function should return that integer.")
  end

  def test_check_for_effect_expiration
    list_of_current_effects = {3 => ["spell1"], 4 => ["spell2", "spell4"], 5 => ["spell3"]}
    turn = 4
    assert_equal(["spell2", "spell4"], @combat_session.check_for_effect_expiration(list_of_current_effects, turn),
      "Function should return the spells that are expiring on the turn sent in.")
  end
end