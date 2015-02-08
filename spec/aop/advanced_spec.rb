RSpec.describe "Advanced advices" do
  include FixtureLoader

  let(:spy) { double("Spy") }

  before do
    load_fixture("BankAccount", "bank_account")
    load_fixture("CashAccount", "cash_account")
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

  describe "multiple classes, methods and advices" do
    before do
      Aop["BankAccount,CashAccount#transfer,#withdraw,.transfer:before,:after"].advice do |*args, &blk|
        spy.report(*args, &blk)
      end
    end

    it "works for BankAccount#transfer" do
      account = BankAccount.new(spy)
      other = BankAccount.new(spy)
      amount = 55

      expect(spy).to receive(:report).with(account, other, amount).ordered.once
      expect(spy).to receive(:inside).with(other, amount).ordered.once
      expect(spy).to receive(:report).with(account, other, amount).ordered.once

      expect(account.transfer(other, amount)).to eq(:a_result)
    end

    it "works for CashAccount#transfer" do
      account = CashAccount.new(spy)
      other = CashAccount.new(spy)
      amount = 55

      expect(spy).to receive(:report).with(account, other, amount).ordered.once
      expect(spy).to receive(:inside).with(:cash_account, other, amount).ordered.once
      expect(spy).to receive(:report).with(account, other, amount).ordered.once

      expect(account.transfer(other, amount)).to eq(:a_result)
    end

    it "works for BankAccount#withdraw" do
      account = BankAccount.new(spy)
      amount = 55

      expect(spy).to receive(:report).with(account, amount).ordered.once
      expect(spy).to receive(:withdraw).with(account, amount).ordered.once
      expect(spy).to receive(:report).with(account, amount).ordered.once

      expect(account.withdraw(amount)).to eq(:a_result)
    end

    it "works for CashAccount#withdraw" do
      account = CashAccount.new(spy)
      amount = 55

      expect(spy).to receive(:report).with(account, amount).ordered.once
      expect(spy).to receive(:withdraw).with(:cash_account, account, amount).ordered.once
      expect(spy).to receive(:report).with(account, amount).ordered.once

      expect(account.withdraw(amount)).to eq(:a_result)
    end

    it "works for BankAccount.transfer" do
      account = BankAccount.new(spy)
      other = BankAccount.new(spy)
      amount = 55

      expect(spy).to receive(:report).with(BankAccount, spy, account, other, amount).ordered.once
      expect(spy).to receive(:inside).with(spy, account, other, amount).ordered.once
      expect(spy).to receive(:report).with(BankAccount, spy, account, other, amount).ordered.once

      expect(BankAccount.transfer(spy, account, other, amount)).to eq(:a_result)
    end

    it "works for CashAccount.transfer" do
      account = CashAccount.new(spy)
      other = CashAccount.new(spy)
      amount = 55

      expect(spy).to receive(:report).with(CashAccount, spy, account, other, amount).ordered.once
      expect(spy).to receive(:inside).with(:cash_account, spy, account, other, amount).ordered.once
      expect(spy).to receive(:report).with(CashAccount, spy, account, other, amount).ordered.once

      expect(CashAccount.transfer(spy, account, other, amount)).to eq(:a_result)
    end
  end
end
