require "byebug"
require_relative 'user_interface.rb'

class Items
  include UserInterface

  attr_reader :item_list, :default_weapon

  def initialize
    create_list_of_items
  end

  def create_list_of_items
    @default_weapon = {"fists" => { name: "fists", type: "unarmed weapon", dice: 4, number_of_dice: 1, crit: 20, crit_damage: 3, enchantment: 0 }}
    @item_list = {
      "bronze sword" => { name: "bronze sword", type: "1-hand weapon", dice: 6, number_of_dice: 1, enchantment: 0, crit: 19, crit_damage: 2, price: 10 },
      "bronze greatsword" => { name: "bronze greatsword", type: "2-hand weapon", dice: 8, number_of_dice: 1, enchantment: 0, crit: 20, crit_damage: 3, price: 10 },
      "bronze knuckles" => { name: "bronze knuckles", type: "unarmed weapon", dice: 4, number_of_dice: 1, enchantment: 0, crit: 20, crit_damage: 3, price: 10 },
      "bronze dual swords" => { name: "bronze dual swords", type: "dual wield weapon", dice: 6, number_of_dice: 1, enchantment: 0, crit: 18, crit_damage: 2, price: 10 },
      "wooden staff" => { name: "wooden staff", type: "staff", dice: 4, number_of_dice: 1, enchantment: 0, crit: 20, crit_damage: 2, price: 10 },
      "bronze shield" => { name: "bronze shield", type: "shield", defense_bonus: 1, enchantment: 0, price: 10 },
      "health potion" => { name: "health potion", type: "healing", stat: "hp", bonus: 20, price: 10}
    }
  end

end

=begin
items = Items.new
items.display_list_of_items(items.item_list)
=end