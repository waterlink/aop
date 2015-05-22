require "aop"
require "contracts"

class BankAccount < Struct.new(:number, :amount)
  include Contracts

  Contract BankAccount, Num => Num
  def transfer(other, amount)
    self.amount -= amount
    other.amount += amount
  end

  Contract nil, Num => Num
  def transfer(_, amount)
    self.amount -= amount
  end
end

@actual = nil
@expected = "Transfered 100 from 12345 to cash account"

Aop["BankAccount#transfer:around"].advice do |jp, account, other, amount|
  @actual = "Transfered #{amount} from #{account.number} to #{other ? other.number : "cash account"}"
  jp.call
end

BankAccount[12345, 955].transfer(nil, 100)

fail "\nExpected: #{@expected}\nActual:   #{@actual}" unless @expected == @actual
