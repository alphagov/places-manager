require "rails_helper"

RSpec.describe "Main menu" do
  context "as a normal user" do
    it "shows the Services/Switch app menu items and goes to signon when Switch app is clicked" do
      as_gds_editor do
        visit "/admin"

        within(".govuk-service-navigation__container") do
          expect(page).to have_link("Services")
          expect(page).to have_link("Switch app")
        end
      end
    end
  end
end
