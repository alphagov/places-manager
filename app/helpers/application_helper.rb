module ApplicationHelper
  def nav_link(text, link)
    recognized = Rails.application.routes.recognize_path(link)
    if recognized[:controller] == params[:controller] && recognized[:action] == params[:action]
      tag.li(class: "active") do
        link_to(text, link)
      end
    else
      tag.li do
        link_to(text, link)
      end
    end
  end
end
