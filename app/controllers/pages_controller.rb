class PagesController < ApplicationController
  before_action :require_user, except: :front

  def front; end

  def home; end
end
