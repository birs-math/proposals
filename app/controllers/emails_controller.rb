class EmailController < ApplicationController
  def new
    @email = Email.new
  end
end
