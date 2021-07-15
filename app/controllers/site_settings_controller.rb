class SiteSettingsController < ApplicationController
  before_action :set_guideline, only: %i[edit update]

  def edit; end

  def update
    redirect_to guidelines_path, notice: "Guidelines was successfully updated" if @guideline.update(site_params)
  end

  private

  def set_guideline
    @guideline = SiteSetting.find(params[:id])
  end

  def site_params
    params.require(:site_setting).permit(:guideline)
  end
end
