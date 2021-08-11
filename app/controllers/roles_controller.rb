class RolesController < ApplicationController
  before_action :set_role, only: %i[show new_user new_role remove_role]
  load_and_authorize_resource

  def index
    @roles = Role.where(role_type: 'staff_role')
  end

  def new
    @role = Role.new
    @role.role_privileges.build
  end

  def create
    @role = Role.new(role_params)
    create_privileges
    if @role.save
      redirect_to roles_path, notice: "Created a new #{@role.name} role!".squish
    else
      redirect_to new_role_path, alert: @role.errors.full_messages
    end
  end

  def show; end

  def new_user
    render json: {}, status: :ok
  end

  def new_role
    @user = User.find_by(id: params[:user_id])
    @user_role = UserRole.new(user_id: @user.id, role_id: @role.id)
    if @user_role.save
      redirect_to role_path(@role), notice: "Added new user in role #{@role.name}"
    else
      redirect_to role_path(@role), alert: @user_role.errors.full_messages
    end
  end

  def remove_role
    @user = User.find_by(id: params[:user_id])
    role = @role.user_roles.find_by(user_id: @user.id)
    role.destroy
    redirect_to role_path(@role), notice: "Deleted #{@user.fullname} from role #{@role.name}"
  end

  private

  def set_role
    @role = Role.find(params[:id])
  end

  def role_params
    params.require(:role).permit(:name)
  end

  def privilege_params(role)
    role.permit(:permission_type, :privilege_name)
  end

  def create_privileges
    params[:role_privileges].each_value do |role|
      @privilege = @role.role_privileges.new(privilege_params(role))
    end
  end
end
