require_relative "ui.rb"

module Interface
  include UI::Interact
  include UI::CharacterDisplay
  include UI::ItemDisplay
  include UI::DisplayShortcuts
  include UI::StoryDisplay
  include UI::CombatDisplay
  include UI::FinalScreens
  include UI::CBMDisplay
end