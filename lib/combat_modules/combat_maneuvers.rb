require_relative "../user_interface.rb"

module CombatManeuvers
  include UserInterface

  attr_reader :maneuvers

  def create_list_of_maneuvers
    @maneuvers = {
      "trip" => {name: "trip", status: "tripped", fervor: 10, description: "Attempt to knock your opponent over."},
      "disarm" => {name: "disarm", fervor: 10, description: "Attempt to disarm your opponent."},
      "grapple" => {name: "grapple", status: "grappled", fervor: 10, description: "Attempt to grab your opponent. If successful, you can attempt to pin them down."},
      "pin" => {name: "pin", status: "pinned", fervor: 10, description: "Attempt to pin your opponent down. If successful, you may perform coup de grace."},
      "release" => {name: "release", fervor: -10, description: "Release your opponent from your grapple."}
    }
  end

  def implement_cbm(target, cbm)
    if cbm[:name] == "disarm"
      if target == "ally"
        @ally.equipped_weapon = @ally.default_weapon
        @message += "#{@ally.name} has been disarmed!\n\n"
      elsif target == "enemy"
        @enemy_previous_weapon = @enemy.equipped_weapon
        @enemy.equipped_weapon = @enemy.default_weapon
        @message += "#{@enemy.name} has been disarmed!\n\n"
      end
    else
      effect = cbm[:status]
      effect = @status_effects[effect]
      implement_status_effect(target, effect)
      if target == "ally"
        @message += "#{@ally.name} has been #{cbm[:status]}\n\n"
      elsif target == "enemy"
        @message += "#{@enemy.name} has been #{cbm[:status]}\n\n"
      end
    end
  end

  def reverse_cbm(target, cbm)
    effect = cbm[:status]
    effect = @status_effects[effect]
    reverse_status_effect(target, effect)
    if target == "ally"
      @message += "#{@ally.name} has recovered from being #{cbm[:status]}\n\n"
    elsif target == "enemy"
      @message += "#{@enemy.name} has recovered from being #{cbm[:status]}\n\n"
    end
  end

  def cbm_attack_attempt(target, attacker)
    dice_roll = rand(1..20)
    @message += "CMB roll: #{dice_roll} + #{attacker.cbm} = #{dice_roll + attacker.cbm}, Target: #{target.cbm_def}\n"
    attack = dice_roll + attacker.cbm
    if attack >= target.cbm_def
      @message += "CBM attempt successful!\n"
      return true
    else
      @message += "CBM attempt fails. \n\n"
      return false
    end
  end

end

=begin
cbm = CombatManeuvers.new
cbm.create_list_of_maneuvers
cbm.show_CBM
=end