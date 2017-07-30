require 'minitest/autorun'
require_relative "../lib/characters/player_characters/character_for_unit_tests.rb"

class CharacterCalculationsTest < Minitest::Test

  def setup
    @test_character = CharacterForUnitTests.new("Test Character", "test")
    @test_character.create_test_character
  end

  def test_base_calculations
    assert_equal(2, @test_character.bab, "Bab is not 2. It is: #{@test_character.bab}")
    assert_equal(14, @test_character.ac, "AC is not 18, It is: #{@test_character.ac}")

    #hp can be random number between 9 and 18 + 2 so between 11 and 20, 3 times as level 3
    assert(@test_character.hp.between?(33, 60), "HP is not in valid range. It is: #{@test_character.hp}")
  end

  def test_magic_resist_calculation
    assert_equal(5, @test_character.mag_resist, "Magic resist is not 5. It is: #{@test_character.mag_resist}")
  end

  def test_cbm_calculation
    assert_equal(4, @test_character.cbm, "CBM is not 4. It is: #{@test_character.cbm}")

    assert_equal(18, @test_character.cbm_def, "CBM defence is not 18. It is: #{@test_character.cbm_def}")
  end

  def test_attack_and_damage_calculation
    assert_equal(5, @test_character.one_hand_atk, 
                 "One Hand Attack is not 5. It is: #{@test_character.one_hand_atk}")

    assert_equal(6, @test_character.two_hand_damage, 
                 "Two Hand Damage is not 6. It is: #{@test_character.two_hand_damage}")

    assert_equal("bronze sword", @test_character.equipped_weapon[:name])
    assert_equal(5, @test_character.attack, "Attack is not 5. It is: #{@test_character.attack}")
    assert_equal(3, @test_character.damage, "Damage is not 3. It is: #{@test_character.damage}")
  end

end