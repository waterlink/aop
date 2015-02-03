RSpec.describe "After advice" do
  include FixtureLoader

  let(:spy) { double("Spy") }

  before do
    load_fixture("BankAccount", "bank_account")

    Aop["BankAccount#transfer:after"].advice do |account, *args, &blk|
      spy.after(account, *args, &blk)
    end
  end

  it "fires after #transfer" do
    account = BankAccount.new(spy)
    other = BankAccount.new(spy)
    amount = 55

    expect(spy).to receive(:inside).with(other, amount).ordered.once
    expect(spy).to receive(:after).with(account, other, amount).ordered.once

    account.transfer(other, amount)
  end
end
