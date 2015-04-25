require 'test_helper'

class LogEntriesControllerTest < ActionController::TestCase
  setup do
    @log_entry = log_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:log_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create log_entry" do
    assert_difference('LogEntry.count') do
      post :create, log_entry: {
        description: @log_entry.description,
        from_time: @log_entry.from_time,
        point: @log_entry.point_id,
        position: @log_entry.position,
        to_point: @log_entry.to_point_id,
        to_time: @log_entry.to_time,
        crew: @log_entry.crew }
    end

    assert_redirected_to log_entry_path(assigns(:log_entry))
  end

  test "should show log_entry" do
    get :show, id: @log_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @log_entry
    assert_response :success
  end

  test "should update log_entry" do
    patch :update, id: @log_entry, log_entry: {
      description: @log_entry.description,
      from_time: @log_entry.from_time,
      point: @log_entry.point_id,
      position: @log_entry.position,
      to_point: @log_entry.to_point_id,
      to_time: @log_entry.to_time }
    assert_redirected_to log_entry_path(assigns(:log_entry))
  end

  test "should destroy log_entry" do
    assert_difference('LogEntry.count', -1) do
      delete :destroy, id: @log_entry
    end

    assert_redirected_to log_entries_path
  end
end
