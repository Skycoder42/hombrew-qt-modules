require_relative "../base/Qtformula"

class Qtjsonserializer < Qtformula
	version "4.0.2"
	revision 1
	desc "A library to perform generic seralization and deserialization of QObjects"
	homepage "https://github.com/Skycoder42/QtJsonSerializer/"
	url "https://github.com/Skycoder42/QtJsonSerializer/archive/#{version}.tar.gz"
	sha256 "17800689d81313265afeee982ecd8d2b1f86a8643361e8dea3d921a42647b5c3"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on :xcode => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def install
		build_and_install_default
		create_mod_pri prefix, "jsonserializer"
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
		CONFIG -= app_bundle
		CONFIG += c++17
		QMAKE_MACOSX_DEPLOYMENT_TARGET = 10.14
		QT += jsonserializer
		SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
		#include <QtCore>
		#include <QtJsonSerializer>
		int main() {
			QtJsonSerializer::JsonSerializer s;
			s.serialize<int>(42);
			return 0;
		}
		EOS
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end
