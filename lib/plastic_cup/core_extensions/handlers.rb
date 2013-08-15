# teacup/lib/teacup-ios/core_extensions/teacup_handlers.rb
##|
##|  UIButton
##|
PlasticCup::Base.handler UIButton, :title do |target, title|
  if title.is_a?(NSAttributedString)
    target.setAttributedTitle(title, forState: UIControlStateNormal)
  else
    target.setTitle(title.to_s, forState: UIControlStateNormal)
  end
end

PlasticCup::Base.handler UIButton, :image do |target, image|
  target.setImage(image, forState: UIControlStateNormal)
end

PlasticCup::Base.handler UIButton, :backgroundImage do |target, background_image|
  target.setBackgroundImage(background_image, forState: UIControlStateNormal)
end

PlasticCup::Base.handler UIButton, :titleColor do |target, color|
  target.setTitleColor(color, forState: UIControlStateNormal)
end

PlasticCup::Base.handler UIButton, :titleFont, :font do |target, font|
  target.titleLabel.font = font
end
