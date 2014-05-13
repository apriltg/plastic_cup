Plastic Cup
===========

Plastic Cup is a simplified version of Teacup, aiming at memory leak prevention.
It allow assigning properties to object by hash and define stylesheets, in a dummy way.

#### Usage
Style by Hash
```ruby
@button = PlasticCup::Base.style(UIButton.new, {title: 'Red', backgroundColor: UIColor.redColor})
```

Style by Stylesheet
```ruby
PlasticCup::Base.add_style_sheet(:red_button, {
  title: 'Red',
  backgroundColor: UIColor.redColor
})
@button = PlasticCup::Base.style(UIButton.new, :red_button)
@button2 = PlasticCup::Base.style(UIButton.new, :red_button, title: 'Another Red')
```

Style with extend Stylesheet
```ruby
PlasticCup::Base.add_style_sheet(:round_button, {
  layer: {
    cornerRadius: 8
  }
})
PlasticCup::Base.add_style_sheet(:green_button, {
  extends: :round_button,
  backgroundColor: UIColor.greenColor
}
@button = PlasticCup::Base.style(UIButton.new, :green_button)
```

Support different iOS versions
```ruby
PlasticCup::Base.add_style_sheet(:bg_view, {
  frame: CGRectMake(0, 0, 320, 200)
}, :all)

PlasticCup::Base.add_style_sheet(:bg_view, {
  frame: CGRectMake(0, 20, 320, 200)
}, :ios7)
# supported symbols: :all, :ios4, :ios5, :ios6, :ios7
# default is :all
```

If you define stylesheet outside methods, some values (e.g. UIFont) need to be in Proc form:
```ruby
PlasticCup::Base.add_style_sheet(:login_title, {
    text: 'Login',
    font: lambda {UIFont.systemFontOfSize(28)}
})
```

#### Important: Don't add handler inside any instance method

Will leak:
```ruby
def viewDidLoad
  super

  PlasticCup::Base.handler UIButton, :highlighted_image do |target, image|
    target.setImage(image, forState: UIControlStateHighlighted)
  end
end
```

Will not leak:
```ruby
PlasticCup::Base.handler UIButton, :highlighted_image do |target, image|
  target.setImage(image, forState: UIControlStateHighlighted)
end

def viewDidLoad
  super
end
```
