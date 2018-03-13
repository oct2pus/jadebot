# function that performs stupid simple santizations
module Sanitize
  def self.sanitize(words)
    words = words.gsub('@here', '@​here') # invisible character between @ and h
    words = words.gsub('@everyone', '@​everyone') # also between @ and e

    words
  end
end
