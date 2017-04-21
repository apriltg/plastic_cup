module PlasticCup

  class Base

    OS_VERSIONS = %w(any ios4 ios5 ios6 ios7 ios8 ios9 ios10)
    DISPLAY_INCHES = %w(any 3.5 4 4.7 5.5)

    def self.style(target, style, other_style=nil, screen=nil)
      if style.is_a?(Hash)
        apply_properties(target, style)
      else
        extends = style.is_a?(Array) ? style : [style]
        final_style = {}
        extends.each do |ext|
          final_style.merge!(get_style_sheet_properties(ext, screen))
        end
        final_style.merge!(other_style) if other_style.is_a?(Hash)
        apply_properties(target, final_style)
      end
      target
    end

    # device_options={inch: '4.7', os: 'ios10'}
    def self.add_style_sheet(name, properties, device_options={})
      device_options ||= {}
      if device_options == :all # backward compatible
        os = :any
        inch = :any
      elsif !device_options.is_a?(Hash)
        os = device_options
        inch = :any
      else
        os = device_options[:os]
        os = :any if os.nil?
        inch = device_options[:inch] || :any
      end
      unless OS_VERSIONS.include?(os.to_s)
        raise ArgumentError.new "os only accept #{OS_VERSIONS}"
      end
      unless DISPLAY_INCHES.include?(inch.to_s)
        raise ArgumentError.new "inch only accept #{DISPLAY_INCHES}"
      end

      styles[to_key(name)] ||= {}
      styles[to_key(name)][version_key(inch, os)] = Stylesheet.new(properties)
    end

    def self.get_style_sheet(style, screen=nil)
      style_key = to_key(style)
      if styles[style_key].is_a?(Hash)
        style_hash = nil
        get_version_keys(screen).each do |key|
          style_hash = styles[style_key][key]
          break if style_hash
          # TODO: support merge style sheets with different versions
          # hash = styles[style_key][key]
          # if hash
          #   style_hash = hash.merge(style_hash||{})
          # end
        end
      end
      NSLog "WARNING: Style #{style} undefined." if style_hash.nil?
      style_hash
    end

    def self.get_style_sheet_properties(style, screen=nil)
      style_sheet = get_style_sheet(style, screen)
      if style_sheet.nil?
        {}
      else
        extends = style_sheet.extends
        if extends.empty?
          style_sheet.properties
        else
          final_style = {}
          extends.each do |ext|
            final_style.merge!(get_style_sheet_properties(ext, screen))
          end
          final_style.merge(style_sheet.properties)
        end
      end
    end

    def self.get_property(style, name, screen=nil)
      get_style_sheet_properties(style, screen)[name]
    end

    def self.get_style_sheet_ignored_properties(style, screen=nil)
      hash = get_style_sheet_properties(style, screen)
      hash = hash.select{|k,v| k[0] == ignore_symbol}
      hash.each_with_object({}) do |pair, h|
        k = pair[0][1..-1].to_sym
        h[k] = pair[1]
      end

    end

    # teacup/lib/teacup/handler.rb
    def self.handler(klass, *style_names, &block)
      if style_names.length == 0
        raise TypeError.new "No style names assigned"
      else
        style_names.each do |style_name|
          handlers[klass.name][to_key(style_name)] = block
        end
      end
      self
    end

    def self.to_key(key)
      begin
        key = key.to_sym
      rescue NoMethodError
        raise TypeError.new "#{key.inspect} is not a symbol"
      end
    end

    def self.get_inch(screen=nil)
      height = get_screen_height(screen)
      case height
        when 480
          '3.5'
        when 568
          '4'
        when 667
          '4.7'
        when 736
          '5.5'
          # TODO: handle landscape, ipad, and split screen
        # when 1024
        #   '9.7'
        # when 1336
        #   '12.9'
        else
          'any'
      end
    end

    def self.get_os(version=UIDevice.currentDevice.systemVersion)
      "ios#{version.split('.').first}"
    end

    def self.get_version_keys(screen=nil)
      inch_array = [get_inch(screen), 'any']
      os_array = [get_os, 'any']
      inch_array.map{|inch| os_array.map{|os| version_key(inch, os)}}.flatten
    end

    def self.version_key(inch, os)
      "#{inch}|#{os}".to_sym
    end

    def self.get_screen_height(screen=nil)
      screen ||= UIScreen.mainScreen
      screen.bounds.size.height
    end

    def self.get_screen_width(screen=nil)
      screen ||= UIScreen.mainScreen
      screen.bounds.size.width
    end

    def self.ignore_symbol
      '_'
    end

    def self.styles
      @styles||={}
    end

    # teacup/lib/teacup/handler.rb
    def self.handlers
      @handlers ||= Hash.new{ |hash,klass| hash[klass] = {} }
    end

    protected

    # teacup/lib/teacup/handler.rb
    def self.apply_properties(target, properties)
      klass = target.class
      properties.each do |key, proxy_value|
        next if key[0] == ignore_symbol # ignore keys start with that character
        value = if proxy_value.is_a?(Proc)
                  proxy_value.call
                else
                  proxy_value
                end
        handled = false
        klass.ancestors.each do |ancestor|
          ancestor_name=ancestor.name
          key = to_key(key)
          if handlers[ancestor_name].has_key? key
            handlers[ancestor_name][key].call(target, value)
            handled = true
            break
          end
        end
        unless handled
          # you can send methods to subviews (e.g. UIButton#titleLabel) and CALayers
          # (e.g. UIView#layer) by assigning a hash to a style name.
          if value.is_a?(Hash)
            if target.respondsToSelector(key) || target.respond_to?(key)
              apply_properties(target.send(key), value)
            else
              NSLog "WARNING: undefined method '#{key}' for #{target.inspect}"
            end
          else
            if key =~ /^set[A-Z]/
              assign = nil
              setter = key.to_s + ':'
            else
              assign = key.to_s + '='
              setter = 'set' + key.to_s.sub(/^./) {|c| c.capitalize} + ':'
            end

            apply_method(target, assign, setter, value)
          end
        end

      end
    end

    # teacup/lib/teacup-ios/handler.rb
    def self.apply_method(target, assign, setter, value)
      if target.respondsToSelector(setter)
        #NSLog "Calling target.#{setter}(#{value.inspect})"
        target.send(setter, value)
      elsif assign and target.respond_to?(assign)
        #NSLog "Setting #{assign} #{value.inspect}"
        target.send(assign, value)
      else
        NSLog "WARNING: Can't apply #{setter.inspect}#{assign and " or " + assign.inspect or ""} to #{target.inspect}"
      end
    end


    # for testing
    if RUBYMOTION_ENV == 'test'
      def self.clear_style_sheets
        @styles = nil
      end

      def self.clear_handlers
        @handlers = nil
      end
    end

  end

end