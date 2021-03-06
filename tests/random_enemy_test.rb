require 'minitest/autorun'
require_relative "../lib/factories/random_enemy_factory.rb"
require_relative "../lib/characters/enemies.rb"

class RandomEnemyTest < Minitest::Test
  def setup
    @random_enemy = Enemies.new
    @enemy_factory = RandomEnemyFactory.new
    @random_enemy = @enemy_factory.create_random_enemy(@random_enemy, 1)
    @enemy_factory.get_random_character_base
  end

  def test_get_points_to_assign
    @enemy_factory.random_enemy.set_level(5)
    points = @enemy_factory.get_points_to_assign
    assert_equal(points, 21, "The random points were #{points}")

    level_groups = {20 => [1,2,3], 21 => [4, 5, 6, 7]}
    level_groups.each_pair do |answer, levels|
      levels.each do |level|
        @enemy_factory.random_enemy.set_level(level)
        assert_equal(answer, @enemy_factory.get_points_to_assign, 
                    "Given that enemy's level is #{level}, expected points to assign should be #{answer}")
      end
    end
  end

  def test_update_random_attribute
    @enemy_factory.get_stat_max("1-hand weapon", "1-hand weapon")
    20.times do 
      @enemy_factory.update_random_attribute(4, 20)
    end
    assert_operator 12, :>=, @enemy_factory.mag,
    "Given that the enemy has 1-hand weapon as their primary and secondary proficiencies, their magic should never be more than 12"
  end

  def test_set_proficiency_points
    @enemy_factory.set_proficiency_points(["1-hand weapon"], 2)
    @enemy_factory.update_random_enemy
    assert_equal(2, @enemy_factory.random_enemy.one_hand_prof, 
      "When the proficiency 1-hand weapon is selected twice, the one_hand_prof variable for the random enemy should be 2.")
  end

  def test_get_equipped_weapon
    @enemy_factory.get_equipped_weapon("magic")
    assert_equal("staff", @random_enemy.equipped_weapon[:type], 
      "When the random enemy's primary skill is magic, their equipped weapon should be type staff")

    @enemy_factory.get_equipped_weapon("1-hand weapon")
    assert_equal("1-hand weapon", @random_enemy.equipped_weapon[:type], 
      "When the random enemy's primary skill is magic, their equipped weapon should be type 1-hand weapon")
  end
end

