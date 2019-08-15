module TransactionsHelper
  def transaction_params
    params.require(:transaction).permit(:total_price, :transaction_token)
  end
end
