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
