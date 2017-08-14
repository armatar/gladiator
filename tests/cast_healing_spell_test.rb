require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CastHealingSpellTest < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
    @spell = {name: "cure light wounds", level: 1, type: "healing", attribute: "hp", dice: 8, number_of_dice: 1, 
           healing_bonus: "proficiency", number_of_dice_bonus: false, casting_cost: 20, cost_pool: "mana", price: 200,
           description: "You use your magic to mend some of your cuts and bruises. \nHeals 1d8 + magic proficiency point per level."}
  end

  def test_cast_healing_spell
    @player_character.magic_prof = 3
    @player_character.hp = 9
    @player_character.max_hp = 10
    assert_equal(1, @combat_session.cast_healing_spell(@spell, @player_character),
      "The healing returned can never exceed the caster's max HP.")

    @player_character.max_hp = 100
    possible_healing = (4..11).to_a
    assert_includes(possible_healing, @combat_session.cast_healing_spell(@spell, @player_character),
      "The healing returned can never exceed the caster's max HP.")
  end

  def test_coordinate_healing
    @player_character.magic_prof = 3
    possible_healing = (4..11).to_a
    assert_includes(possible_healing, @combat_session.coordinate_healing(@player_character, @spell), 
      "1d8 +3 should result in a healing number between 4 and 11.")

  end

  def test_get_base_spell_healing
    number_of_dice_bonus = 0
    possible_healing = (1..8).to_a
    assert_includes(possible_healing, @combat_session.get_base_spell_healing(@spell, number_of_dice_bonus),
      "1d8 healing should result in healing between 1 and 8.")

    number_of_dice_bonus = 2
    possible_healing = (3..24).to_a
    assert_includes(possible_healing, @combat_session.get_base_spell_healing(@spell, number_of_dice_bonus),
      "3d8 healing should result in healing between 3 and 24.")
  end

  def test_get_full_spell_healing
    base_healing = 8
    bonus_healing = 2
    assert_equal(10, @combat_session.get_full_spell_healing(base_healing, bonus_healing), 
      "When the base healing is 8 and the bonus damage is 2, the full damage should be 10")
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