class CombatManeuvers

  def self.create_list_of_maneuvers
    maneuvers = {
      "trip" => {name: "trip", status: "tripped", fervor: 10, description: "Attempt to knock your opponent over."},
      "disarm" => {name: "disarm", fervor: 10, description: "Attempt to disarm your opponent."},
      "grapple" => {name: "grapple", status: "grappled", fervor: 10, description: "Attempt to grab your opponent. If successful, you can attempt to pin them down."},
      "pin" => {name: "pin", status: "pinned", fervor: 10, description: "Attempt to pin your opponent down. If successful, you may perform coup de grace."},
      "release" => {name: "release", fervor: -10, description: "Release your opponent from your grapple."}
    }
    return maneuvers
  end

  def self.maneuvers
    @@maneuvers = create_list_of_maneuvers
  end
end
