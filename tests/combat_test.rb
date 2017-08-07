require 'minitest/autorun'
require_relative '../lib/combat.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CombatTest < Minitest::Test
  def setup
    @character = CharacterForUnitTests.new("test", "human")
    @character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@character, @enemy)
  end

  def test_get_damage
    @character.damage = 5
    @character.equipped_weapon = @character.inventory["bronze sword"]

    assert_equal(18, @combat_session.get_damage(@character, "crit", 4), 
      "Attacker damage should be (4 |die roll| + 5 |damage bonus| ) x 2 |crit| = 18")
    assert_equal(9, @combat_session.get_damage(@character, true, 4), 
      "Attacker damage should be (4 |die roll| + 5 |damage bonus| ) = 9")
  end

  def test_attack_with_weapon
    assert_equal("crit", @combat_session.attack_with_weapon(@character, @enemy, 20),
      "When anyone attacking with their weapon rolls a 20, it is a critical hit and the function should return 'crit'")
    @enemy.ac = 15
    @character.attack = 5
    assert(@combat_session.attack_with_weapon(@character, @enemy, 10),
      "When the enemy's AC is 15, and the character's attack role is 10 + 5 = 15, the function should return true.")
  end

  def test_get_number_of_attacks
    #get_number_of_attacks(attacker)
    two_attack_items = ["bronze dual swords", "bronze knuckles"]
    two_attack_items.each do |item|
      @character.equipped_weapon = @character.inventory[item]
      assert_equal(2, @combat_session.get_number_of_attacks(@character),
        "When a character has a dual wield weapon or unarmed weapon equipped, they should get 2 weapon attacks per turn.")
    end

    single_attack_items = ["bronze sword", "bronze greatsword", "wooden staff"]
    single_attack_items.each do |item|
      @character.equipped_weapon = @character.inventory[item]
      assert_equal(1, @combat_session.get_number_of_attacks(@character),
        "When a character has any weapon equipped aside from a dual wield and unarmed, they should only get one attack per turn.")
    end
  end

end