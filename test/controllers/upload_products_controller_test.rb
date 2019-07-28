require 'test_helper'

class UploadProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get upload_products_new_url
    assert_response :success
  end

  test "should get create" do
    get upload_products_create_url
    assert_response :success
  end

end
