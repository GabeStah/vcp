Rails.application.config.middleware.use OmniAuth::Builder do
  provider :bnet, 'rrs7u8pftmn5tt6r7wg7benc8aywe7gz', '6GaRZqtHT8HCS2tXW83dqKmYcBK9HsAq', scope: "wow.profile sc2.profile"
end