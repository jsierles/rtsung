$: << '../lib'

require 'rtsung'

rtsung = RTsung.new do
  server 'google.com'

  session :search do
    request '/' do
      variable :a => //
    end
    think_time 1..2, :random => true

    get '/avbbb', :a => A, :b => :c
  end
end

print rtsung.to_xml
