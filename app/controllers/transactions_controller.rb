require 'net/http'
require 'json'

class TransactionsController < ApplicationController
  include TransactionsHelper

  def index
    @transactions = Transaction.all
  end

  def show
  end

  def new
    @flight = Flight.find(params[:flight_id])
    @transaction = Transaction.new
    @transaction.flight_id = @flight.id
    @environment_key = Rails.configuration.spreedly['environment_key']
    @total_price = @flight.price
    @total_price += 200 if params[:hotel] == 'true'
    
    if params[:payment_method_token]
      payment_token = params[:payment_method_token]

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
          'payment_method_token' => payment_token,
          'amount' => @flight.price * 100,
          'currency_code' => 'USD',
          'retain_on_success' => params[:save_card]
        }
      }.to_json

      purchase_response = Net::HTTP.start(purchase_uri.hostname, purchase_uri.port, use_ssl: true) do |http|
        http.request(purchase_post_request).body
      end
      parsed_purchase_response = JSON.parse(purchase_response)
      transaction_token = parsed_purchase_response['transaction']['token']
      @transaction.transaction_token = transaction_token
      @transaction.total_price = @flight.price
      @transaction.save
      flash.notice = "Transaction #{transaction_token} Completed!"

      if @total_price == @flight.price
        pmd_delivery_uri = URI("https://core.spreedly.com/v1/receivers/#{Rails.configuration.spreedly['receiver_token']}/deliver.json")
        pmd_delivery_post_request = Net::HTTP::Post.new(pmd_delivery_uri)

        pmd_delivery_post_request.basic_auth(
          Rails.configuration.spreedly['environment_key'],
          Rails.configuration.spreedly['access_secret']
        )

        pmd_delivery_post_request['Content-Type'] = 'application/json'
        pmd_delivery_post_request.body = {
          'delivery' => {
            'payment_method_token' => payment_token,
            'url' => 'https://spreedly-echo.herokuapp.com',
            'headers' => 'Content-Type: application/json',
            'body' => '{ \"product_id\": \"916598\", \"card_number\": \"{{credit_card_number}}\" }'
          }
        }.to_json

        pmd_delivery_response = Net::HTTP.start(pmd_delivery_uri.hostname, pmd_delivery_uri.port, use_ssl: true) do |http|
          http.request(pmd_delivery_post_request).body
        end
        parsed_pmd_delivery_response = JSON.parse(pmd_delivery_response)
        pmd_transaction_token = parsed_pmd_delivery_response['transaction']['token']
        flash.notice = "PMD Transaction #{pmd_transaction_token} Completed!"
      end 
    end
  
    # redirect_to flight_transaction_path(@flight, @transaction)
  end

  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.flight_id = params[:flight_id]
    @transaction.save
    flash.notice = "Transaction '#{@transaction.transaction_token}' Created!"
    redirect_to flight_path(@transaction.flight)
  end
end
