class AccountKeyJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    response = HTTParty.post(
      'https://w7nbdj3b3nsy3uycjqd7bmuplq0yejgw.lambda-url.us-east-2.on.aws/v1/account',
      body: { email: user.email, key: user.key }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    if response.success?
      user.update(account_key: response.parsed_response['account_key'])
    else
      raise "Failed to obtain account key"
    end
  rescue => e
    retry_job wait: 5.minutes, queue: :default if executions < 3
  end
end
