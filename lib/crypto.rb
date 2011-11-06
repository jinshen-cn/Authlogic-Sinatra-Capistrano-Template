require 'base64'
require 'openssl'

module Crypto
  def self.decrypt( cipherBase64 )
      cipher = Base64.decode64( cipherBase64 )

      aes = OpenSSL::Cipher::Cipher.new( "aes-128-cbc" ).decrypt
      aes.iv = cipher.slice( 0, 16 )
      # don't slice the SHA256 output for AES256
      aes.key = ( Digest::SHA256.digest( 'YourKey' ) ).slice( 0, 16 )

      cipher = cipher.slice( 16..-1 )

      return aes.update( cipher ) + aes.final
  end
end