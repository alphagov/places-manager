require "govspeak"

class GovspeakUtils
  def self.govspeak_or_string(input)
    govspeak = Govspeak::Document.new(input)
    html = govspeak.to_html
    return input if html == "<p>#{input}</p>\n"

    govspeak.valid? ? html : ""
  end
end
