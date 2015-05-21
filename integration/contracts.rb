require "aop"
require "contracts"

class BankAccount < Struct.new(:number, :amount)
  include Contracts

  Contract BankAccount, Num => Num
  def transfer(other, amount)
    self.amount -= amount
    other.amount += amount
  end
end

@actual = nil
@expected = "Transfered 100 from 12345 to 98765"

Aop["BankAccount#transfer:after"].advice do |account, other, amount|
  @actual = "Transfered #{amount} from #{account.number} to #{other.number}"
end

BankAccount[12345, 955].transfer(BankAccount[98765, 130], 100)

fail "\nExpected: #{@expected}\nActual:   #{@actual}" unless @expected == @actual
