class FaqsController < ApplicationController
  before_action :set_faq, only: %i[edit update destroy move]

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
    redirect_to faqs_path, notice: "Faq has been updated!" if @faq.update(faq_params)
  end

  def destroy
    redirect_to faqs_path, notice: "Faq has been deleted!" if @faq.destroy
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
end
