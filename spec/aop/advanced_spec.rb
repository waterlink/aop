RSpec.describe "Advanced advices" do
  include FixtureLoader

  let(:spy) { double("Spy") }

  before do
    load_fixture("BankAccount", "bank_account")
  end

  describe "class methods" do
    before do
      Aop["BankAccount.transfer:around"].advice do |joint_point, klass, *args, &blk|
        spy.before(klass, *args, &blk)
        joint_point.call
        spy.after(klass, *args, &blk)
      end
    end

    it "fires around #transfer" do
      account = BankAccount.new(spy)
      other = BankAccount.new(spy)
      amount = 55

      expect(spy).to receive(:before).with(BankAccount, spy, account, other, amount).ordered.once
      expect(spy).to receive(:inside).with(spy, account, other, amount).ordered.once
      expect(spy).to receive(:after).with(BankAccount, spy, account, other, amount).ordered.once

      expect(BankAccount.transfer(spy, account, other, amount)).to eq(:a_result)
    end
  end
end
