# functions expected to be reused in multiple parts of the program
module Jb
  # simple sanitization method to make sure it doesn't ping people
  def self.sanitize(words)
    words = words.gsub('`', '\\\`')
    words = words.gsub('@here', '@​here') # invisible character between @ and h
    words = words.gsub('@everyone', '@​everyone') # also between @ and e

    words
  end

  # converts into to booleans, lazy conversion (nonzeros are true)
  # might possibly change to be positives to true, 0s and negatives to false
  def self.i_to_b(int)
    int != 0
  end

  # given a string, finds the closest resembling display name, then returns the
  # user object containing that display name
  def self.fuzz(event, user)
    users = event.server.members

    fuzz = FuzzyMatch.new(users.map(&:display_name))

    desired_user = fuzz.find(user)

    result = users.find { |member| member.display_name == desired_user }

    result
  end
end
