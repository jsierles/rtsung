class RTsung
  class ThinkTime
    attr :attrs

    def initialize(value, options = {})
      if value.is_a?(Range)
        @attrs = {
            :min => value.min,
            :max => value.max
        }
      else
        @attrs = {:value => value}
      end

      @attrs[:random] = options[:random].nil? ? true : options[:random]
    end

    def to_xml(xml)
      xml.thinktime @attrs
    end
  end
end
