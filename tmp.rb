BEGIN {
 
  require 'net/http'
  
  Net::HTTP.module_eval do
    alias_method '__initialize__', 'initialize'
    
    def initialize(*args,&block)
      __initialize__(*args, &block)
    ensure
      binding.pry
      @debug_output = $stderr if ENV['HTTP_DEBUG']
    end
  end
 
}
