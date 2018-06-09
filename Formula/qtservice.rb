class Qtservice < Formula
	version "1.0.0"
	revision 1
	desc "A platform independent library to easily create system services and use some of their features"
	homepage "https://github.com/Skycoder42/QtService"
	url "https://github.com/Skycoder42/QtService/archive/#{version}.tar.gz"
	sha256 "f941ae4a009b6a957bf1b2d951d49bdd49a541a421158ac647e0021c018b85f7"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on :xcode => :build
	depends_on "qpmx" => :build
	depends_on "qpm" => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def file_replace(file, base, suffix)
		text = File.read(file)
		replace = text.gsub(base, "#{base}/../../../qtservice/#{pkg_version}/#{suffix}")
		File.open(file, "w") { |f| f << replace }
	end
	
	def install		
		Dir.mkdir ".git"
		Dir.mkdir "build"
		Dir.chdir "build"
		
		ENV["QPMX_CACHE_DIR"] = "#{ENV["HOME"]}/qpmx-cache"
		system "mkdir", "-p", "#{ENV["QPMX_CACHE_DIR"]}"
		system "qmake", "-config", "release", ".."
		system "make", "qmake_all"
		system "make"
		system "make", "lrelease"
		
		if build.with? "docs"
			system "make", "doxygen"
		end
		
		# ENV.deparallelize
		instdir = "#{buildpath}/install"
		system "make", "INSTALL_ROOT=#{instdir}", "install"
		prefix.install Dir["#{instdir}#{HOMEBREW_PREFIX}/Cellar/qt/#{Formula["qt"].pkg_version}/*"]
		
		# overwrite pri include
		file_replace "#{prefix}/mkspecs/modules/qt_lib_service.pri", "QT_MODULE_LIB_BASE", "lib"
		file_replace "#{prefix}/mkspecs/modules/qt_lib_service.pri", "QT_MODULE_BIN_BASE", "bin"
		file_replace "#{prefix}/mkspecs/modules/qt_lib_service_private.pri", "QT_MODULE_LIB_BASE", "lib"
		
		#create bash src
		File.open("#{prefix}/bashrc.sh", "w") { |file|
			file << "export QMAKEPATH=$QMAKEPATH:#{prefix}"
			file << ""
			file << "echo WARNING: In order to find the service plugins, you must export QT_PLUGIN_PATH before running an application built against QtService"
		}
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
		system "./test"
	end
end
