require 'test_helper'
require 'dhcpsapi'

class ClassTest < Test::Unit::TestCase
  def setup
    @subnet_1 = "192.168.242.0"
    @subnet_2 = "192.168.243.0"
    @api = new_server
  end

  def test_create_list_delete_classes
    original_class_count = @api.list_classes.size

    @api.create_class('test_class_one', 'test class one comment', false, 'test class one data')
    @api.create_class('test_class_two', 'test class two comment', true, 'test class two data')

    classes = @api.list_classes
    assert classes.any? {|c| c[:class_name] == 'test_class_one'}
    assert classes.any? {|c| c[:class_name] == 'test_class_two'}

    @api.delete_class('test_class_one')
    @api.delete_class('test_class_two')
    assert_equal original_class_count, @api.list_classes.size
  ensure
    ignore_exceptions { @api.delete_class('test_class_one') }
    ignore_exceptions { @api.delete_class('test_class_two') }
  end

  def test_delete_non_existent_class
    assert_raises(DhcpsApi::Error) { @api.delete_class('__pretty_sure_does_not_exist__') }
  end
end
