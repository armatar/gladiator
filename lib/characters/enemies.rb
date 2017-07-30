require_relative "../character.rb"

class Enemies < Character

  attr_reader :gold_worth, :item_drop, :fame_worth, :exp_worth, :is_alive
  
  def initialize(name, race)
    super(name, race)

    @is_alive = true
  end

  def kill
    @is_alive = false
  end

end
