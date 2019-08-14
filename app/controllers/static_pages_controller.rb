class StaticPagesController < ApplicationController
  def home
    
  end

  def result
    @purchase_uri = Rails.configuration.spreedly['environment_key']
  end

  def about
  end

  def contact
  end
end
