require_relative '../../../helpers/trie'

module Performance
  module SubTasks
    module Lookups
      class Lookup
        include Helpers::Trie

        def initialize iterations = 200_000
          @iterations = iterations
        end

        private

        attr_reader :iterations
      end
    end
  end
end
