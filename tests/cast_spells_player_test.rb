require 'minitest/autorun'
require_relative '../lib/combat_v2.rb'
require_relative '../lib/characters/player_characters/character_for_unit_tests.rb'
require_relative '../lib/characters/enemies/enemy_for_unit_tests.rb'

class CastSpellsPlayerTest < Minitest::Test
  def setup
    @mock = MiniTest::Mock.new
    @player_character = CharacterForUnitTests.new("test", "human")
    @player_character.create_character
    @enemy = EnemyForUnitTests.new
    @enemy.create_enemy
    @combat_session = Combat.new(@player_character, @enemy, "special event")
  end

  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def with_stdin
    stdin = $stdin             # remember $stdin
    $stdin, write = IO.pipe    # create pipe assigning its "read end" to $stdin
    yield write                # pass pipe's "write end" to block
  ensure
    write.close                # close pipe
    $stdin = stdin             # restore $stdin
  end

  def test_player_get_spell
    spell = {name: "magic missle", level: 1, type: "damage", dice: 4, number_of_dice: 1, damage_bonus: "magic", 
           number_of_dice_bonus: "level", bonus_missles: "proficiency", casting_cost: 15, cost_pool: "mana", price: 150,
           description: "Missles shoot from your fingers toward your opponent. \nDeals 1d4 + cha modifier damage per level."} 

    with_stdin do |user|
      user.puts "magic missle"
      @mock.expect :call, true, [spell]
      @combat_session.stub(:player_cast_spell, @mock) do
        capture_stdout { @combat_session.player_get_spell }
      end
    end
    assert(@mock.verify)
  end

  def test_spell_pre_checks
    spell = {name: "some healing spell", type: "healing", attribute: "hp"}
    @combat_session.player_character.hp = 10
    @combat_session.player_character.max_hp = 10
    assert(!@combat_session.player_spell_pre_checks(spell),
      "If the player is attempting to cast a healing spell but the attribute they're affecting is already full, the function should return false.")
  end

  def test_player_account_for_cost
    spell = {name: "spell with too high a mana cost", casting_cost: 20, cost_pool: "mana"}
    @combat_session.player_character.mana = 100

    assert(@combat_session.player_account_for_cost(spell),
      "When the mana cost is less than or equal to the character's mana, the function should return true.")

    @combat_session.player_character.mana = 0

    assert(!@combat_session.player_account_for_cost(spell),
      "When the mana cost is greater than the character's mana, the function should return false.")
  end

  def test_player_cast_spell
    spell = {name: "magic missle", level: 1, type: "damage", dice: 4, number_of_dice: 1, damage_bonus: "magic", 
           number_of_dice_bonus: "level", bonus_missles: "proficiency", casting_cost: 15, cost_pool: "mana", price: 150,
           description: "Missles shoot from your fingers toward your opponent. \nDeals 1d4 + cha modifier damage per level."} 

    @combat_session.player_character.spell_failure_chance = 0
    @mock.expect :call, nil, [spell, spell[:type]]
    @combat_session.stub(:player_coordinate_cast, @mock) do
      @combat_session.player_cast_spell(spell)
    end
    assert(@mock.verify)

    @combat_session.player_character.spell_failure_chance = 100
    @combat_session.enemy.mag_resist = -20
    current_hp = @combat_session.enemy.hp
    @combat_session.player_cast_spell(spell)
    assert_equal(current_hp, @combat_session.enemy.hp,
      "When the player's spell failure chance is 100%, the enemy should never get hit by the spell.")
  end

  def test_player_coordinate_cast
    spell = @combat_session.player_character.known_spells["magic missle"]
    @mock.expect :call, nil, [spell]
    @combat_session.stub(:player_cast_damage_spell, @mock) do
      @combat_session.player_coordinate_cast(spell, spell[:type])
    end

    spell = @combat_session.player_character.known_spells["cure light wounds"]
    @mock.expect :call, nil, [spell]
    @combat_session.stub(:player_cast_healing_spell, @mock) do
      @combat_session.player_coordinate_cast(spell, spell[:type])
    end
  end

  def test_player_cast_hybrid_spell
    spell = {name: "ear-piercing scream", level: 1, type: "hybrid", hybrid_types: ["damage", "curse"], dice: 6, number_of_dice: 1, damage_bonus: false, 
           number_of_dice_bonus: "proficiency", bonus_missles: false, status_effect: "sickened", time: 1, casting_cost: 50, cost_pool: "mana", price: 300,
           description: "You unleash a powerful scream. \nTarget is dazed for 1 round and takes 1d6 points of sonic damage per proficiency."}
    @mock.expect :call, nil, [spell, "damage"]
    @mock.expect :call, nil, [spell, "curse"]
    @combat_session.stub(:player_coordinate_cast, @mock) do
      @combat_session.player_cast_hybrid_spell(spell)
    end

    assert(@mock.verify)
  end

  def test_player_cast_damage_spell
    spell = {name: "magic missle", level: 1, type: "damage", dice: 4, number_of_dice: 1, damage_bonus: "magic", 
           number_of_dice_bonus: "level", bonus_missles: "proficiency", casting_cost: 15, cost_pool: "mana", price: 150,
           description: "Missles shoot from your fingers toward your opponent. \nDeals 1d4 + cha modifier damage per level."} 

    @combat_session.enemy.mag_resist = 100
    starting_hp = @combat_session.enemy.hp 
    @combat_session.player_cast_damage_spell(spell)
    assert_equal(starting_hp, @combat_session.enemy.hp,
      "When the enemy's magic resist is at 100, they should resist the magic and not be damaged.")

    @combat_session.enemy.mag_resist = -20
    @combat_session.player_cast_damage_spell(spell)
    assert_operator starting_hp, :>, @combat_session.enemy.hp, 
      "When the enemy's magic resist is -20, they should never resist a spell and should be hit."
  end

  def test_player_cast_healing_spell
    spell = {name: "cure light wounds", level: 1, type: "healing", attribute: "hp", dice: 8, number_of_dice: 1, 
           healing_bonus: "proficiency", number_of_dice_bonus: false, casting_cost: 20, cost_pool: "mana", price: 200,
           description: "You use your magic to mend some of your cuts and bruises. \nHeals 1d8 + magic proficiency point per level."}
    @combat_session.player_character.hp = 5
    @combat_session.player_character.max_hp = 30
    @combat_session.player_cast_healing_spell(spell)
    assert_operator @combat_session.player_character.hp, :>, 5,
      "When the player casts a healing spell, their health should increase."
  end

  def test_player_cast_buff_spell
    spell = {name: "beguiler's grace", level: 1, type: "buff", affected_stat: ["ac", "magic resist"], 
          bonus: "charisma", time: "level", casting_cost: 20, cost_pool: "mana", price: 200,
          description: "You radiate such grace that your enemies struggle to hit you.\n+cha modifier to ac for a number of rounds equal to your level."}
    cha_bonus = 5
    @combat_session.player_character.ac = 10
    @combat_session.player_cast_buff_spell(spell, cha_bonus)
    assert_equal(15, @combat_session.player_character.ac, 
      "When Beguiler's Grace is cast, it should update the player's AC by their charisma modifier.")
  end

  def test_player_reverse_buff_spells_loop
    @combat_session.player_character.ac = 15
    @combat_session.player_character.mag_resist = 20
    @combat_session.player_character.hp = 25

    @combat_session.player_character.cha_modifier = 5
    @combat_session.player_character.mag_modifier = 3

    spells_to_reverse = [ {name: "spell1", type: "buff", affected_stat: ["ac", "magic resist"], bonus: "charisma"}, 
      {name: "spell2", type: "buff", affected_stat: ["hp"], bonus: "magic"}]

    @combat_session.player_reverse_buff_spells_loop(spells_to_reverse)
    assert_equal(10, @combat_session.player_character.ac,
      "The player's ac should be reverted.")
    assert_equal(15, @combat_session.player_character.mag_resist,
      "The player's magic resist should be reverted.")
    assert_equal(22, @combat_session.player_character.hp,
      "The player's hp should be reverted.")
  end

  def test_player_reverse_buff_spell
    spell = {name: "beguiler's grace", level: 1, type: "buff", affected_stat: ["ac", "magic resist"], 
          bonus: "cha", time: "level", casting_cost: 20, cost_pool: "mana", price: 200,
          description: "You radiate such grace that your enemies struggle to hit you.\n+cha modifier to ac for a number of rounds equal to your level."}
    bonus = 5
    @combat_session.player_character.ac = 15
    @combat_session.player_character.mag_resist = 20

    @combat_session.player_reverse_buff_spell(spell, bonus)
    assert_equal(10, @combat_session.player_character.ac)
    assert_equal(15, @combat_session.player_character.mag_resist)
  end

end