class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_feedback, only: %w[update add_reply]
  
  def index
    @feedback = Feedback.all
  end

  def new
    @feedback = Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.user = current_user
    if @feedback.save
      FeedbackMailer.with(feedback: @feedback).new_feedback_email.deliver_later
      redirect_to feedbacks_path, notice: 'Your feedback has been submitted.'
    else
      render :new, alert: 'There is error while saving feedback'
    end
  end

  def update
    @feedback.toggle!(:reviewed)
    redirect_to feedback_path
  end

  def add_reply
    if @feedback.update(reply: params[:feedback_reply])
      render json: {}, status: :ok
    else
      render json: {erros: @feedback.errors.full_messages }, status: 500
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:content)
  end

  def set_feedback
    @feedback = Feedback.find_by(id: params[:id])
  end
end
