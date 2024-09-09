def as_gds_editor(&block)
  as_logged_in_user(["GDS Editor"], "government-digital-service", &block)
end

def as_test_department_user(&block)
  as_logged_in_user([], "test-department", &block)
end

def as_other_department_user(&block)
  as_logged_in_user([], "other-department", &block)
end

def as_logged_in_user(permissions, organisation_slug, &_block)
  allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
  allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(User.new(permissions:, organisation_slug:))
  yield
  allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_call_original
  allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_call_original
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_call_original
end
