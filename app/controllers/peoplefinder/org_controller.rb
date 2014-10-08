require 'peoplefinder'

class Peoplefinder::OrgController < ApplicationController
  def show
    render json: GroupHierarchy.new(Group.department).to_hash
  end
end
