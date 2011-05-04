require "spec_helper"

describe SeriesController do
  describe "routing" do

=begin
    it "recognizes and generates #index" do
      { :get => "/series" }.should route_to(:controller => "series", :action => "index")
    end
=end

    it "recognizes and generates #show" do
      { :get => "/series/1" }.should route_to(:controller => "series", :action => "show", :permalink => "1")
    end

  end
end
