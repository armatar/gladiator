require 'minitest/autorun'
require_relative "../lib/characters/player_characters/character_for_unit_tests.rb"

class PlayerCharacterTest < Minitest::Test

  def setup
    @test_character = CharacterForUnitTests.new("Test Character", "test")
    @test_character.create_test_character
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

  def test_if_have_shield
    assert(@test_character.check_if_have_shield, "There is no shield in the inventory.")
  end

  def test_equip_weapon
    with_stdin do |user|
      user.puts "bronze dual swords"
      user.puts "yes"
      capture_stdout { @test_character.equip_weapon } 
      assert_equal(@test_character.equipped_weapon[:name], "bronze dual swords", "Equipped weapon is #{@test_character.equipped_weapon[:name]}")
    end
  end

  def test_equipping_shield
    with_stdin do |user|
      @test_character.equipped_weapon = @test_character.inventory["bronze dual swords"]
      user.puts "bronze shield"
      user.puts "back"
      capture_stdout { @test_character.equip_shield }
      assert(!@test_character.equipped_shield, "Equipped weapon is #{@test_character.equipped_shield}")
    end

    with_stdin do |user|
      @test_character.equipped_weapon = @test_character.inventory["bronze sword"]
      user.puts "bronze shield"
      user.puts "yes"
      capture_stdout { @test_character.equip_shield }
      assert_equal("bronze shield", @test_character.equipped_shield[:name], "Equipped weapon is #{@test_character.equipped_shield[:name]}")
    end
  end

  def test_set_stats
    with_stdin do |user|
      user.puts "strength"
      user.puts "add"
      user.puts "2"
      user.puts "confirm"
      user.puts "yes"
      capture_stdout { @test_character.set_stats }
      assert_equal(2, @test_character.str_modifier, "Str_modifier is #{@test_character.str_modifier}")
    end

    with_stdin do |user|
      user.puts "strength"
      user.puts "add"
      user.puts "2"
      user.puts "strength"
      user.puts "subtract"
      user.puts "2"
      user.puts "dexterity"
      user.puts "add"
      user.puts "2"
      user.puts "confirm"
      user.puts "yes"

      capture_stdout { @test_character.set_stats }
      assert_equal(2, @test_character.str_modifier, "Str_modifier is #{@test_character.str_modifier}")
      assert_equal(5, @test_character.dex_modifier, "Dex_modifier is #{@test_character.dex_modifier}")
    end
  end

  def test_set_proficiencies
    with_stdin do |user|
      user.puts "1"
      user.puts "add"
      user.puts "1"
      user.puts "confirm"
      user.puts "yes"
      capture_stdout { @test_character.set_proficiencies }
      assert_equal(3, @test_character.one_hand_prof, "One_hand_prof is #{@test_character.one_hand_prof}")
    end

    with_stdin do |user|
      user.puts "1"
      user.puts "subtract"
      user.puts "1"
      user.puts "0"
      user.puts "confirm"
      user.puts "yes"
      capture_stdout { @test_character.set_proficiencies }
      assert_equal(3, @test_character.one_hand_prof, "One_hand_prof is #{@test_character.one_hand_prof}")
    end
  end

  def test_use_item
    @test_character.hp -= 10
    with_stdin do |user|
      user.puts "health potion"
      user.puts "yes"
      capture_stdout { @test_character.use_item }
      assert_equal(@test_character.max_hp, @test_character.hp, "HP is #{@test_character.hp}")
    end
  end

  def test_add_item
    @test_character.add_item("potion", "potion description")
    assert(@test_character.inventory["potion"], "Items named potion does not exist in inventory.")
  end

  def test_update_stat
    @test_character.update_stat("magic resist", 1)
    assert_equal(6, @test_character.mag_resist, "Magic resist = #{@test_character.mag_resist}")
  end

end