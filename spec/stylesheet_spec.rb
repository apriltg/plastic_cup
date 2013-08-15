describe 'PlasticCup::Stylesheet' do

  it 'should have suitable accessors' do
    style_sheet = PlasticCup::Stylesheet.new
    style_sheet.extends.should == []
    style_sheet.properties.should == {}
  end

  it 'should convert single extend to an array' do
    style_sheet = PlasticCup::Stylesheet.new({extends: :parent_style})
    style_sheet.extends.should == [:parent_style]
  end

  it 'should accept multiple extend styles name' do
    style_sheet = PlasticCup::Stylesheet.new({extends: [:father_style, :mother_style]})
    style_sheet.extends.should == [:father_style, :mother_style]
  end

  it 'should not accept extend style name which is not a symbol' do
    lambda {
      PlasticCup::Stylesheet.new({extends: [:father_style, 123, :mother_style, 456]})
    }.
        should.raise(TypeError).
        message.should.match(/123 is not a symbol/)
  end

  it 'should convert extend style name from String to Symbol' do
    style_sheet = PlasticCup::Stylesheet.new({extends: [:father_style, 'mother_style']})
    style_sheet.extends.should == [:father_style, :mother_style]
  end

  it 'should initialize properties' do
    style_sheet = PlasticCup::Stylesheet.new({style_a: 1, style_b: 2})
    style_sheet.properties.should == {style_a: 1, style_b: 2}
  end

  it 'should remove extends from properties' do
    style_sheet = PlasticCup::Stylesheet.new({extends: :parent_style, color: UIColor.blueColor, text: 'Title'})
    style_sheet.properties.should == {color: UIColor.blueColor, text: 'Title'}
  end
end