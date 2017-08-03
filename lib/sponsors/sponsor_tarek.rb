require_relative "../sponsor.rb"

class SponsorTarek < Sponsor
  def initialize
    super("Tarek")
    set_introduction
  end

  def set_introduction
    @introduction = "will complete soon..."
  end
end