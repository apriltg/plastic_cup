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
