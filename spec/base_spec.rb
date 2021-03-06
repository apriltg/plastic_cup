describe 'PlasticCup::Base' do
  after do
    PlasticCup::Base.clear_style_sheets
  end

  describe '#style' do
    it 'should apply style to target by hash' do
      view = PlasticCup::Base.style(UIView.new, {backgroundColor: UIColor.redColor})
      view.backgroundColor.should == UIColor.redColor
    end

    it 'should apply style by style sheet name' do
      PlasticCup::Base.add_style_sheet(:my_style, {frame: [[10, 20], [30, 40]]})
      button = PlasticCup::Base.style(UIButton.new, :my_style)
      button.frame.should == CGRectMake(10, 20, 30, 40)
    end

    it 'should apply style sheet including extends' do
      PlasticCup::Base.add_style_sheet(:father, {backgroundColor: UIColor.redColor})
      PlasticCup::Base.add_style_sheet(:mother, {text: 'Default Text', textAlignment: 2})
      PlasticCup::Base.add_style_sheet(:my_style, {extends: [:father, :mother], numberOfLines: 3})

      label = PlasticCup::Base.style(UILabel.new, :my_style)

      label.backgroundColor.should == UIColor.redColor
      label.textAlignment.should == 2
      label.text.should == 'Default Text'
      label.numberOfLines.should == 3
    end

    it 'should override styles in parent style sheets' do
      PlasticCup::Base.add_style_sheet(:father, {textColor: UIColor.blueColor, textAlignment: 2})
      PlasticCup::Base.add_style_sheet(:mother, {text: 'Default Text',  placeholder: 'This is placeholder'})
      PlasticCup::Base.add_style_sheet(:my_style, {extends: [:father, :mother], text: 'My Text', textAlignment: 1})

      field = PlasticCup::Base.style(UITextField.new, :my_style)

      field.textColor.should == UIColor.blueColor
      field.textAlignment.should == 1
      field.text.should == 'My Text'
      field.placeholder.should == 'This is placeholder'
    end

    it 'should override former style' do
      button = PlasticCup::Base.style(UIBarButtonItem.new, {style: UIBarButtonItemStyleBordered, tintColor: UIColor.greenColor})
      PlasticCup::Base.style(button, {style: UIBarButtonItemStyleDone})

      button.style.should == UIBarButtonItemStyleDone
      button.tintColor.should == UIColor.greenColor
    end

    it 'should support multiple layer extends' do
      PlasticCup::Base.add_style_sheet(:grandma, {textAlignment: 2})
      PlasticCup::Base.add_style_sheet(:mother, {extends: :grandma, placeholder: 'This is placeholder'})
      PlasticCup::Base.add_style_sheet(:my_style, {extends: :mother, text: 'My Text'})

      field = PlasticCup::Base.style(UITextField.new, :my_style)

      field.textAlignment.should == 2
      field.text.should == 'My Text'
      field.placeholder.should == 'This is placeholder'
    end

    it 'should ignore missing extends style sheet' do
      PlasticCup::Base.add_style_sheet(:grandma, {textAlignment: 3})
      PlasticCup::Base.add_style_sheet(:mother, {extends: [:grandma, :nobody], placeholder: 'Mother placeholder'})
      PlasticCup::Base.add_style_sheet(:my_style, {extends: [:mother, :et], text: 'My Style Text'})

      field = PlasticCup::Base.style(UITextField.new, :my_style)

      field.textAlignment.should == 3
      field.text.should == 'My Style Text'
      field.placeholder.should == 'Mother placeholder'
    end

    it 'should support additional style' do
      PlasticCup::Base.add_style_sheet(:my_style, {textAlignment: 3})

      field = PlasticCup::Base.style(UITextField.new, :my_style, text: 'My Style Text')

      field.textAlignment.should == 3
      field.text.should == 'My Style Text'
    end

    it 'should support additional style overriding style sheet' do
      PlasticCup::Base.add_style_sheet(:my_style, {textAlignment: 3, placeholder: 'Mother placeholder'})

      field = PlasticCup::Base.style(UITextField.new, :my_style, text: 'My Style Text', placeholder: 'My placeholder')

      field.textAlignment.should == 3
      field.text.should == 'My Style Text'
      field.placeholder.should == 'My placeholder'
    end

    it 'should support multiple additional styles' do
      PlasticCup::Base.add_style_sheet(:father, {backgroundColor: UIColor.blueColor, numberOfLines: 18})
      PlasticCup::Base.add_style_sheet(:mother, {backgroundColor: UIColor.redColor, textColor: UIColor.greenColor})
      label = PlasticCup::Base.style(UILabel.new, [:father, :mother], text: 'My label', textColor: UIColor.grayColor)

      label.backgroundColor.should == UIColor.redColor
      label.numberOfLines.should == 18
      label.textColor.should == UIColor.grayColor
      label.text.should == 'My label'
    end
  end

  describe '#add_style_sheet and #get_style_sheet' do
    it 'should add style sheet by hash' do
      PlasticCup::Base.add_style_sheet(:my_style, {text: 'My Text', textAlignment: 1})
      style_sheet = PlasticCup::Base.get_style_sheet(:my_style)
      style_sheet.properties.should == {text: 'My Text', textAlignment: 1}
    end

    it 'add style sheet should raise error if the name is not a symbol' do
      lambda {
        PlasticCup::Base.add_style_sheet(456, {text: 'My Text', textAlignment: 1})
      }.
          should.raise(TypeError).
          message.should.match(/456 is not a symbol/)
    end

    it 'get style sheet should raise error if the name is not a symbol' do
      lambda {
        PlasticCup::Base.get_style_sheet(789)
      }.
          should.raise(TypeError).
          message.should.match(/789 is not a symbol/)
    end

    it 'should add style sheet with one extend' do
      PlasticCup::Base.add_style_sheet(:my_style, {extends: :father, text: 'My Text', textAlignment: 1})
      style_sheet = PlasticCup::Base.get_style_sheet(:my_style)
      style_sheet.properties.should == {text: 'My Text', textAlignment: 1}
      style_sheet.extends.should == [:father]
    end

    it 'should add style sheet with multiple extends' do
      PlasticCup::Base.add_style_sheet(:my_style, {extends: [:mother, :father], text: 'My Text', textAlignment: 1})
      style_sheet = PlasticCup::Base.get_style_sheet(:my_style)
      style_sheet.properties.should == {text: 'My Text', textAlignment: 1}
      style_sheet.extends.should == [:mother, :father]
    end

    describe 'os version' do
      after do
        UIDevice.currentDevice.reset(:systemVersion)
      end

      it 'should add style sheet with specific os version' do
        PlasticCup::Base.add_style_sheet(:my_style, {text: 'iOS 7 text'}, os: :ios7)
        PlasticCup::Base.add_style_sheet(:my_style, {text: 'iOS 6 text'}, os: :ios6)
        PlasticCup::Base.add_style_sheet(:my_style, {text: 'other iOS text'})

        UIDevice.currentDevice.stub!(:systemVersion, return: '6.1')
        style_sheet = PlasticCup::Base.get_style_sheet(:my_style)
        style_sheet.properties.should == {text: 'iOS 6 text'}

        UIDevice.currentDevice.stub!(:systemVersion, return: '7.0')
        style_sheet = PlasticCup::Base.get_style_sheet(:my_style)
        style_sheet.properties.should == {text: 'iOS 7 text'}

        UIDevice.currentDevice.stub!(:systemVersion, return: '5.0')
        style_sheet = PlasticCup::Base.get_style_sheet(:my_style)
        style_sheet.properties.should == {text: 'other iOS text'}

      end

      it 'add style sheet should raise error if os version not supported' do
        lambda {
          PlasticCup::Base.add_style_sheet(:my_style, {text: ''}, os: :ios1)
        }.
            should.raise(ArgumentError).
            message.should.match(/os only accept /)
      end
    end

    describe 'inch version' do

      it 'should add style sheet with specific screen inch' do
        PlasticCup::Base.add_style_sheet(:my_style, {text: 'iPhone 4 text'}, inch: '3.5')
        PlasticCup::Base.add_style_sheet(:my_style, {text: 'iPhone 6 Plus text'}, inch: '5.5')
        PlasticCup::Base.add_style_sheet(:my_style, {text: 'other screen text'})

        screen = PlasticCup::Base.style(UIView.new, frame: CGRectMake(0,0,320,480))

        style_sheet = PlasticCup::Base.get_style_sheet(:my_style, screen)
        style_sheet.properties.should == {text: 'iPhone 4 text'}

        screen = PlasticCup::Base.style(UIView.new, frame: CGRectMake(0,0,414,736))

        style_sheet = PlasticCup::Base.get_style_sheet(:my_style, screen)
        style_sheet.properties.should == {text: 'iPhone 6 Plus text'}

        screen = PlasticCup::Base.style(UIView.new, frame: CGRectMake(0,0,768,1024))

        style_sheet = PlasticCup::Base.get_style_sheet(:my_style, screen)
        style_sheet.properties.should == {text: 'other screen text'}
      end

      it 'add style sheet should raise error if screen inch not supported' do
        lambda {
          PlasticCup::Base.add_style_sheet(:my_style, {text: ''}, inch: '12.9') # ipad not supported yet
        }.
            should.raise(ArgumentError).
            message.should.match(/inch only accept /)
      end
    end

    describe 'inch version and os version' do
      after do
        UIDevice.currentDevice.reset(:systemVersion)
      end

      it 'should add style sheet with specific screen inch and os version' do

        PlasticCup::Base.add_style_sheet(:my_style, {text: 'iPhone 4 iOS 7 text'}, inch: '3.5', os: :ios7)
        PlasticCup::Base.add_style_sheet(:my_style, {text: 'iPhone 4 iOS 6 text'}, inch: '3.5', os: :ios6)
        PlasticCup::Base.add_style_sheet(:my_style, {text: 'iPhone 6 Plus text'}, inch: '5.5')
        PlasticCup::Base.add_style_sheet(:my_style, {text: 'other iOS text'})

        screen = PlasticCup::Base.style(UIView.new, frame: CGRectMake(0,0,320,480))

        UIDevice.currentDevice.stub!(:systemVersion, return: '6.1')
        style_sheet = PlasticCup::Base.get_style_sheet(:my_style, screen)
        style_sheet.properties.should == {text: 'iPhone 4 iOS 6 text'}

        UIDevice.currentDevice.stub!(:systemVersion, return: '7.0')
        style_sheet = PlasticCup::Base.get_style_sheet(:my_style, screen)
        style_sheet.properties.should == {text: 'iPhone 4 iOS 7 text'}

        screen = PlasticCup::Base.style(UIView.new, frame: CGRectMake(0,0,414,736))

        style_sheet = PlasticCup::Base.get_style_sheet(:my_style, screen)
        style_sheet.properties.should == {text: 'iPhone 6 Plus text'}

        screen = PlasticCup::Base.style(UIView.new, frame: CGRectMake(0,0,768,1024))

        UIDevice.currentDevice.stub!(:systemVersion, return: '5.0')
        style_sheet = PlasticCup::Base.get_style_sheet(:my_style, screen)
        style_sheet.properties.should == {text: 'other iOS text'}
      end
    end
  end

  describe '#handler' do
    after do
      #PlasticCup::Base.clear_handlers
    end

    it 'should add custom style' do
      PlasticCup::Base.handler UIAlertView, :add_title do |target, value|
        target.addButtonWithTitle(value)
      end
      alert = PlasticCup::Base.style(UIAlertView.new, {add_title: 'New Title'})
      alert.buttonTitleAtIndex(0).should == 'New Title'
      PlasticCup::Base.style(alert, {add_title: 'Second Title'})
      alert.buttonTitleAtIndex(1).should == 'Second Title'
    end

  end

  describe '#apply_properties' do
    it 'should apply properties in hash' do
      cell = UITableViewCell.new
      PlasticCup::Base.apply_properties(cell, {backgroundColor: UIColor.redColor, textLabel: {text: 'Cell Text', numberOfLines: 3}})
      cell.backgroundColor.should == UIColor.redColor
      cell.textLabel.text.should == 'Cell Text'
      cell.textLabel.numberOfLines.should == 3
    end

    it 'should apply Proc value' do
      label = UILabel.new
      PlasticCup::Base.apply_properties(label, {font: lambda {UIFont.systemFontOfSize(77)}, textColor: UIColor.grayColor})
      label.font.should == UIFont.systemFontOfSize(77)
      label.textColor.should == UIColor.grayColor
    end
  end

  # TODO: add tests for string to symbol conversion
end
