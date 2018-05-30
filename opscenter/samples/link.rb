# this is an example of how to generate one time app install link using
# ruby net http client

# 1. Setup robot user and token on the ops center first:
#
# $ gravity resource create -f userandtoken.yaml
# created user "jenkins@example.com"
# created token for user "jenkins@example.com"
#
# Now you can use the token to authorize the HTTP requests

require "net/http"
require "uri"
require 'json'

# the URL of your opscenter
opscenter_url = "https://example.com"

# account_id is always the same, don't change it
account_id = "00000000-0000-0000-0000-000000000001"

# pick username and token from the token yaml file
username = "jenkins@example.com"
token = "enter-your-token-here-please-dont-use-this-one"

# set application name and version to the app published in the ops center
app_name = "mattermost"
app_version = "2.2.0"

uri = URI.parse("#{opscenter_url}/portal/v1/tokens/install")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
request.basic_auth(username, token)

request.body = {"app" => "gravitational.io/#{app_name}:#{app_version}", "account": account_id, "type": "agent"}.to_json

response = http.request(request)

if response.code != "200" then
  printf("Received error status: %s\nResponse: %s\n", response.code, response.body)
  exit 255
else
  data = JSON.parse(response.body)
  token = data["token"]
  printf("Token:\n#{opscenter_url}/web/installer/new/gravitational.io/#{app_name}/#{app_version}?install_token=#{token}\n")
end
