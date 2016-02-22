Rails.application.config.middleware.insert_before 0, "Rack::Cors", :debug => Rails.env.development?, :logger => (-> { Rails.logger }) do
  allow do
    origins 'localhost:4200', '127.0.0.1:4200', '0.0.0.0:4200', 'subkitchen.herokuapp.com'
    resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :patch, :head, :options]
  end
end
