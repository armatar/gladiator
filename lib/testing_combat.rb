require_relative "combat.rb"
require_relative "random_enemies.rb"
require_relative "player_character.rb"
require_relative "spells.rb"
require_relative "spell_effects.rb"

class TestingCombat
  attr_reader :spells, :player

  def initialize(level1, level2)
    @enemy_one = RandomEnemies.new(level1)
    @enemy_one.create_random_enemy("enemy1", "monster")
    @enemy_two = RandomEnemies.new(level2)
    @enemy_two.create_random_enemy("enemy2", "monster")

    @player = PlayerCharacter.new("Player", "Eastern")
    @player.create_test_character
=begin
    @spells = Spells.new
    @spells.create_spell_list
    @spells = @spells.spells
    @spell_effects = SpellEffects.new
=end
  end

=begin
  def cast_spells
    system "clear"
    @enemy_one.hp = cast_spell_full(@spells["burning hands"], @player, @enemy_one)
    puts "-" * 50
    @player.hp = cast_spell_full(@spells["magic missle"], @enemy_one, @player)
    puts "-" * 50
    @player.hp = cast_spell_full(@spells["cure light wounds"], @player, @enemy_one)
  end

  def cast_spell_full(spell, caster, target)
    puts "This is #{target.name}'s current HP: #{target.hp}/#{target.max_hp}"
    puts "This is #{caster.name}'s HP: #{caster.hp}/#{caster.max_hp}"
    puts "Casting #{spell[:name]}..."
    if spell[:type] == "damage"
      damage = @spell_effects.cast_damage_spell(spell, caster, target)
      target.hp -= damage
      puts "This is #{target.name}'s current HP: #{target.hp}/#{target.max_hp}"
      return target.hp
    elsif spell[:type] == "healing"
      healing = @spell_effects.cast_healing_spell(spell, caster, target)
      caster.hp += healing
      puts "This is #{caster.name}'s HP: #{caster.hp}/#{caster.max_hp}"
      return caster.hp
    end
  end
=end
  def fight
    @fight = Combat.new(@player, @enemy_two)
    @fight.turn_based_combat
  end
end

test = TestingCombat.new(3, 5)
test.fight
puts "player ac: #{test.player.ac}"