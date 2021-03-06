require_relative "../base/Qtformula"

class Qtautoupdater < Qtformula
	version "3.0.0"
	revision 3
	desc "A Qt library to automatically check for updates and install them"
	homepage "https://github.com/Skycoder42/QtAutoUpdater/"
	url "https://github.com/Skycoder42/QtAutoUpdater/archive/#{version}-3.tar.gz"
	sha256 "14041ec32920c2e561897c6d4db2b238aabc1c259ed0e92f51dedcd18be6627d"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on :xcode => :build
	depends_on "qdep" => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def install
		prepare_qdep
		build_and_install_default
		create_mod_pri prefix, "autoupdatercore"
		create_mod_pri prefix, "autoupdaterwidgets"
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
			CONFIG -= app_bundle
			CONFIG += c++17
			QT += autoupdatercore
			SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
			#include <QtAutoUpdaterCore>
			int main(int argc, char *argv[]) {
				QCoreApplication app(argc, argv);
				qDebug() << QtAutoUpdater::Updater::supportedUpdaterBackends();
				auto updater = QtAutoUpdater::Updater::create("homebrew", {
					{"packages", "qtautoupdater"}
				});
				return updater != nullptr ? 0 : 1;
			}
		EOS
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		
		ENV["QT_PLUGIN_PATH"] = "#{ENV["QT_PLUGIN_PATH"]}:#{prefix}/plugins"
		ENV["DYLD_LIBRARY_PATH"] = "#{ENV["DYLD_FRAMEWORK_PATH"]}:#{prefix}/lib"
		ENV["DYLD_FRAMEWORK_PATH"] = "#{ENV["DYLD_FRAMEWORK_PATH"]}:#{prefix}/lib"
		system "./test"
	end
end
