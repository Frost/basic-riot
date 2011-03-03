class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me

  # Only permit mass assignment of username (for CAS login) at user creation
  attr_accessible :username, :scope => :new
  sanitizer_scope_recognizer :new do |record, scope_value|
    record.new_record?
  end

  devise :cas_authenticatable

  before_save :import_from_ldap

  def import_from_ldap
    return true unless self.new_record?
    return false if self.username.blank?
    filter = Net::LDAP::Filter.eq(:ugKthid, self.username)
    
    ldap = Net::LDAP.new( :host => "ldap.kth.se",
                          :base => "ou=Addressbook,dc=kth,dc=se",
                          :port => 389)
    
    ldap.search(:filter => filter) do |user|
      self.first_name = user.givenName.first
      self.last_name = user.sn.first
      self.kth_username = user.ugusername.first
      self.email = user.mail.first
      return true
    end
    return false
  end

end
