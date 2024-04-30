require "rails_helper"
require "places_manager/file_verifier"

RSpec.describe(PlacesManager::FileVerifier, type: :model) do
  it "it can be handed a file object" do
    f = File.open(Rails.root.join("features/support/data/register-offices.csv"))
    expect(PlacesManager::FileVerifier.new(f).csv?).to(eq(true))
  end

  it "it can be handed a path" do
    f = Rails.root.join("features/support/data/register-offices.csv")
    expect(PlacesManager::FileVerifier.new(f).csv?).to(eq(true))
  end

  it "it can provide just the main type of a file" do
    f = Rails.root.join("features/support/data/rails.csv")
    expect(PlacesManager::FileVerifier.new(f).type).to(eq("image"))
  end

  it "it can provide just the sub-type of a file" do
    f = Rails.root.join("features/support/data/rails.csv")
    expect(PlacesManager::FileVerifier.new(f).sub_type).to(eq("png"))
  end
end
