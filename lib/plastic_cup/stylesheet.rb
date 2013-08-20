module PlasticCup

  class Stylesheet

    attr_accessor :properties, :extends

    def initialize(options={})
      @extends = options.delete(:extends) || []
      @extends = [@extends] if !@extends.is_a?(Array)
      @extends.map!{|ext| Base.to_key(ext)}
      @properties=options
    end

  end

end
