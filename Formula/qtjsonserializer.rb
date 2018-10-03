require_relative "../base/Qtformula"

class Qtjsonserializer < Qtformula
	version "3.2.0"
	revision 1
	desc "A library to perform generic seralization and deserialization of QObjects"
	homepage "https://skycoder42.github.io/QtJsonSerializer/"
	url "https://github.com/Skycoder42/QtJsonSerializer/archive/#{version}.tar.gz"
	sha256 "3b0f1b339c6c26b1c8781364269405158b86faa64c765da388c5d01bb3441c82"
	
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
