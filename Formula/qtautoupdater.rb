require_relative "../base/Qtformula"

class Qtautoupdater < Qtformula
	version "3.0.0"
	revision 1
	desc "A Qt library to automatically check for updates and install them"
	homepage "https://github.com/Skycoder42/QtAutoUpdater/"
	url "https://github.com/Skycoder42/QtAutoUpdater/archive/#{version}.tar.gz"
	sha256 "26294429597b85fecaf51eb534edd9898d3652d97262e13a96b3aa346645956b"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on :xcode => :build
	depends_on "qdep" => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def install
		build_and_install_default
		create_mod_pri prefix, "autoupdatercore"
		create_mod_pri prefix, "autoupdaterwidgets"
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
		CONFIG -= app_bundle
		QT += autoupdatercore
		SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
		#include <QtAutoUpdaterCore>
		int main() {
			auto updater = QtAutoUpdater::Updater::create("homebrew");
			return updater != nullptr ? 0 : 1;
		}
		EOS
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end
