require_relative "../base/Qtformula"

class Qtmvvm < Qtformula
	version "1.1.5"
	revision 1
	desc "A mvvm oriented library for Qt, to create Projects for Widgets and Quick in parallel"
	homepage "https://github.com/Skycoder42/QtMvvm"
	url "https://github.com/Skycoder42/QtMvvm/archive/#{version}.tar.gz"
	sha256 "7e95322375c098d4f3de5e49cd5003571a435304ff8504d4b266d7a9fd1dd3f2"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on "qtdatasync" => :recommended
	depends_on :xcode => :build
	depends_on "qdep" => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def install
		prepare_qdep
		if build.with? "qtdatasync"
			add_modules "qtdatasync", "qtjsonserializer"
		end
		build_and_install_default
		create_mod_pri prefix, "mvvmcore"
		create_tool_pri prefix, "qsettingsgenerator"
		create_mod_pri prefix, "mvvmwidgets"
		create_mod_pri prefix, "mvvmquick"
		if build.with? "qtdatasync"
			create_mod_pri prefix, "mvvmdatasynccore"
			create_mod_pri prefix, "mvvmdatasyncwidgets"
			create_mod_pri prefix, "mvvmdatasyncquick"
		end
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
			CONFIG -= app_bundle
			CONFIG += c++14
			QT += mvvmcore
			SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
			#include <QtCore>
			#include <QtMvvmCore>
			int main() {
				QtMvvm::MessageConfig config;
				return 0;
			}
		EOS
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end
