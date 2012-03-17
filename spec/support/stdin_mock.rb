class MockSTDIN

  attr_accessor :string

  def initialize(string=nil)
    @string = string
  end

  def fcntl(*args)
    @string ? 0 : 2
  end

  def read
    @string
  end

end

$stdin = MockSTDIN.new
