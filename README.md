# Aop

[![Build Status](https://travis-ci.org/waterlink/aop.svg?branch=master)](https://travis-ci.org/waterlink/aop)

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

```ruby
module Authentication
  Aop["BankAccount#transfer:before"].advice do |account, *args, &blk|
    can!(:transfer, account)
  end

  def self.can!(action, subject)
    # raises error if current user can't execute `action` on `subject`
  end
end
```

### After advice

```ruby
module Analytics
  Aop["User#sign_in:after"].advice do |target, *args, &blk|
    report("sign_in", user.id)
  end
end
```

### Around advice

```ruby
module Transactional
  Aop["BankAccount#transfer:around"].advice do |joint_point, account, *args, &blk|
    start_transaction
    joint_point.call
    finish_transaction
  end
end
```

### Class methods

Use `.method` notation:

```ruby
module Transactional
  Aop["BankAccount.transfer:around"].advice do |joint_point, klass, *args, &blk|
    start_transaction
    joint_point.call
    finish_transaction
  end
end
```

### Multiple classes, methods and advices

Use `,` to use multiple classes, methods and advices:

```ruby
module Analytics
  Aop["User,Admin#sign_in,.sign_up,#sign_out:before,:after"].advice do |target, *args, &blk|
    report("auth_action", user.id)
  end
end
```

## TODO

- Fail hard and with descriptive error when unable to find a pointcut

## Contributing

1. Fork it ( https://github.com/waterlink/aop/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
