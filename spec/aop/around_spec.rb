RSpec.describe "Around advice" do
  include FixtureLoader

  let(:spy) { double("Spy") }

  before do
    load_fixture("BankAccount", "bank_account")

    Aop["BankAccount#transfer:around"].advice do |joint_point, account, *args, &blk|
      spy.before(account, *args, &blk)
      joint_point.call
      spy.after(account, *args, &blk)
    end
  end

  it "fires around #transfer" do
    account = BankAccount.new(spy)
    other = BankAccount.new(spy)
    amount = 55

    expect(spy).to receive(:before).with(account, other, amount).ordered.once
    expect(spy).to receive(:inside).with(other, amount).ordered.once
    expect(spy).to receive(:after).with(account, other, amount).ordered.once

    expect(account.transfer(other, amount)).to eq(:a_result)
  end
end
