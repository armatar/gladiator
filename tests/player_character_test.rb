require 'minitest/autorun'
require_relative "../lib/player_character.rb"

class PlayerCharacterTest < Minitest::Test

  def setup
    @player_character = Player_Character.new("Test Character", "test")
    @player_character.create_test_character
  end

  def test_base_calculations
    assert_equal(2, @player_character.bab, "Bab is not 3. It is: #{@player_character.bab}")
    assert_equal(18, @player_character.ac, "Bab is not 18, It is: #{@player_character.ac}")

    #hp can be random number between 9 and 18 + 2 so between 11 and 20, 3 times as level 3
    assert(@player_character.hp.between?(33, 60), "HP is not in valid range. It is: #{@player_character.hp}")
  end

  def test_magic_resist_calculation
    assert_equal(4, @player_character.mag_resist, "Magic resist is not 6. It is: #{@player_character.mag_resist}")
  end

  def test_cbm_calculation
    assert_equal(3, @player_character.cbm, "CBM is not 3. It is: #{@player_character.cbm}")

    assert_equal(17, @player_character.cbm_def, "CBM defence is not 17. It is: #{@player_character.cbm_def}")
  end

  def test_attack_and_damage_calculation
    assert_equal(3, @player_character.one_hand_atk, 
                 "One Hand Attack is not 3. It is: #{@player_character.one_hand_atk}")

    assert_equal(2, @player_character.dual_wield_damage, 
                 "Dual Wield Damage is not 2. It is: #{@player_character.dual_wield_damage}")

    assert_equal(3, @player_character.attack, "Attack is not 3. It is: #{@player_character.attack}")
    assert_equal(1, @player_character.damage, "Damage is not 1. It is: #{@player_character.damage}")
  end

end