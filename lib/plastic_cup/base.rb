module PlasticCup

  class Base

    OSVersions = %w(all ios4 ios5 ios6 ios7 ios8 ios9 ios10)

    def self.style(target, style, other_style=nil)
      if style.is_a?(Hash)
        apply_properties(target, style)
      else
        extends = style.is_a?(Array) ? style : [style]
        final_style = {}
        extends.each do |ext|
          final_style.merge!(get_style_sheet_properties(ext))
        end
        final_style.merge!(other_style) if other_style.is_a?(Hash)
        apply_properties(target, final_style)
      end
      target
    end

    def self.add_style_sheet(name, properties, os_version=:all)
      if OSVersions.include?(os_version.to_s)
        styles[to_key(name)] ||= {}
        styles[to_key(name)][os_version.to_sym] = Stylesheet.new(properties)
      else
        raise ArgumentError.new "OS version only accept #{OSVersions}"
      end
    end

    def self.get_style_sheet(style)
      version_string = UIDevice.currentDevice.systemVersion.split('.').first
      if styles[to_key(style)].is_a?(Hash)
        style_hash = styles[to_key(style)]["ios#{version_string}".to_sym]
        style_hash ||= styles[to_key(style)][:all]
      end
      NSLog "WARNING: Style #{style} undefined." if style_hash.nil?
      style_hash
    end

    def self.get_style_sheet_properties(style)
      style_sheet = get_style_sheet(style)
      if style_sheet.nil?
        {}
      else
        extends = style_sheet.extends
        if extends.empty?
          style_sheet.properties
        else
          final_style = {}
          extends.each do |ext|
            final_style.merge!(get_style_sheet_properties(ext))
          end
          final_style.merge(style_sheet.properties)
        end
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