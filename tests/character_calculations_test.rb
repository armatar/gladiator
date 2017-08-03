require 'minitest/autorun'
require_relative "../lib/characters/player_characters/character_for_unit_tests.rb"

class CharacterCalculationsTest < Minitest::Test

  def setup
    @test_character = CharacterForUnitTests.new("Test Character", "test")
    @test_character.create_test_character
  end

  def test_initial_hp_calculations
    @test_character.set_first_hp(5, [15,30], 4)
    min = 95
    max = 170
    message = "When the character's level is 5, their con modifier is 4, and the range of die roll is 15-30, " +
              "their HP should be between #{min} and #{max}. HP was #{@test_character.hp}"
    assert(@test_character.hp.between?(min,max), message)
  end

  def test_get_hp_range
    assert_equal([9,18], @test_character.get_hp_range(2),
      "When the character's con modifier is 2, the hp ranged returned should be [9,18]" )
  end

  def test_calculate_bab
    level_groups = {1 => [1], 2 => [2, 3], 3 => [4, 5]}
    level_groups.each_pair do |answer, levels|
      levels.each do |level|
        assert_equal(answer, @test_character.calculate_bab(level), 
          "When the character's level is #{level}, the base attack bonus should be #{answer}" )
      end
    end
  end

  def test_calculate_magic_resist
    magic_modifier = 4
    magic_prof = 2
    answer_and_cha_modifier = {6 => [1], 7 => [2, 3], 8 => [4, 5]}
    answer_and_cha_modifier.each_pair do |answer, cha_modifiers|
      cha_modifiers.each do |cha_modifier|
        message = "When the character's magic modifier is #{magic_modifier}, magic proficiency is " +
                  "#{magic_prof}, and charisma modifier is #{cha_modifier}, the magic resist should " +
                  "be #{answer}."
        assert_equal(answer, @test_character.calculate_magic_resist(magic_modifier, cha_modifier, magic_prof), message )
      end
    end
  end
end