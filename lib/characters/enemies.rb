require_relative "../character.rb"

class Enemies < Character

  attr_reader :gold_worth, :item_drop, :fame_worth, :exp_worth, :is_alive
  
  def initialize(name=get_random_name, race=get_random_race)
    super(name, race)

    @is_alive = true
  end

  def get_random_name
    names = ["Eadbrand", "Anpher", "Sararich", "Anealjohn", "Ansam", "Rahbeo", "Nesha", "Achris", 
             "Geor", "Phiesu", "Soncar", "Lalen", "Serehelm", "Zanan", "Cenfred", "Clachar", "Vidguth"]

    return names.sample
  end

  def get_random_race
    races = ["drai", "relic", "aloiln", "tiersmen"]
    return races.sample
  end

  def kill
    @is_alive = false
  end

end
