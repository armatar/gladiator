class Skills
  def initialize
  end

  def create_list_of_skills
    @skills = {
      "improved trip" => {name: "improved trip"}, 
      "improved dirty trip" => {name: "improved dirty trip"},
      "improved disarm" => {name: "improved disarm"}, 
      "improved grapple" => {name: "improved grapple"}, 
      "power attack" => {name: "power attack", required_item: "none", description: "Focus on a single attack. \n+2 to hit, +2 to damage, -2 to ac"},
      "taunt" => {name: "taunt", require_item: "none", description: "Taunt your enemy. \n+2 bonus to enemy hit, but he can only auto attack for 3 rounds."},
      "defensive stance" => {name: "defensive stance", required_item: "shield" desription: "Take a defensive stance. \n+2 to ac -2 to attack."}
      
    }
  end
end