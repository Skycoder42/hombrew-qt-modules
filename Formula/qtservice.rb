require_relative "../base/Qtformula"

class Qtservice < Qtformula
	version "1.1.0"
	revision 1
	desc "A platform independent library to easily create system services and use some of their features"
	homepage "https://github.com/Skycoder42/QtService"
	url "https://github.com/Skycoder42/QtService/archive/#{version}.tar.gz"
	sha256 "26197b596543ac9233f3afb280f9b214953c51e22de3a0b8aa96c25dcc05cf4d"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on :xcode => :build
	depends_on "qpmx" => :build
	depends_on "qpm" => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def install
		build_and_install_default
		create_mod_pri prefix, "service"
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
			CONFIG -= app_bundle
			CONFIG += c++14
			QT += service
			SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
			#include <QtCore>
			#include <QtService>
			int main(int argc, char *argv[]) {
				QCoreApplication app(argc, argv);
				auto control = QtService::ServiceControl::create("standard", "test", nullptr);
				return 0;
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
