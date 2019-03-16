require_relative "../base/Qtformula"

class Qtjsonserializer < Qtformula
	version "3.3.1"
	revision 1
	desc "A library to perform generic seralization and deserialization of QObjects"
	homepage "https://github.com/Skycoder42/QtJsonSerializer/"
	url "https://github.com/Skycoder42/QtJsonSerializer/archive/#{version}.tar.gz"
	sha256 "bfca092fac62980aa07c711b7ea836ad7f2cb55b4c80fc3e0af8b9579abf8db6"
	
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
		QT += jsonserializer
		SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
		#include <QtCore>
		#include <QtJsonSerializer>
		int main() {
			QJsonSerializer s;
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
