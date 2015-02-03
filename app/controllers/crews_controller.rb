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
    @points = Point.find_by_number('555').targets
    @points << Point.find_by_number('555')

    @polylines = Array.new
    from_point = Point.find_by_number('555')
    for point in from_point.targets
      roundpoints = []
      roundpoints << {:lng => from_point.long_d, :lat => from_point.lat_d}
      roundpoints << {:lng => point.long_d, :lat => point.lat_d}
      @polylines << roundpoints
    end


    @hash = Gmaps4rails.build_markers(@points) do |point, marker|
      colorcode='ff0'
      colorcode = 'f0f' if point.number == '555'
      marker.lat point.lat_d
      marker.lng point.long_d
      marker.json({:id => point.number.to_i })
      marker.title point.number
      marker.picture ({
           "url" => "https://chart.googleapis.com/chart?chst=d_map_spin&chld=0.6|000000|#{colorcode}|8|_|#{URI.encode(point.number)}",
           "width" =>  23,
           "height" => 41,
       })
    end

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
      params.require(:crew).permit(:boat_name, :captain_name, :captain_email)
    end
end
