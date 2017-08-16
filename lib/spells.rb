class Spells
  attr_reader :spells, :damage_spells, :healing_spells, :buff_spells, :curse_spells, :hybrid_spells

  def initialize
  end

  def create_spell_list
    create_damage_spells
    create_healing_spells
    create_buff_spells
    create_curse_spells
    create_hybrid_spells
    create_master_spell_list
  end

  def create_master_spell_list
    @spells = {}
    @spells.merge!(@damage_spells)
    @spells.merge!(@healing_spells)
    @spells.merge!(@buff_spells)
    @spells.merge!(@curse_spells)
    @spells.merge!(@hybrid_spells)
  end

  def create_damage_spells
    @damage_spells = {
        "burning hands" => {name: "burning hands", level: 1, type: "damage", dice: 4, number_of_dice: 1, damage_bonus: false, 
           number_of_dice_bonus: "proficiency", bonus_missles: false, casting_cost: 10, cost_pool: "mana", price: 100,
           description: "You touch your opponent with hands of flame. \nDeals 1d6 damage per magic proficiency point."},
      "magic missle" => {name: "magic missle", level: 1, type: "damage", dice: 4, number_of_dice: 1, damage_bonus: "magic", 
           number_of_dice_bonus: "level", bonus_missles: "proficiency", casting_cost: 15, cost_pool: "mana", price: 150,
           description: "Missles shoot from your fingers toward your opponent. \nDeals 1d4 + cha modifier damage per level."} 
    }
  end

  def create_healing_spells
    @healing_spells = {
      "cure light wounds" => {name: "cure light wounds", level: 1, type: "healing", attribute: "hp", dice: 8, number_of_dice: 1, 
           healing_bonus: "proficiency", number_of_dice_bonus: false, casting_cost: 20, cost_pool: "mana", price: 200,
           description: "You use your magic to mend some of your cuts and bruises. \nHeals 1d8 + magic proficiency point per level."}
    }
  end

  def create_buff_spells
    @buff_spells = {
      "beguiler's grace" => {name: "beguiler's grace", level: 1, type: "buff", affected_stat: ["ac", "magic resist"], 
          bonus: "charisma", time: "level", casting_cost: 20, cost_pool: "mana", price: 200,
          description: "You radiate such grace that your enemies struggle to hit you.\n+cha modifier to ac for a number of rounds equal to your level."},
      "shock weapon" => {name: "shock weapon", level: 1, type: "buff", affected_stat: ["attack", "damage"], 
          bonus: "magic", time: "proficiency", casting_cost: 10, cost_pool: "mana", price: 100,
          description: "Your weapon begins to crackle with electric energy.\n+mag modifier to attack and damage for a number of rounds equal to your magic proficiency"}
    }
  end

  def create_curse_spells
    @curse_spells = {
      "ray of sickening" => {name: "ray of sickening", level: 1, type: "curse", status_effect: "sickened", time: "level", 
           bonus: false, casting_cost: 25, cost_pool: "mana", cost: 250,
           description: "A black ray projects from your pointed finger, sickening your opponent."}
    }
  end

  def create_hybrid_spells
    @hybrid_spells = {
      "ear-piercing scream" => {name: "ear-piercing scream", level: 1, type: "hybrid", hybrid_types: ["damage", "curse"], dice: 6, number_of_dice: 1, damage_bonus: false, 
           number_of_dice_bonus: "proficiency", bonus_missles: false, status_effect: "sickened", time: 1, casting_cost: 50, cost_pool: "mana", price: 300,
           description: "You unleash a powerful scream. \nTarget is dazed for 1 round and takes 1d6 points of sonic damage per proficiency."}
    }
  end
end