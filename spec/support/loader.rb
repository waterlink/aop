module FixtureLoader
  def self.included(base)
    base.after { reset_fixtures }
  end

  def load_fixture(name, filename)
    return if loaded[name]
    load "./spec/fixtures/#{filename}.rb"
    loaded[name] = 1
  end

  def reset_fixtures
    loaded.each do |name, _|
      Object.send(:remove_const, name)
    end
  end

  private

  def loaded
    @_loaded ||= {}
  end
end
