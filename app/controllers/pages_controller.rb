class PagesController < ApplicationController
  def guidelines
    @guideline = SiteSetting.first
  end
end
