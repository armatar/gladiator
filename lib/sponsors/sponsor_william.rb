require_relative "../sponsor.rb"

class SponsorWilliam < Sponsor
  def initialize
    super("William")
    set_introduction
  end

  def set_introduction
    @introduction = "The man that approaches you is well-dressed and wearing a smile \n" +
                    "that has spread all the way across his face. He moves quickly to \n" +
                    "your side, taking your hand and shaking it animatedly.\n\n"
    @introduction += '"My name is ' + @name.to_s + '.", he explains. "I watched your' + "\n" +
                     'fight in the arena just now and I was amazed that you spared that ' + "man's" + "\n" +
                     'life. I' + "'ve not met many who would prioritize another's well being over \n" + 
                     'what the crowd might prefer." He takes a breath, clearly working up to something.'+ "\n\n" +
                     '"I don' + "'t " + "know if you've had any other offers yet, but I'd \n" +
                     "like to be your sponsor. I think the arena could use someone with your \n" +
                     "morals and I'd like to help them see that." + '"' + "\n\n"
  end
end