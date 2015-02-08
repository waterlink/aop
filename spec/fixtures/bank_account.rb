class BankAccount < Struct.new(:spy)
  def transfer(to, amount)
    spy.inside(to, amount)
    :a_result
  end

  def self.transfer(spy, from, to, amount)
    spy.inside(spy, from, to, amount)
    :a_result
  end
end
