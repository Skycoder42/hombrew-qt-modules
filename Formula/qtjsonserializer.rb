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
	
	def file_replace(file, base, suffix)
		text = File.read(file)
		replace = text.gsub(base, "#{base}/../../../qtjsonserializer/#{pkg_version}/#{suffix}")
		File.open(file, "w") { |f| f << replace }
	end
	
	def install
		Dir.mkdir ".git"
		Dir.mkdir "build"
		Dir.chdir "build"
		system "qmake", "-config", "release", ".."
		system "make", "qmake_all"
		system "make"
		
		if build.with? "docs"
			system "make", "doxygen"
		end
		
		# ENV.deparallelize
		instdir = "#{buildpath}/install"
		system "make", "INSTALL_ROOT=#{instdir}", "install"
		prefix.install Dir["#{instdir}#{HOMEBREW_PREFIX}/Cellar/qt/#{Formula["qt"].pkg_version}/*"]
		
		# overwrite pri include
		file_replace "#{prefix}/mkspecs/modules/qt_lib_jsonserializer.pri", "QT_MODULE_LIB_BASE", "lib"
		file_replace "#{prefix}/mkspecs/modules/qt_lib_jsonserializer.pri", "QT_MODULE_BIN_BASE", "bin"
		file_replace "#{prefix}/mkspecs/modules/qt_lib_jsonserializer_private.pri", "QT_MODULE_LIB_BASE", "lib"
		
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
			qDebug() << s.serialize<int>(42);
			return 0;
		}
		EOS
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end
