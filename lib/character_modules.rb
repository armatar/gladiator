require "require_all"
require_rel "character_modules"

module CharacterModules
  include AutoAttack
  include CharacterCalculations
  include CharacterCombat
  include CastSpell
  include CastDamageSpell
  include DefendSpell
  include CastHealingSpell
end