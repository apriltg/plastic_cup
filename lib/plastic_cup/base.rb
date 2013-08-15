module PlasticCup

  class Base

    def self.style(target, style)
      if style.is_a?(Hash)
        apply_properties(target, style)
      else
        style_sheet = get_style_sheet(style)
        unless style_sheet.nil?
          extends = style_sheet.extends
          final_style = {}
          extends.each do |ext|
            ext_style_sheet = get_style_sheet(ext)
            final_style.merge!(ext_style_sheet.properties) unless ext_style_sheet.nil?
          end
          apply_properties(target, final_style.merge(style_sheet.properties))
        end
      end
      target
    end

    def self.add_style_sheet(name, properties)
      styles[to_key(name)] = Stylesheet.new(properties)
    end

    def self.get_style_sheet(style)
      style_hash = styles[to_key(style)]
      NSLog "WARNING: Style #{style} undefined." if style_hash.nil?
      style_hash
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
      properties.each do |key, value|
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
            apply_properties(target.send(key), value)
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