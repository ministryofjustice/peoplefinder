module Admin
  class SettingsController < AdminController
    def update
      key = params[:id]
      value = params[:setting][:value]
      Setting[key] = value
      notice :updated, key: key
      redirect_to admin_path
    end
  end
end
