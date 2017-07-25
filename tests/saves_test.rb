require 'minitest/autorun'
require_relative "../lib/saves.rb"

class SavesTest < Minitest::Test

  def setup
    @saves = Saves.new
    @save_name = "test-save"
    @save_content = "test"
  end

  def test_saves
    @saves.save(@save_name, @save_content)
    assert(File.exist?(@saves.get_full_file_path(@save_name)), "#{@save_name} does not exist.")

    result = @saves.load_save(@save_name)
    assert_equal(@save_content, result, "#{result} is not equal to #{@save_content}.")

    @saves.delete_save(@save_name)
    assert(!File.exist?(@saves.get_full_file_path(@save_name)), "#{@save_name} still exists.")
  end

  def test_update_saves
    @saves.update_saves(@save_name, false)
    assert(@saves.saves.include?(@save_name), "#{@saves.saves} does not include #{@save_name}")

    yaml_saves = @saves.load_save("saves")
    assert(yaml_saves.include?(@save_name), "#{yaml_saves} does not include #{@save_name}")

    @saves.remove_from_saves_list(@save_name)
    assert(!@saves.saves.include?(@save_name), "#{@saves.saves} still includes #{@save_name}")
  end
end