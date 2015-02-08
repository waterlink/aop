class CashAccount < Struct.new(:spy)
  def transfer(to, amount)
    spy.inside(:cash_account, to, amount)
    :a_result
  end

  def withdraw(amount)
    spy.withdraw(:cash_account, self, amount)
    :a_result
  end

  def self.transfer(spy, from, to, amount)
    spy.inside(:cash_account, spy, from, to, amount)
    :a_result
  end
end
