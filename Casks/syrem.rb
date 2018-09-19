cask 'syrem' do
  version '3.0.0'
  url "https://github.com/Skycoder42/Syrem/releases/download/#{version}/syrem-#{version}_clang_64.dmg"
  sha256 '7b54529cd00332e423839cf768b732ac6c42e17de9325d0a093764180deeb611'
  appcast 'https://github.com/Skycoder42/Syrem/releases.atom'
  
  name 'Syrem'
  homepage 'https://github.com/Skycoder42/Syrem'
  app 'Syrem.app'
end
