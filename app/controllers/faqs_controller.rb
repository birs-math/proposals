class FaqsController < ApplicationController
  load_and_authorize_resource
  before_action :set_faq, only: %i[edit update destroy move]
  before_action :require_staff_member

  def index
    @faqs = Faq.all
  end

  def new
    @faq = Faq.new
  end

  def create
    @faq = Faq.new(faq_params)
    if @faq.save
      redirect_to faqs_path, notice: 'Your faq has been saved.'
    else
      render :new, alert: 'There is error while saving faq.'
    end
  end

  def edit; end

  def update
    if @faq.update(faq_params)
      redirect_to faqs_path, notice: "Faq has been updated!"
    else
      redirect_to faqs_path, alert: "Faq has not been updated!"
    end
  end

  def destroy
    @faq.destroy
    redirect_to faqs_path, notice: "Faq has been deleted!"
  end

  def move
    @faq = Faq.find_by(id: params[:faq_id])
    @faq.update(position: params[:position].to_i)
    head :ok
  end

  private

  def set_faq
    @faq = Faq.find(params[:id])
  end

  def faq_params
    params.require(:faq).permit(:question, :answer)
  end

  def require_staff_member
    redirect_to root_path unless current_user.staff_member?
  end
end
