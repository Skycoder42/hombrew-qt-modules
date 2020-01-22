require_relative "../base/Qtformula"

class Qtapng < Qtformula
	version "1.1.2"
	revision 1
	desc "An apng image plugin for Qt to support animated PNGs"
	homepage "https://github.com/Skycoder42/QtApng"
	url "https://github.com/Skycoder42/QtApng/archive/#{version}.tar.gz"
	sha256 "d985540ea83b8944e514151cdc15acf4db0dce77895c2697053974817ed1bc03"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on :xcode => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def install
		build_and_install_default
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
		CONFIG -= app_bundle
		CONFIG += c++17
		QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.14
		QT = core gui
		SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
		#include <QtGui/QtGui>
		int main(int argc, char **argv) {
			QGuiApplication a(argc, argv);
			Q_ASSERT(QImageReader::supportedImageFormats().contains("apng"));
			Q_ASSERT(QMovie::supportedFormats().contains("apng"));
			return 0;
		}
		EOS
		
		ENV["QT_PLUGIN_PATH"] = "#{ENV["QT_PLUGIN_PATH"]}:#{prefix}/plugins"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end
