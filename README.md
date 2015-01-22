# Aop

Very thin AOP gem for Ruby.

Thin and fast framework for Aspect Oriented Programming in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aop'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aop

## Usage

### Before advice

*Not implemented*

```ruby
module Authentication
  Aop["BankAccount#transfer:before"] do |account, *args, &blk|
    can!(:transfer, account)
  end

  def self.can!(action, subject)
    # raises error if current user can't execute `action` on `subject`
  end
end
```

### After advice

*Not implemented*

```ruby
module Analytics
  Aop["User#sign_in:after"] do |target, *args, &blk|
    report("sign_in", user.id)
  end
end
```

### Around advice

*Not implemented*

```ruby
module Transactional
  Aop["BankAccount#transfer:around"] do |joint_point, account, *args, &blk|
    start_transaction
    joint_point.call
    finish_transaction
  end
end
```

## TODO (to specify)

- multiple classes, methods and types of advices

## Contributing

1. Fork it ( https://github.com/waterlink/aop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
