cask 'kptransfer' do
  version '3.0.0'
  url "https://github.com/Skycoder42/KeepassTransfer/releases/download/#{version}/kptransfer-#{version}_clang_64.dmg"
  sha256 '997d0654288b9e69b289fda1529ed35eb8df0b141b599c00520bf379ea15b214'
  appcast 'https://github.com/Skycoder42/KeepassTransfer/releases.atom'
  
  name 'KeePass-Transfer'
  homepage 'https://github.com/Skycoder42/KeepassTransfer'
  app 'KeePass-Transfer.app'
end
