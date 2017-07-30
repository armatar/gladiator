require_relative "combat_modules/status_effects.rb"
require_relative "combat_modules/combat_maneuvers.rb"
require_relative "combat_modules/spell_effects.rb"
require_relative "combat_modules/player_combat_options.rb"
require_relative "combat_modules/player_combat_specific_interactions.rb"

module CombatModules
  include StatusEffects
  include CombatManeuvers
  include SpellEffects
  include PlayerCombatOptions
  include PlayerCombatSpecificInteractions
end