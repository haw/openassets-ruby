# Transaction output type enum
module OpenAssets
  module Protocol
    module OutputType
      UNCOLORED = 0
      MARKER_OUTPUT = 1
      ISSUANCE = 2
      TRANSFER = 3

      # get all enum.
      def self.all
        self.constants.map{|name|self.const_get(name)}
      end

      def self.output_type_label(type)
        case type
          when UNCOLORED then 'uncolored'
          when MARKER_OUTPUT then 'marker'
          when ISSUANCE then 'issuance'
          when TRANSFER then 'transfer'
          else 'uncolored'
        end
      end

    end
  end
end
