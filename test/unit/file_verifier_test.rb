require "test_helper"
require "places_manager/file_verifier"

class FileVerifierTest < ActiveSupport::TestCase
  test "it can be handed a file object" do
    f = File.open(Rails.root.join("features/support/data/register-offices.csv"))
    assert_equal true, PlacesManager::FileVerifier.new(f).csv?
  end

  test "it can be handed a path" do
    f = Rails.root.join("features/support/data/register-offices.csv")
    assert_equal true, PlacesManager::FileVerifier.new(f).csv?
  end

  test "it can provide just the main type of a file" do
    f = Rails.root.join("features/support/data/rails.csv")
    assert_equal "image", PlacesManager::FileVerifier.new(f).type
  end

  test "it can provide just the sub-type of a file" do
    f = Rails.root.join("features/support/data/rails.csv")
    assert_equal "png", PlacesManager::FileVerifier.new(f).sub_type
  end
end
