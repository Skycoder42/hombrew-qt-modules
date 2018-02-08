class Qtdatasync < Formula
	version "4.0.0"
	revision 1
	desc "A simple offline-first synchronisation framework, to synchronize data of Qt applications between devices"
	homepage "https://github.com/Skycoder42/QtDataSync"
	url "https://github.com/Skycoder42/QtDataSync/archive/#{version}.tar.gz"
	sha256 "543e6f51ec22ae045a2c61ea1952d406d587b2ef186426cd29f65e3ee9b80d85"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	depends_on "qt"
	depends_on "qtjsonserializer"
	depends_on "cryptopp"
	depends_on :xcode => :build
	depends_on "pkg-config" => :build
	depends_on "qpmx" => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def file_replace(file, base, suffix)
		text = File.read(file)
		replace = text.gsub(base, "#{base}/../../../qtdatasync/#{pkg_version}/#{suffix}")
		File.open(file, "w") { |f| f << replace }
	end
	
	def install
		Dir.mkdir ".git"
		Dir.mkdir "build"
		Dir.chdir "build"
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{HOMEBREW_PREFIX}/Cellar/qtjsonserializer/#{Formula["qtjsonserializer"].pkg_version}"
		ENV["QPMX_CACHE_DIR"] = "#{ENV["HOME"]}/qpmx-cache"
		system "echo", "#{ENV["QPMX_CACHE_DIR"]}"
		system "mkdir", "-p", "#{ENV["QPMX_CACHE_DIR"]}"
		system "qmake", "CONFIG+=system_cryptopp", "-config", "release", ".."
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
		file_replace "#{prefix}/mkspecs/modules/qt_lib_datasync.pri", "QT_MODULE_LIB_BASE", "lib"
		file_replace "#{prefix}/mkspecs/modules/qt_lib_datasync.pri", "QT_MODULE_BIN_BASE", "bin"
		file_replace "#{prefix}/mkspecs/modules/qt_lib_datasync_private.pri", "QT_MODULE_LIB_BASE", "lib"
		
		#create bash src
		File.open("#{prefix}/bashrc.sh", "w") { |file| 
			file << ""
			file << "echo WARNING: In order to find the keystore plugins, you must export PLUGIN_KEYSTORES_PATH before running an application built against datasync"
		}
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
			CONFIG -= app_bundle
			QT += datasync
			SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
			#include <QtCore>
			#include <QtDataSync>
			int main() {
				QtRestClient::Setup s;
				return 0;
			}
		EOS
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}:#{HOMEBREW_PREFIX}/Cellar/qtjsonserializer/#{Formula["qtjsonserializer"].pkg_version}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end
