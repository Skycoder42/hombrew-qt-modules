class Qpmx < Formula
	desc "A frontend for qpm, to provide source and build caching"
	homepage "https://github.com/Skycoder42/qpmx"
	version "1.6.0"
	revision 1
	url "https://github.com/Skycoder42/qpmx/archive/#{version}.tar.gz"
	sha256 "b4a72af6542118b4d46f9840f26a95dfa3c9a19a340f9c901af1a60d1230e482"
	
	resource "deployment" do
		url "https://github.com/Skycoder42/deployment/archive/brew-1.tar.gz"
		sha256 "914acbb92d59f670c5fd06733a2580ba022e8a0984d02701683e76d5d9925ba6"
	end
	
	resource "qcliparser" do
		url "https://github.com/Skycoder42/QCliParser/archive/1.0.1.tar.gz"
		sha256 "713b20ccd4fe89ea663da142e1c4c2550b6e86f425b94552b638f97ff8785ae2"
	end
	
	resource "qctrlsignals" do
		url "https://github.com/Skycoder42/QCtrlSignals/archive/1.1.2.tar.gz"
		sha256 "78776be603687a2b36bf4ad8ea68d8b4e888635e185de05231b6f01f0eb7da91"
	end
	
	resource "qpluginfactory" do
		url "https://github.com/Skycoder42/QPluginFactory/archive/1.3.1.tar.gz"
		sha256 "5721041e82941a5894034626cbc16b247bf8fd8a11743bbf4488dd535e31b0a1"
	end
	
	resource "qtcoroutines" do
		url "https://github.com/Skycoder42/QtCoroutines/archive/1.1.0.tar.gz"
		sha256 "df00ab356718e61ed980b36330b17f6617c91440a13c99e16d12e67db168161f"
	end
	
	depends_on "qt"
	depends_on "qtjsonserializer"
	depends_on :xcode => :build
	depends_on "qpm" => :recommended
	depends_on "qbs" => :optional
	
	def install
		resource("deployment").stage { (buildpath/"submodules/deployment").install Dir["*"] }
		resource("qcliparser").stage { (buildpath/"submodules/qcliparser").install Dir["*"] }
		resource("qctrlsignals").stage { (buildpath/"submodules/qctrlsignals").install Dir["*"] }
		resource("qpluginfactory").stage { (buildpath/"submodules/qpluginfactory").install Dir["*"] }
		resource("qtcoroutines").stage { (buildpath/"submodules/qtcoroutines").install Dir["*"] }
		
		Dir.mkdir "build"
		Dir.chdir "build"
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{HOMEBREW_PREFIX}/Cellar/qtjsonserializer/#{Formula["qtjsonserializer"].pkg_version}"
		system "qmake", "-config", "release", "PREFIX=/", ".."
		system "make", "qmake_all"
		system "make"
		
		# ENV.deparallelize
		instdir = "#{buildpath}/install"
		system "make", "INSTALL_ROOT=#{instdir}", "install"
		prefix.install Dir["#{instdir}/*"]
		
		# adjust qt.conf
		open(prefix/"bin/qt.conf", 'w') { |f|
			f.puts "[Paths]"
			f.puts "Prefix=#{HOMEBREW_PREFIX}/Cellar/qt/#{Formula["qt"].pkg_version}"
			f.puts "Plugins=#{prefix}/plugins"
		}
	end
	
	test do
		providers=`#{prefix}/bin/qpmx list providers --short`
		prov=providers.strip.split(/ /)
		return (prov.include? "git") && (prov.include? "qpm")
	end
end
