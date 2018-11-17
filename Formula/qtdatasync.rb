require_relative "../base/Qtformula"

class Qtdatasync < Qtformula
	version "4.2.0"
	revision 1
	desc "A simple offline-first synchronisation framework, to synchronize data of Qt applications between devices"
	homepage "https://github.com/Skycoder42/QtDataSync"
	url "https://github.com/Skycoder42/QtDataSync/archive/#{version}.tar.gz"
	sha256 "4f91246dfc702ef69fa08a827f1f4af76551a1d4921e916d261f637fea422183"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on "qtjsonserializer"
	depends_on "qtservice"
	depends_on "cryptopp"
	depends_on :xcode => :build
	depends_on "qpmx" => :build
	depends_on "qpm" => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def install
		# mangle in cryptopp
		FileUtils.ln_s "#{HOMEBREW_PREFIX}/Cellar/cryptopp/#{Formula["cryptopp"].pkg_version}/lib", "src/3rdparty/cryptopp/lib"
		FileUtils.ln_s "#{HOMEBREW_PREFIX}/Cellar/cryptopp/#{Formula["cryptopp"].pkg_version}/include", "src/3rdparty/cryptopp/include"
#		# fix keychain config
# 		File.open("src/plugins/keystores/keystores.pro", "r") do |orig|
# 			File.unlink("src/plugins/keystores/keystores.pro")
# 			File.open("src/plugins/keystores/keystores.pro", "w") do |new|
# 				new.write "keychain.CONFIG += no_lrelease_target\n"
# 				new.write(orig.read())
# 			end
# 		end
		
		# build and install
		add_modules "qtjsonserializer", "qtservice"
		build_and_install_default
		create_mod_pri prefix, "datasync"
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
			CONFIG -= app_bundle
			CONFIG += c++14
			QT += datasync
			SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
			#include <QtCore>
			#include <QtDataSync>
			int main() {
				QtDataSync::Setup s;
				return 0;
			}
		EOS
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}"
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{HOMEBREW_PREFIX}/Cellar/qtjsonserializer/#{Formula["qtjsonserializer"].pkg_version}"
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{HOMEBREW_PREFIX}/Cellar/qtservice/#{Formula["qtservice"].pkg_version}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end
