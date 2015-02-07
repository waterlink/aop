RSpec.describe "Before advice" do
  include FixtureLoader

  let(:spy) { double("Spy") }

  before do
    load_fixture("BankAccount", "bank_account")

    Aop["BankAccount#transfer:before"].advice do |account, *args, &blk|
      spy.before(account, *args, &blk)
    end
  end

  it "fires before #transfer" do
    account = BankAccount.new(spy)
    other = BankAccount.new(spy)
    amount = 55

    expect(spy).to receive(:before).with(account, other, amount).ordered.once
    expect(spy).to receive(:inside).with(other, amount).ordered.once

    expect(account.transfer(other, amount)).to eq(:a_result)
  end
end
