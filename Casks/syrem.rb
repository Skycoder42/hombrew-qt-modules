cask 'syrem' do
  version '3.0.0'
  revision 2
  url "https://github.com/Skycoder42/Syrem/releases/download/#{version}/syrem-#{version}_clang_64.dmg"
  sha256 '8818373ae1c4eff1fee9fc76a6c5cb7b0d83eb558325fc5e81bb478fb600b7fe'
  appcast 'https://github.com/Skycoder42/Syrem/releases.atom'
  
  name 'Syrem'
  homepage 'https://github.com/Skycoder42/Syrem'
  app 'Syrem.app'
end
