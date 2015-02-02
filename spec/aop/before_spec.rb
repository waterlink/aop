RSpec.describe "Before advice" do
  def self.spy(given_spy=nil)
    @_spy ||= given_spy
  end

  def self.reset
    @_spy = nil
  end

  class BankAccount < Struct.new(:spy)
    def transfer(to, amount)
      spy.inside(to, amount)
    end
  end

  Aop["BankAccount#transfer:before"].advice do |account, *args, &blk|
    spy.before(account, *args, &blk)
  end

  it "fires before #transfer" do
    spy = self.class.spy(double("Spy"))

    account = BankAccount.new(spy)
    other = BankAccount.new(spy)
    amount = 55

    expect(spy).to receive(:before).with(account, other, amount).ordered.once
    expect(spy).to receive(:inside).with(other, amount).ordered.once

    account.transfer(other, amount)

    self.class.reset
  end
end
