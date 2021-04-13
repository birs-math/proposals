Role.find_or_create_by!(name: 'Admin')
Role.find_or_create_by!(name: 'Staff')
Role.find_or_create_by!(name: 'Reviewers')
Role.find_or_create_by!(name: 'Organizers')

unless User.find_by(email: 'admin@proposals.com')
   User.create!(email: 'admin@proposals.com', password: 'W!cOp123')
end

user = User.find_by(email: 'admin@proposals.com')
admin = Role.find_by(name: 'Admin')
user.roles << admin unless user.roles.include?(admin)

RolePrivilege.find_or_create_by!(role: admin, permission_type: 'write', privilege_name: 'Location')
RolePrivilege.find_or_create_by!(role: admin, permission_type: 'write', privilege_name: 'Subject')
