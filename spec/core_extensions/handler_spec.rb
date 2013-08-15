describe 'Handler Extensions' do
  describe 'UIButton' do

    it 'should handle :title for string' do
      button = PlasticCup::Base.style(UIButton.new, {title: 'button title'})
      button.titleForState(UIControlStateNormal).should == 'button title'
    end

    it 'should handle :title for attributed string' do
      string = NSMutableAttributedString.alloc.initWithString('redblue')
      string.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor, range: NSMakeRange(0,3))
      string.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor, range: NSMakeRange(3,4))
      button = PlasticCup::Base.style(UIButton.new, {title: string})

      button.attributedTitleForState(UIControlStateNormal).should == string
    end

    it 'should handle :image' do
      image = UIImage.imageNamed('Default-568h@2x.png')
      button = PlasticCup::Base.style(UIButton.new, {image: image})
      button.imageForState(UIControlStateNormal).should == image
    end

    it 'should handle :backgroundImage' do
      image = UIImage.imageNamed('Default-568h@2x.png')
      button = PlasticCup::Base.style(UIButton.new, {backgroundImage: image})
      button.backgroundImageForState(UIControlStateNormal).should == image
    end

    it 'should handle :titleColor' do
      button = PlasticCup::Base.style(UIButton.new, {titleColor: UIColor.greenColor})
      button.titleColorForState(UIControlStateNormal).should == UIColor.greenColor
    end

    it 'should handle :titleFont' do
      button = PlasticCup::Base.style(UIButton.new, {titleFont: UIFont.systemFontOfSize(88)})
      button.titleLabel.font.should == UIFont.systemFontOfSize(88)
    end

    it 'should handle :font' do
      button = PlasticCup::Base.style(UIButton.new, {font: UIFont.systemFontOfSize(88)})
      button.titleLabel.font.should == UIFont.systemFontOfSize(88)
    end
  end
end