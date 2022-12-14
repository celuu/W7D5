class User < ApplicationRecord

    validates :username, :password_digest, :session_token, presence: true
    validates :username, :session_token, uniqueness: true
    validates :password, length:{minimum: 6}, allow_nil: true

    before_validation :ensure_session_token

    attr_reader :password

    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)
        if user && user.is_password?(password)
            return user
        else
            return nil
        end
    end

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password)
    end

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end


    def reset_session_token!
        self.session_token = generate_session_token
        self.save
        self.session_token
    end

    def ensure_session_token
        self.session_token ||= generate_session_token
    end

    def generate_session_token
        session_token = SecureRandom::urlsafe_base64
        while User.exists?(session_token: session_token)
            session_token = SecureRandom::urlsafe_base64
        end
        session_token
    end

end
