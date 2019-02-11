require_relative "../base/Qtformula"

class Qtrestclient < Qtformula
	version "2.1.1"
	revision 1
	desc "A library for generic JSON-based REST-APIs, with a mechanism to map JSON to Qt objects"
	homepage "https://github.com/Skycoder42/QtRestClient/"
	url "https://github.com/Skycoder42/QtRestClient/archive/#{version}.tar.gz"
	sha256 "7c43acfbf77b46968503759fd5d381098b17494c105dced252abe4673a2be1d5"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on "qtjsonserializer"
	depends_on :xcode => :build
	depends_on "qdep" => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def install
		add_modules "qtjsonserializer"
		build_and_install_default
		create_mod_pri prefix, "restclient"
		create_tool_pri prefix, "qrestbuilder"
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
		CONFIG -= app_bundle
		QT += restclient
		SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
		#include <QtCore>
		#include <QtRestClient>
		int main() {
			QtRestClient::RestClient r;
			qDebug() << r.serializer();
			return 0;
		}
		EOS
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}:#{HOMEBREW_PREFIX}/Cellar/qtjsonserializer/#{Formula["qtjsonserializer"].pkg_version}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end
