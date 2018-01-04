class Qtbackgroundprocess < Formula
	version "1.6.0-3"
	desc "A Library to create background applications with simple, automated foreground control"
	homepage "https://skycoder42.github.io/QtBackgroundProcess/"
	url "https://github.com/Skycoder42/QtBackgroundProcess/archive/#{version}.tar.gz"
	sha256 "4461bd8c1935650ad22ac05dff2a34bb41910b6dc25c36f74cd19decaba04b34"

	keg_only "Qt itself is keg only which implies the same for Qt modules"

	option "with-docs", "Build documentation"

	depends_on "qt"
	depends_on :xcode => :build
	depends_on "python3" => [:build, "with-docs"]
	depends_on "doxygen" => [:build, "with-docs"]

	def file_replace(file, base, suffix)
		text = File.read(file)
		replace = text.gsub(base, "#{base}/../../../qtbackgroundprocess/#{version}/#{suffix}")
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
		file_replace "#{prefix}/mkspecs/modules/qt_lib_backgroundprocess.pri", "QT_MODULE_LIB_BASE", "lib"
		file_replace "#{prefix}/mkspecs/modules/qt_lib_backgroundprocess.pri", "QT_MODULE_BIN_BASE", "bin"
		file_replace "#{prefix}/mkspecs/modules/qt_lib_backgroundprocess_private.pri", "QT_MODULE_LIB_BASE", "lib"

		#create bash src
		File.open("#{prefix}/bashrc.sh", "w") { |file| file << "export QMAKEPATH=$QMAKEPATH:#{prefix}" }
	end

	test do
		(testpath/"test.pro").write <<~EOS
		CONFIG -= app_bundle
		QT += backgroundprocess
		SOURCES += main.cpp
		EOS

		(testpath/"main.cpp").write <<~EOS
		#include <QtCore>
		#include <QtBackgroundProcess>
		int main() {
			QtBackgroundProcess::App a(argc, argv);
			qDebug() << a.instanceID();
			return 0;
		}
		EOS

		ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{prefix}"
		system "#{Formula["qt"].bin}/qmake", "test.pro"
		system "make"
		system "./test"
	end
end
