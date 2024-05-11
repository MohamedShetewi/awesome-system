class ApplicationController < ActionController::Base
    def show 
        render plain: params[:app_id]
    end
end
