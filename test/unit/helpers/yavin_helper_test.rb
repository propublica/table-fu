require 'test_helper'

class YavinHelperTest < ActionView::TestCase
  test "formatting comma number" do
    assert_equal "1,000", fmt("comma", 1000)
  end
  test "formatting percent number" do
    assert_equal "1000.000%", fmt("percent", 1000)
  end
  test "formatting currency number" do
    assert_equal "$1,000.00", fmt("currency", 1000) 
  end
  test "trying to format with bad function call" do
    assert_equal 1000, fmt("test", 1000)
  end
  test "format strings as well" do
    assert_equal "$1,000.00", fmt("currency", "1000")
  end
end
