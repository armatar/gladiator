require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CastDamageSpellTest < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def test_get_base_spell_damage
    spell = {number_of_dice: 1, dice:6}
    bonus = 1
    valid_damage = (2..12).to_a

    assert_includes(valid_damage, @combat_session.get_base_spell_damage(spell, bonus),
      "Damage should be a result of 2d6. (2-12)")
  end

  def test_get_full_spell_damage
    base_damage = 10 
    bonus_damage = 5
    assert_equal(15, @combat_session.get_full_spell_damage(base_damage, bonus_damage),
      "Base damage (10) + bonus damage (5) should be added (15)")
  end

  def test_coordinate_damage
    spell = {number_of_dice_bonus: "level", damage_bonus: false, 
      dice: 4, number_of_dice: 1, bonus_missles: "proficiency"}
    @player_character.level = 1
    @player_character.magic_prof = 1
    acceptable_damage = (2..8).to_a

    assert_includes(acceptable_damage, @combat_session.coordinate_damage(@player_character, spell),
      "2d4 damage should end with damage between 2 and 8.")
  end

  def test_loop_through_missles
    spell = {number_of_dice_bonus: "level", damage_bonus: false, 
      dice: 4, number_of_dice: 1, bonus_missles: "proficiency"}
    missles = 2
    @player_character.level = 1
    acceptable_damage = (4..16).to_a

    assert_includes(acceptable_damage, @combat_session.loop_through_missles(@player_character, spell, missles),
      "2d4 twice damage should end with damage between 4 and 16.")
  end
end