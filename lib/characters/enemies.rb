require_relative "../character.rb"

class Enemies < Character

  attr_reader :gold_worth, :item_drop, :fame_worth, :exp_worth
  
  def initialize(name, race)
    super(name, race)
  end

end
