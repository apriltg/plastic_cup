module PlasticCup

  class Stylesheet

    attr_accessor :properties, :extends

    def initialize(options={})
      @extends = options.delete(:extends) || []
      @extends = [@extends] if !@extends.is_a?(Array)
      @extends.map!{|ext| Base.to_key(ext)}
      #@extends.each do |ext|
      #  @extends.delete(ext) unless Base.is_key?(ext)
      #end
      @properties=options
    end

  end

end
