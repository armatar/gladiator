require "require_all"
require_rel "combat_modules"

module CombatModules
  include StatusEffects
  include CombatManeuvers
  include SpellEffects
  include PlayerCombatOptions
  include PlayerCombatSpecificInteractions
  include GenericCombatInteractions
end