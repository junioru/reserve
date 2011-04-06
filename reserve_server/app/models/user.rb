# == Schema Information
# Schema version: 20110113215251
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  email              :string(255)
#  encrypted_password :string(255)
#  salt               :string(255)
#  mobile_number      :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  user_type          :string(255)     default("personal")
#  business_name      :string(255)
#  business_category  :string(255)
#


#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  email              :string(255)
#  encrypted_password :string(255)
#  salt               :string(255)
#  mobile_number      :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

require 'digest' # for password encryption
class User < ActiveRecord::Base
  attr_accessor   :password
  attr_accessible :name, :email, :mobile_number, :password, :password_confirmation, :user_type, :business_name, :business_category

  has_many :reservations, :dependent => :destroy
  has_many :reservation_systems, :dependent => :destroy
  has_many :ratings
  has_many :rated_resources, :through => :ratings, :source => :resources

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  mobile_number_regex = /\A[0-9\-()+]+\Z/

  validates :name,  :presence => true,
                    :length => { :within => 2..50 }
  validates :mobile_number, :presence => true,
                            :format => { :with => mobile_number_regex },
                            :uniqueness => true,
                            :length => { :within => 7..50}
  validates :email, :presence => true,
                    :format => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false } 
  validates :password,  :presence => true,
                        :confirmation => true,
                        :length => { :within => 6..40 },
                        :if => Proc.new{new_record? or not ( password=='' or password.nil?)}
  validates :user_type, :inclusion => {:in => %w(personal business) }
  validates_presence_of :business_name, :if => Proc.new {user_type=='business'}  

before_save :encrypt_password

  # Encrypts and checks submitted password against stored encypted password
  def check_password?(submitted_password)
    self.encrypted_password == encrypt(submitted_password)
  end
  
  def User.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil  if user.nil?
    return user if user.check_password?(submitted_password)
  end

  def User.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  private
    def encrypt_password
      self.salt = make_salt if new_record? #create salt only the first time record is created
      self.encrypted_password = encrypt(self.password) unless (self.password.nil? or self.password =='')
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
  
end
