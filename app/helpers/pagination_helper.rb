module PaginationHelper
  def requested_page
    page = params[:page].to_i
    page.positive? ? page : 1
  end
end
