require_relative "../base/Qtformula"

class Qtdatasync < Qtformula
	version "4.2.2"
	revision 1
	desc "A simple offline-first synchronisation framework, to synchronize data of Qt applications between devices"
	homepage "https://github.com/Skycoder42/QtDataSync"
	url "https://github.com/Skycoder42/QtDataSync/archive/#{version}.tar.gz"
	sha256 "eeb2a7cbc0d781bed363cd85edd75e23b8b27f9a7482138ba88dd1d818939029"
	
	keg_only "Qt itself is keg only which implies the same for Qt modules"
	
	option "with-docs", "Build documentation"
	
	patch :DATA
	patch :p0, :DATA
	
	depends_on "qt"
	depends_on "qtjsonserializer"
	depends_on "qtservice"
	depends_on "cryptopp"
	depends_on :xcode => :build
	depends_on "pkg-config" => :build
	depends_on "qdep" => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]
	depends_on "graphviz" => [:build, "with-docs"]
	
	def install
		# create cryptopp pkgconfig
		Dir.mkdir "pkgconfig"
		File.open("pkgconfig/libcrypto++.pc", "w") do |pcfile|
			pcfile.write("prefix=#{HOMEBREW_PREFIX}/Cellar/cryptopp/#{Formula["cryptopp"].pkg_version}\n")
			pcfile.write("libdir=${prefix}/lib\n")
			pcfile.write("includedir=${prefix}/include\n")
			pcfile.write("Name: libcrypto++-#{Formula["cryptopp"].pkg_version}\n")
			pcfile.write("Description: Class library of cryptographic schemes\n")
			pcfile.write("Version: #{Formula["cryptopp"].pkg_version}\n")
			pcfile.write("Libs: -L${libdir} -lcryptopp\n")
			pcfile.write("Cflags: -I${includedir} \n")
		end
		ENV["PKG_CONFIG_PATH"] = "#{Dir.pwd}/pkgconfig:#{ENV["PKG_CONFIG_PATH"]}"
		
		# enforce system cryptopp
		File.open(".qmake.conf", "a") do |conffile|
			conffile.write("CONFIG += system_cryptopp\n")
		end
		
		# build and install (with system_cryptopp)
		prepare_qdep
		add_modules "qtjsonserializer", "qtservice"
		build_and_install_default
		create_mod_pri prefix, "datasync"
	end
	
	test do
		(testpath/"test.pro").write <<~EOS
			CONFIG -= app_bundle
			CONFIG += c++14
			QT += datasync
			SOURCES += main.cpp
		EOS
		
		(testpath/"main.cpp").write <<~EOS
			#include <QtCore>
			#include <QtDataSync>
			int main() {
				QtDataSync::Setup s;
				return 0;
			}
		EOS
		
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}"
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{HOMEBREW_PREFIX}/Cellar/qtjsonserializer/#{Formula["qtjsonserializer"].pkg_version}"
		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{HOMEBREW_PREFIX}/Cellar/qtservice/#{Formula["qtservice"].pkg_version}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end

__END__
diff --git a/tools/appserver/appserver.pro b/tools/appserver/appserver.pro
index b9580a7..f15d2e4 100644
--- a/tools/appserver/appserver.pro
+++ b/tools/appserver/appserver.pro
@@ -48,10 +48,7 @@ DISTFILES += $$SVC_CONFIG_FILES \
		
include(../../src/messages/messages.pri)

-osx:!debug_and_release {
	-	CONFIG(release, debug|release): QDEP_LINK_DEPENDS = ../../src/messages/release/messages.pro
-	else:CONFIG(debug, debug|release): QDEP_LINK_DEPENDS = ../../src/messages/debug/messages.pro
-} else: QDEP_LINK_DEPENDS += ../../src/messages
+QDEP_LINK_DEPENDS += ../../src/messages

win32 {
	QMAKE_TARGET_PRODUCT = "Qt Datasync Server"
