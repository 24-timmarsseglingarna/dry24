class CrewsController < ApplicationController
  before_action :set_crew, only: [:show, :edit, :update, :destroy]

  # GET /crews
  # GET /crews.json
  def index
    @crews = Crew.all
  end

  # GET /crews/1
  # GET /crews/1.json
  def show
    @log_entry = LogEntry.new
    @log_entry.crew = @crew
    @log_entry.point = @crew.last_point

    @sections = @crew.last_point.sections
    @points = @crew.last_point.targets
    @points << @crew.last_point
    @points << @crew.start_point

    @polylines = Array.new
    from_point = @crew.last_point
    for point in from_point.targets
      roundpoints = []
      roundpoints << {:lng => from_point.longitude, :lat => from_point.latitude}
      roundpoints << {:lng => point.longitude, :lat => point.latitude}
      @polylines << roundpoints
    end


    for section in @crew.sections_within_range
      roundpoints = []
      roundpoints << {:lng => section.point.longitude, :lat => section.point.latitude}
      roundpoints << {:lng => section.to_point.longitude, :lat => section.to_point.latitude}
      @polylines << roundpoints
    end

    @visited = Array.new
    @wakes = Array.new
    for leg in @crew.log_entries
      if leg.point.present? && leg.to_point.present?
        roundpoints = []
        roundpoints << {:lng => leg.point.longitude, :lat => leg.point.latitude}
        roundpoints << {:lng => leg.to_point.longitude, :lat => leg.to_point.latitude}
        @wakes << roundpoints
        @visited << leg.to_point
      end
    end

    if @crew.finished
      @hash = Gmaps4rails.build_markers(@visited) do |point, marker|
        colorcode='fff'
        colorcode = 'ff8c00' if point.number == @crew.start_point.number
        marker.lat point.latitude
        marker.lng point.longitude
        marker.json({:id => point.number.to_i })
        marker.title point.number_name
        marker.picture ({
                           "url" => "https://chart.googleapis.com/chart?chst=d_map_spin&chld=0.6|000000|#{colorcode}|8|_|#{URI.encode(point.number)}",
                           "width" =>  23,
                           "height" => 41,
                       })
      end
    else
      @hash = Gmaps4rails.build_markers(@points) do |point, marker|
        colorcode='ff0'
        colorcode = 'ff8c00' if point.number == @crew.start_point.number
        colorcode = '66ff66' if point.number == @crew.last_point.number
        marker.lat point.latitude
        marker.lng point.longitude
        marker.json({:id => point.number.to_i })
        marker.title point.number_name
        marker.picture ({
                           "url" => "https://chart.googleapis.com/chart?chst=d_map_spin&chld=0.6|000000|#{colorcode}|8|_|#{URI.encode(point.number)}",
                           "width" =>  23,
                           "height" => 41,
                       })
        #"url" => "http://maps.google.com/mapfiles/ms/micons/sailing.png",
      end
    end

  end

  def create_log_entry
    @crew = Crew.find(params[:id])
    @log_entry = @crew.log_entries.build
    @log_entry.to_point_id = params[:to_point_id]
    @log_entry.point = @crew.last_point
    @log_entry.from_time = DateTime.now
    @log_entry.to_time = DateTime.now
    if @log_entry.point.present? && @log_entry.to_point.present?
      @log_entry.distance = Section.find_by(point: @log_entry.point, to_point: @log_entry.to_point).distance
    end
    next_point = Point.find params[:to_point_id]
    @crew.last_point = next_point
    @crew.save
    if @log_entry.save
      @log_entry = LogEntry.new
    end

    #render :action => :show
    #render 'crews/show'
    redirect_to crew_url(@crew), notice: "Rundat."
  end

  def finish
    @crew = Crew.find(params[:id])
    @crew.finished= true
    @crew.save
    redirect_to crew_url(@crew), notice: "Gått i mål."
  end

  # GET /crews/new
  def new
    @crew = Crew.new
  end

  # GET /crews/1/edit
  def edit
  end

  # POST /crews
  # POST /crews.json
  def create
    @crew = Crew.new(crew_params)
    @crew.last_point = @crew.start_point
    respond_to do |format|
      if @crew.save
        @log_entry = @crew.log_entries.build
        @log_entry.to_point = @crew.start_point
        @log_entry.point = nil
        @log_entry.from_time = nil
        @log_entry.to_time = DateTime.now
        @log_entry.save
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
      format.html { redirect_to crews_url, notice: 'Crew was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_crew
      @crew = Crew.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def crew_params
      params.require(:crew).permit(:boat_name, :captain_name, :captain_email, :last_point_id, :to_point_id, log_entry: [:id, :crew_id, :point_id, :to_point_id, :from_time, :to_time, :position, :description, :distance ])
    end
end