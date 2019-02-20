# run `pod lib lint MastercardOAuth.podspec' to validate before submitting

Pod::Spec.new do |s|
  s.name             = 'MastercardOAuth1Signer'
  s.version          = '1.0.0'
  s.summary          = 'Zero dependency library for generating a Mastercard API compliant OAuth signature'

  s.description      = <<-DESC
Zero dependency library for generating a Mastercard API compliant OAuth signature.
                       DESC

  s.homepage         = 'https://github.com/Mastercard/oauth1-signer-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'lukereichold' => 'luke@reikam.com', 'Mastercard' => '' }
  s.source           = { :git => 'https://github.com/Mastercard/oauth1-signer-swift.git', :tag => s.version.to_s }
  s.swift_version    = '4.2'
  s.ios.deployment_target = '11.0'

  s.source_files = 'MastercardOAuth1Signer/MastercardOAuth1Signer/*.swift'
  s.frameworks = 'Foundation', 'Security'

end
