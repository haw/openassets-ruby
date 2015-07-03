# Transaction output type enum
module OutputType
  UNCOLORED = 0
  MARKER_OUTPUT = 1
  ISSUANCE = 2
  TRANSFER = 3

  # get all enum.
  def self.all
    self.constants.map{|name|self.const_get(name)}
  end

end