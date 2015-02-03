class BankAccount < Struct.new(:spy)
  def transfer(to, amount)
    spy.inside(to, amount)
  end
end
