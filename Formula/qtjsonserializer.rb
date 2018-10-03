class Qtjsonserializer < Formula
	version "3.2.0"
	revision 1
	desc "A library to perform generic seralization and deserialization of QObjects"
	homepage "https://skycoder42.github.io/QtJsonSerializer/"
	url "https://github.com/Skycoder42/QtJsonSerializer/archive/#{version}.tar.gz"
	sha256 "3b0f1b339c6c26b1c8781364269405158b86faa64c765da388c5d01bb3441c82"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on :xcode => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def create_qtpath_pri(base)
		File.open("#{base}/mkspecs/modules/brew.pri", "w") { |f|
			f << "QT_MODULE_BIN_BASE = \"#{base}/bin\""
			f << "QT_MODULE_INCLUDE_BASE = \"#{base}/include\""
			f << "QT_MODULE_LIB_BASE = \"#{base}/lib\""
			f << "QT_MODULE_HOST_LIB_BASE = \"#{base}/lib\""
		}
	end
	
	def create_mod_pri(base, mod)
		File.open("#{base}/mkspecs/modules/qt_lib_#{mod}.pri", "w") { |f|
			f << "include($$PWD/brew.pri)"
			f << "include($$PWD/../modules-inst/qt_lib_#{mod}.pri)"
			f << "QT.#{mod}.priority = 1"
		}
		File.open("#{base}/mkspecs/modules/qt_lib_#{mod}_private.pri", "w") { |f|
			f << "include($$PWD/brew.pri)"
			f << "include($$PWD/../modules-inst/qt_lib_#{mod}_private.pri)"
			f << "QT.#{mod}_private.priority = 1"
		}
	end
	
	def create_tool_pri(base, tool)
		File.open("#{base}/mkspecs/modules/qt_tool_#{tool}.pri", "w") { |f|
			f << "QT_TOOL.#{tool}.binary = \"#{base}/bin/#{tool}\""
			f << "QT_TOOL.#{tool}.depends = core"
		}
	end
	
	def install
		Dir.mkdir ".git"
		Dir.mkdir "build"
		Dir.chdir "build"
		system "qmake", "CONFIG+=release", ".."
		system "make", "qmake_all"
		system "make"
		
		if build.with? "docs"
			system "make", "doxygen"
		end
		
		instdir = "#{buildpath}/install"
		system "make", "INSTALL_ROOT=#{instdir}", "install"
		prefix.install Dir["#{instdir}#{HOMEBREW_PREFIX}/Cellar/qt/#{Formula["qt"].pkg_version}/*"]
		
		# overwrite pri include
		FileUtils.mv "#{prefix}/mkspecs/modules", "#{prefix}/mkspecs/modules-inst"
		Dir.mkdir "#{prefix}/mkspecs/modules"
		create_qtpath_pri prefix
		create_mod_pri prefix, "jsonserializer"
		
		#create bash src
		File.open("#{prefix}/bashrc.sh", "w") { |file| file << "export QMAKEPATH=$QMAKEPATH:#{prefix}" }
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
