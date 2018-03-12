# function that performs stupid simple santizations
module Sanitize
  def self.sanitize(words)
    words = words.gsub('`', '\\\`')
    words = words.gsub('@here', '`@here`')
    words = words.gsub('@everyone', '`@everyone`')

    words
  end
end
