class Qpmx < Formula
	desc "A frontend for qpm, to provide source and build caching"
	homepage "https://github.com/Skycoder42/qpmx"
	version "1.3.0"
	url "https://github.com/Skycoder42/qpmx/archive/#{version}.tar.gz"
	sha256 "d153308bc224ffc294429d274561436b1d19bc19286b3dd91136e128cd66e6ca"
	
	resource "qcliparser" do
		url "https://github.com/Skycoder42/QCliParser/archive/1.0.0.tar.gz"
		sha256 "043c0366c318243a3a32cde30942331b14685737b5174eb67b4d8c7cbe53d399"
	end
	
	depends_on "qt"
	depends_on "qtjsonserializer"
	depends_on :xcode => :build
	
	def install
		resource("qcliparser").stage { (buildpath/"submodules/qcliparser").install Dir["*"] }
		
		open(".qmake.conf", 'a') { |f|
			f.puts "CONFIG += no_installer"
		}
		Dir.mkdir "build"
		Dir.chdir "build"
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{HOMEBREW_PREFIX}/Cellar/qtjsonserializer/#{Formula["qtjsonserializer"].pkg_version}"
		system "qmake", "-config", "release", ".."
		system "make", "qmake_all"
		system "make"
		
		# ENV.deparallelize
		instdir = "#{buildpath}/install"
		system "make", "INSTALL_ROOT=#{instdir}", "install"
		prefix.install Dir["#{instdir}#{HOMEBREW_PREFIX}/Cellar/qt/#{Formula["qt"].pkg_version}/*"]
		
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
