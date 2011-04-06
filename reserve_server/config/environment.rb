# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
FYP::Application.initialize!

ActiveRecord::Base.instance_eval do
  def per_page; 3; end
end

