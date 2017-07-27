require_relative "combat.rb"
require_relative "random_enemy_factory.rb"
require_relative "test_character.rb"

class TestingCombat

  def initialize
    @enemy_one = RandomEnemyFactory.new(1)
    @enemy_one.create_random_enemy("enemy1", "monster")

    @player = TestCharacter.new("Player", "Eastern")
    @player.create_test_character
  end

  def fight
    @fight = Combat.new(@player, @enemy_one.random_enemy)
    @fight.turn_based_combat
  end
end

test = TestingCombat.new
test.fight