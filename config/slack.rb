module Config
  module Slack
    module_function

    def send_to_lack(message, custome_name = nil)
      uri = URI.parse("https://slack.com/api/chat.postMessage")
      custome_message = if custome_name
                          "#{custome_name} | "
                        end
      params = {
        token: ENV["SLACK_TOKEN"],
        channel: ENV["SLACK_CHANEL_ID"],
        text: "```#{custome_message}#{message}```",
        as_user: true
      }

      uri.query = URI.encode_www_form(params)
      Net::HTTP.post_form(uri, params)
    end
  end
end
