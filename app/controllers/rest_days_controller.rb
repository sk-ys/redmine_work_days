class RestDaysController < ApplicationController
  before_action :require_admin
  before_action :get_year

  unloadable

  def index
    @rest_day = RestDay.new
    @rest_days = RestDay.in_year(@year).all

    @rest_day_csv = RestDayCsv.new
    @rest_day_range = RestDayRange.new
  end

  def create
    if Rails::VERSION::MAJOR < 4
      params_permitted = params[:rest_day]
    else
      params_permitted = params.require(:rest_day).permit([:day, :description])
    end
    @rest_day = RestDay.new(params_permitted)
    if @rest_day.save
      RestDay.clear!
      redirect_to rest_days_path, :notice => l(:notice_create_rest_day_success)
    else
      redirect_to rest_days_path, :alert => l(:alert_create_rest_day_failure)
    end
  end

  def import
    if Rails::VERSION::MAJOR < 4
      params_permitted = params[:rest_day_csv]
    else
      params_permitted = params.require(:rest_day_csv).permit([:file])
    end
    @rest_day_csv = RestDayCsv.new(params_permitted)

    if @rest_day_csv.valid?
      begin
        @rest_day_csv.import_from_csv!
        RestDay.clear!
      rescue => e
        flash[:error] = e.message
        redirect_to rest_days_path
        return
      end
      redirect_to rest_days_path, :notice => l(:notice_import_rest_days_success, :count => @count)
    else
      @rest_day = RestDay.new
      @rest_days = RestDay.in_year(@year).all
      @rest_day_range = RestDayRange.new
      render :action => "index"
    end
  end

  def range_delete
    if Rails::VERSION::MAJOR < 4
      params_permitted = params[:rest_day_range]
    else
      params_permitted = params.require(:rest_day_range).permit([:from, :to])
    end
    @rest_day_range = RestDayRange.new(params_permitted)

    if @rest_day_range.valid?
      @rest_days = RestDay.between(@rest_day_range.from, @rest_day_range.to)
      @count = @rest_days.count
      @rest_days.destroy_all
      RestDay.clear!
      redirect_to rest_days_path, :notice => l(:notice_delete_rest_days_success, :count => @count)
    else
      @rest_day = RestDay.new
      @rest_day_csv = RestDayCsv.new
      @rest_days = RestDay.in_year(@year).all
      render :action => "index"
    end
  end

  private
  def get_year
    if session[:year].present? and params[:year].blank?
      @year = session[:year]
    else
      @year = params[:year].present? ? Date.new(params[:year].to_i, 1, 1) : Date.today
      session[:year] = @year
    end
  end
end
