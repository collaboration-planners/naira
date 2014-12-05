defmodule Naira.EmailService do
	@moduledoc """
  Email service.
"""

  require Logger

  # Environment variable names
	@smtp_server "NAIRA_SMTP_SERVER"
  @smtp_login "NAIRA_SMTP_LOGIN"
  @smtp_password "NAIRA_SMTP_PASSWORD"

	# API

  def email_api_key([user: user, api_key: api_key]) do
		text = """
Hi #{user.name},

This is your api key: #{api_key}

Thanks,
Naira
    """
		send! to: user.email, subject: "Your Naira API key", body: text
  end

  def email_password([user: user, password: password]) do
		text = """
Hi #{user.name},

Your new password is: #{password}

Thanks,
Naira
    """
		send! to: user.email, subject: "Your new Naira password", body: text
  end

  def password_changed([user: user]) do
		text = """
Hi #{user.name},

Your password was changed.

Thanks,
Naira
    """
		send! to: user.email, subject: "Your Naira password was changed", body: text
  end



	# PRIVATE

  defp send!([to: to, subject: subject, body: body]) do
		result = :gen_smtp_client.send({to, [smtp_login], "Subject: #{subject}\r\nFrom: #{smtp_login}\r\nTo: #{to}\r\n\r\n#{body}"}, [{:relay, smtp_server}, {:username, smtp_login}, {:password, smtp_password}])
		IO.puts "Email sent to #{to}: #{inspect result}"
		case result do
			{:ok, _} -> :ok
			_ -> Logger.warn "Failed to email \"#{subject}\" to #{to}: #{inspect result}"
					 {:error, :email_not_sent}
    end
	end

  defp smtp_server do
		System.get_env @smtp_server
  end

  defp smtp_login do
		System.get_env @smtp_login
	end

  defp smtp_password do
    System.get_env @smtp_password
  end

end
