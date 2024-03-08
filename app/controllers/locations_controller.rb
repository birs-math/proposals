class LocationsController < ApplicationController
  load_and_authorize_resource
  before_action :set_location, only: %i[show edit update destroy]

  def index
    @locations = Location.all
  end

  def show; end

  def new
    @location = Location.new
  end

  def edit; end

  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: t('locations.create.success') }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: t('locations.update.success') }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html do
          redirect_to edit_location_path(@location), alert: "Code #{@location.code} has already been taken"
        end
        format.json { render json: @location.errors, status: :unprocessable_entity }

      end
    end
  end

  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: t('locations.destroy.success') }
      format.json { head :no_content }
    end
  end

  def weeks_exclude_dates
    if params[:start].blank? || params[:end].blank?
      render json: { errors: "Date cannot be empty." }, status: :unprocessable_entity
    else
      start_date = params[:start].to_date
      end_date = params[:end].to_date - 5.days
      exclude_dates = []
      workshop_start_date = start_date
      while workshop_start_date <= end_date
        workshop_end_date = workshop_start_date + 5.days # 5-Day Workshops
        exclude_dates << "#{workshop_start_date} - #{workshop_end_date}"
        workshop_start_date += 7.days
      end
      render json: { exclude_dates: exclude_dates }, status: :ok
    end
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :code, :city, :country, :start_date, :end_date, :time_zone,
                                     exclude_dates: [])
  end
end
