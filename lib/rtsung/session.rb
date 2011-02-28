require 'active_support/core_ext/object/to_query'

class RTsung
  class Session
    PROBABILITY = 100
    TYPE = :ts_http

    THINK_TIME_RANDOM = true


    def initialize(name, options = {}, &block)
      @attrs = {
          :name => name,
          :probability => options[:probability] || PROBABILITY,
          :type => options[:type] || TYPE
      }

      @steps = []

      instance_eval(&block) if block_given?
    end

    def request(*args, &block)
      @steps << Request.new(&block).tap { |request| request.http_request(*args) unless args.empty? }
    end

    def think_time(value, options = {})
      @steps << ThinkTime.new(value, options)
    end

    def get(url = '/', params = {}, &block)
      make_request url, :GET, params, &block
    end

    def post(url, params = {}, &block)
      make_request url, :POST, params, &block
    end

    def put(url, params = {}, &block)
      make_request url, :POST, params.merge(:_method => 'put'), &block
    end

    def post_and_follow(url, params = {}, &block)
      post url, params do
        variable :redirect => %r{Location: \(http://.*\)\r}
      end
      request "%%_redirect%%&uid=#{MOBILE_ID}", &block
    end

    def get_and_follow(url, params = {}, &block)
      get url, params do
        variable :redirect => %r{Location: \(http://.*\)\r}
      end
      request "%%_redirect%%&pkid=#{USER_ID}", &block
    end

    def make_request(url, method, params = {}, &block)
      request url, :method => method, :params => params.merge(additional_params), &block
    end

    def additional_params
      {}
    end

    alias :think :think_time

    def authenticate(user_name, password)
      attrs = {:userid => user_name, :passwd => password}
      @steps << {
          :type => :authenticate,
          :attrs => attrs
      }
    end

    def to_xml xml
      if @steps.empty?
        xml.session @attrs
      else
        xml.session(@attrs) do
          @steps.each { |s| s.to_xml xml }
        end
      end
    end

  end
end
