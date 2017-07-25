module StatusEffects
  attr_reader :status_effects

  def create_status_effects_list
    @status_effects = {
      "sickened" => {name: "sickened", affected_stat: ["attack", "damage", "magic resist"], penalty: -2},
      "dazzled" => {name: "dazzled", affected_stat: ["attack"], penalty: -1},
      "blinded" => {name: "blinded", affected_stat: ["attack", "ac"], penalty: -3},
      "deafened" => {name: "deafened", affected_stat: ["spell failure"], penalty: 30},
      "entangled" => {name: "entangled", affected_stat: ["attack", "dex modifier"], penalty: -2},
      "shaken" => {name: "shaken", affected_stat: ["attack", "magic resist"], penalty: -2},
      "tripped" => {name: "tripped", affected_stat: ["ac"], penalty: -4},
      "grappled" => {name: "grappled", affected_stat: ["attack", "dex modifier"], penalty: -2},
      "pinned" => {name: "pinned", affected_stat: [], penalty: 0},
    }
  end


  def implement_status_effect(target, effect)
    if target == "ally"
      effect[:affected_stat].each do | stat |
        updated_stat = @ally.update_stat(stat, effect[:penalty])
        @message += "Ally #{stat} has been updated to #{updated_stat}.\n"
      end
    elsif target == "enemy"
      effect[:affected_stat].each do | stat |
        updated_stat = @enemy.update_stat(stat, effect[:penalty])
        @message += "Enemy #{stat} has been updated to #{updated_stat}.\n"
      end
    end
  end

  def reverse_status_effect(target, effect)
    if target == "ally"
      effect[:affected_stat].each do | stat |
        updated_stat = @ally.update_stat(stat, -effect[:penalty])
        @message += "Ally #{stat} has been restored to #{updated_stat}.\n"
      end
    elsif target == "enemy"
      effect[:affected_stat].each do | stat |
        updated_stat = @enemy.update_stat(stat, -effect[:penalty])
        @message += "Enemy #{stat} has been restored to #{updated_stat}.\n"
      end
    end
  end

end