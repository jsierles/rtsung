class RTsung
  class Request
    class Http
      HTTP_VERSION = '1.1'
      HTTP_METHOD  = :GET

      def initialize(url, options)
        @url            = url
        @version        = options[:version] || HTTP_VERSION
        @method         = options[:method] || HTTP_METHOD
        @authentication = options[:authentication]
        @content_type   = options[:content_type]

        if options[:params]
          params = options[:params].to_param.gsub(/%25%25(.*?)%25%25/) { |match| CGI.unescape(match) }

          @url << "?#{params}"
        end
      end

      def to_xml(xml)
        params = {:url => @url, :version => @version, :method => @method}
        params[:content_type] = @content_type if @content_type
        params[:contents] = @contents if @contents
        xml.http(params) do
          xml.www_authenticate(:userid => @authentication[:user_name], :passwd => @authentication[:password]) if @authentication
        end
      end
    end

    class Variable
      def initialize(name, value)
        @name, @value = name, value
        Object.const_set(name.to_s.upcase, "%%_#{name}%%")
      end

      def to_xml(xml)
        attrs = if @value.is_a?(Regexp)
          {:regexp => @value.source}
        end
        xml.dyn_variable attrs.merge(:name => @name)
      end
    end

    def initialize(&block)
      @steps = []
      instance_eval(&block) if block_given?
    end

    def get(url, options = {})
      http_request(url, options.merge(:method => :GET))
    end

    def post(url, options = {})
      http_request(url, options.merge(:method => :POST))
    end

    def http_request(url, options = {})
      @steps << Http.new(url, options)
    end

    def variable(variables)
      variables.each do |name, value|
        @steps << Variable.new(name, value)
      end
    end

    def to_xml(xml)
      xml.request :subst => true do
        @steps.each { |s| s.to_xml(xml) }
      end
    end
  end
end
