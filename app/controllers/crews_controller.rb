  class CrewsController < ApplicationController
  before_action :set_crew, only: [:show, :update, :destroy]

  # GET /crews
  # GET /crews.json
  def index
    @crews = Crew.all
    @best = Crew.where(:finished => true).order(distance: :asc).last 8
    time_now = DateTime.now
    @ongoing = Crew.where(["finished = ? and updated_at > ?", false, time_now - 30.minutes]).order(updated_at: :asc).last(8).sort_by {|e| e[:game_time]}
  end

  # GET /crews/1
  # GET /crews/1.json
  def show
    @log_entry = LogEntry.new
    @log_entry.crew = @crew
    @log_entry.point = @crew.last_point

    @sections = @crew.last_point.sections

    for section in @sections
      @crew.sections << section unless (@crew.sections.include?(section) || @crew.sections.include?(section.opposite))
    end


    @points = @crew.last_point.targets
    unless @points.include?(@crew.start_point)
      @points << @crew.start_point
    end

    @rounded_points = Array.new
    for leg in @crew.log_entries
      if  leg.to_point.present?
        @rounded_points << leg.to_point
      end
    end
  end


  def create_log_entry
    @crew = Crew.find(params[:id])

    @log_entry = @crew.log_entries.build
    @log_entry.to_point_id = params[:to_point_id]
    @log_entry.point = @crew.last_point
    @log_entry.from_time = @crew.game_time
    @log_entry.to_time = @crew.game_time
    if @log_entry.point.present? && @log_entry.to_point.present?
      @log_entry.distance = Section.find_by(point: @log_entry.point, to_point: @log_entry.to_point).distance
      unless @log_entry.distance <= 0
        increments = (@log_entry.distance * 3).round
        1.upto(increments) do
          @crew.increment :game_time,((@log_entry.distance / increments) / @crew.vmg).hours
        end
        @crew.distance += @log_entry.distance
        @log_entry.to_time = @crew.game_time #+ leg_time.hours
      end
    end
    next_point = Point.find params[:to_point_id]
    @crew.last_point = next_point
    @crew.save

    if @log_entry.save
      if @crew.tripled_rounding? @log_entry.to_point
        @punishment = @crew.log_entries.build
        @punishment.description = "Rundat #{@log_entry.to_point.number} för många gånger."
        @punishment.from_time = @crew.game_time
        @punishment.to_time = @crew.game_time
        @punishment.distance = - @log_entry.distance
        @crew.update(:distance => @crew.distance + @punishment.distance)
        @punishment.save
      else #don't punish twice
        if @crew.tripled_sections? @log_entry
          @punishment = @crew.log_entries.build
          @punishment.description = "Seglat #{@log_entry.from_to} för många gånger."
          @punishment.from_time = @crew.game_time
          @punishment.to_time = @crew.game_time
          @punishment.distance = - @log_entry.distance
          @crew.update(:distance => @crew.distance + @punishment.distance)
          @punishment.save
        end
      end
      @log_entry = LogEntry.new
    end
    redirect_to crew_url(@crew), notice: "Rundat."
  end

  def finish
    @crew = Crew.find(params[:id])
    unless @crew.finished
      @crew.finished= true
      actual_time = (@crew.game_time - @crew.start_time)/3600
      if actual_time > 24
        @punishment = @crew.log_entries.build
        @punishment.description = "Försenad #{((actual_time - 24) * 60).round} min."
        @punishment.from_time = @crew.game_time
        @punishment.to_time = @crew.game_time
        @punishment.distance = (-@crew.distance * 2 * (actual_time - 24) / 24).round 1
        @crew.update(:distance => @crew.distance + @punishment.distance)
        @punishment.save
      end
      @handicap_compensation = @crew.log_entries.build
      @handicap_compensation.description = "Handikapp,   kompensation för SXK-tal #{@crew.handicap} på distansen #{@crew.distance.round(1)}."
      @handicap_compensation.from_time = @crew.game_time
      @handicap_compensation.to_time = @crew.game_time
      @handicap_compensation.distance = @crew.distance * (1 -@crew.handicap)
      @crew.update(:distance => @crew.distance + @handicap_compensation.distance)
      @handicap_compensation.save
      @crew.save
    end
    redirect_to crew_url(@crew), notice: "Gått i mål."
  end

  # GET /crews/new
  def new
    @crew = Crew.new
    @start_points = Array.new
    for organizer in Organizer.order(:name) do
      for start_point in organizer.start_points do
        @start_points << start_point unless start_point.blank?
      end
    end
    @local_start_points = Array.new
    for start_point in Organizer.find_by_fk_org_code('St').start_points do
      @local_start_points << start_point unless start_point.blank?
    end
  end

  # POST /crews
  # POST /crews.json
  def create
    @crew = Crew.new(crew_params)
    @start_points = Array.new
    for organizer in Organizer.order(:name) do
      for start_point in organizer.start_points do
        @start_points << start_point unless start_point.blank?
      end
    end
    @local_start_points = Array.new
    for start_point in Organizer.find_by_fk_org_code('St').start_points do
      @local_start_points << start_point unless start_point.blank?
    end
    @crew.last_point = @crew.start_point
    respond_to do |format|
      if @crew.save
        format.html { redirect_to @crew, notice: 'Crew was successfully created.' }
        format.json { render :show, status: :created, location: @crew }
      else
        format.html { render :new }
        format.json { render json: @crew.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /crews/1
  # PATCH/PUT /crews/1.json
  def update
    respond_to do |format|
      if @crew.update(crew_params)
        format.html { redirect_to @crew, notice: 'Crew was successfully updated.' }
        format.json { render :show, status: :ok, location: @crew }
      else
        format.html { render :edit }
        format.json { render json: @crew.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crews/1
  # DELETE /crews/1.json
  def destroy
    @crew.destroy
    respond_to do |format|
      format.html { redirect_to new_crew_url, notice: 'Crew was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def gmaps4rails_sidebar
    "<span class='foo'>#{name}</span>"
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_crew
      @crew = Crew.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def crew_params
      params.require(:crew).permit(:boat_name, :captain_name, :captain_email, :last_point_id, :to_point_id, :start_point_id, log_entry: [:id, :crew_id, :point_id, :to_point_id, :from_time, :to_time, :position, :description, :distance ])
    end
end
