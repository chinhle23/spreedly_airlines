require 'net/http'

class TransactionsController < ApplicationController
  include TransactionsHelper

  def index
    @transactions = Transaction.all
  end

  def show
  end

  def new
  end

  def create
    @payment_token = params[:payment_method_token]
    # build the cURL command mentioned here: https://docs.spreedly.com/basics/purchase/
    purchase_uri = URI("https://core.spreedly.com/v1/gateways/#{Rails.configuration.spreedly['gateway_token']}/purchase.json")
    purchase_post_request = Net::HTTP::Post.new(purchase_uri)
    purchase_post_request.basic_auth(
      Rails.configuration.spreedly['environment_key'],
      Rails.configuration.spreedly['access_secret']
    )
    purchase_post_request['Content-Type'] = 'application/json'
    purchase_post_request.body = {
      'transaction' => {
        'payment_method_token' => @payment_token,
        'amount' => 100,
        'currency_code' => 'USD',
        'retain_on_success' => true
      }
    }.to_json

    purchase_response = Net::HTTP.start(purchase_uri.hostname, purchase_uri.port, use_ssl: true) do |http|
      http.request(purchase_post_request).body
    end
    @parsed_purchase_response = JSON.parse(purchase_response)
    @transaction = Transaction.new(transaction_params)
    @transaction.flight_id = params[:flight_id]
    @transaction.save
    flash.notice = "Transaction '#{@transaction.transaction_token}' Created!"
    redirect_to flight_path(@transaction.flight)
  end
end
