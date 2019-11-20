class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy]

  def index
    @teams = Team.all
  end

  def show
    if params[:leader]
    @team.owner=nil
    @user=User.find(params[:id])
    @team.owner=@user
    @team.update(team_params)
    else
    @working_team = @team
    change_keep_team(current_user, @team)
    end
  end

  def new
    @team = Team.new
  end

  def edit; end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

 def transfer_authority
 
end

  def update
    if current_user.id == @team.owner_id
      @team.update(team_params)
      redirect_to @team, notice: I18n.t('views.messages.update_team')
    else
      redirect_to @team, notice:"only the owner of the team can edit"
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id leader]
  end
end
