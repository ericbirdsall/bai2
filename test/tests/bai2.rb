require File.expand_path('../../autorun.rb', __FILE__)

require 'bai2'

class Bai2Test < Minitest::Test

  def setup
    @daily = Bai2::BaiFile.parse(File.expand_path('../../data/daily.bai2', __FILE__))
    @eod = Bai2::BaiFile.parse(File.expand_path('../../data/eod.bai2', __FILE__))
  end

  def test_parsing
    assert_kind_of(Bai2::BaiFile, @daily)
    assert_kind_of(Bai2::BaiFile, @eod)
  end

  def test_groups
    [@daily, @eod].each do |file|
      assert_kind_of(Array, file.groups)
      assert_equal(1, file.groups.count)
      group = file.groups.first
      assert_kind_of(Bai2::BaiFile::Group, group)
      assert_equal('121140399', group.originator)
    end
    assert_equal('9999999999', @daily.groups[0].destination)
    assert_equal('3333333333', @eod.groups[0].destination)
  end

  def test_accounts
    [@daily, @eod].each do |file|
      accounts = @daily.groups.first.accounts
      assert_kind_of(Array, accounts)
      assert_equal(1, accounts.count)
      assert_kind_of(Bai2::BaiFile::Account, accounts.first)
    end
  end

  def test_transactions
    all_txs = [@daily, @eod].flat_map(&:groups).flat_map(&:accounts).flat_map(&:transactions)
    assert_equal(2, all_txs.count)
    all_txs.each do |tx|
      assert_kind_of(Bai2::BaiFile::Transaction, tx)
    end
    first, second = all_txs
    assert_equal(first.type, {
      code: 174,
      transaction: :credit,
      scope: :detail,
      description: 'Other Deposit'
    })
    assert_equal(second.type, {
      code: 195,
      transaction: :credit,
      scope: :detail,
      description: 'Incoming Money Transfer'
    })
  end

end
