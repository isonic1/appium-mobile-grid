module Helpers
  class << self
    #puts iOS specific helper methods here...
  end
end

module Kernel
  def helper
    Helpers
  end
end