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
    turn = 2
    assert_equal(7, @combat_session.get_spell_time(@player_character, time, turn),
      "When the time is 'charisma', the function should return the caster's charisma modifier plus the turn plus one.")

    time = 5
    assert_equal(8, @combat_session.get_spell_time(@player_character, time, turn),
      "When the time is an integer, the function should return that integer plus the turn plus one.")
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