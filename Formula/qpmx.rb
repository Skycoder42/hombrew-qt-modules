class Qpmx < Formula
	desc "A frontend for qpm, to provide source and build caching"
	homepage "https://github.com/Skycoder42/qpmx"
	version "1.5.0"
	revision 1
	url "https://github.com/Skycoder42/qpmx/archive/#{version}.tar.gz"
	sha256 "efa92bce06bbc813ccd56b6b16d3b4d79af988e6e8c28304ccdf635069aa050d"
	
	resource "qcliparser" do
		url "https://github.com/Skycoder42/QCliParser/archive/1.0.1.tar.gz"
		sha256 "713b20ccd4fe89ea663da142e1c4c2550b6e86f425b94552b638f97ff8785ae2"
	end
	
	depends_on "qt"
	depends_on "qtjsonserializer"
	depends_on :xcode => :build
	depends_on "qpm" => :recommended
	depends_on "qbs" => :optional
	
	def install
		resource("qcliparser").stage { (buildpath/"submodules/qcliparser").install Dir["*"] }
		
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
