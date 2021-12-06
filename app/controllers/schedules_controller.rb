class SchedulesController < ApplicationController
  before_action :authenticate_user!, except: %i[create]
  before_action :authorize_user, except: %i[create]
  skip_before_action :verify_authenticity_token, only: %i[create]
  before_action :json_only, :authenticate_api_key, only: %i[create]
  before_action :set_location, only: %w[new_schedule_run]
  before_action :set_schedule_run, only: %w[abort_run optimized_schedule]

  def new; end

  def create
    return unless @authenticated

    schedule_errors = save_schedules_data

    if schedule_errors.flatten.empty?
      render json: { success: 'Schedule saved!' }, status: :ok
    else
      Rails.logger.info("Schedule save errors: #{schedule_errors}")
      render json: { errors: schedule_errors.join(',') },
             status: :unprocessable_entity
    end
  end

  def new_schedule_run; end

  def run_hmc_program
    schedule_run = ScheduleRun.new(run_params)
    if schedule_run.save
      hmc_program(schedule_run)
    else
      render json: { errors: schedule_run.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def abort_run
    # TODO: abort_run method pending
  end

  def optimized_schedule
    @case_num = if params[:page].to_i > @schedule_run.cases
                  @schedule_run.cases
                else
                  params[:page] >= "1" ? params[:page] : 1
                end
    @schedules = Schedule.where(schedule_run_id: @schedule_run.id, case_num: @case_num)
  end

  private

  def run_params
    params.permit(:weeks, :runs, :cases, :location_id, :year, :test_mode)
  end

  def schedule_params
    params.require(:schedule)
          .permit(:SCHEDULE_API_KEY, :schedule_run_id,
                  run_data: [:case_num, :hmc_score,
                             assignments: [:week, :proposal]])
  end

  def hmc_program(schedule_run)
    hmc = HungarianMonteCarlo.new(schedule_run: schedule_run)
    if hmc.errors.present?
      render json: { errors: hmc.errors }, status: :unprocessable_entity
    else
      HmcJob.new(hmc).perform(schedule_run)
      head :accepted
    end
  end

  def set_schedule_run
    @schedule_run = ScheduleRun.find_by(id: params[:run_id])
  end

  def set_location
    @location = Location.find_by(id: params[:location])
  end

  def authenticate_api_key
    @authenticated = false
    if ENV['SCHEDULE_API_KEY'].blank?
      render json: { error: "We have no API key!" }, status: :unauthorized
      return
    end

    if schedule_params['SCHEDULE_API_KEY'] != ENV['SCHEDULE_API_KEY']
      render json: { error: "Invalid API key." }, status: :unauthorized
      return
    end

    @authenticated = true
  end

  def json_only
    head :not_acceptable unless request.format == :json
  end

  def save_schedules_data
    schedule_run_id = schedule_params['schedule_run_id']

    schedule_params['run_data'].each_with_object([]) do |run_data, errors|
      error = save_schedule(schedule_run_id, run_data)
      errors << error if error.present?
    end
  end

  def save_schedule(schedule_run_id, run_data)
    return "Empty week assignments!" if run_data["assignments"].blank?

    run_data["assignments"].flatten.each do |assignment|
      schedule = Schedule.new(schedule_run_id: schedule_run_id,
                              case_num: run_data["case_num"],
                              hmc_score: run_data["hmc_score"],
                              week: assignment["week"],
                              proposal: assignment["proposal"])
      return if schedule.save

      Rails.logger.info "Schedule save failed: #{schedule.errors.full_messages}"
      schedule.errors.full_messages
    end
  end

  def authorize_user
    authorize! params[:action], SchedulesController
  end
end
