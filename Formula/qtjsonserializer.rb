class Qtjsonserializer < Formula
  desc "A library to perform generic seralization and deserialization of QObjects"
  homepage "https://skycoder42.github.io/QtJsonSerializer/"
  url "https://github.com/Skycoder42/QtJsonSerializer/archive/3.0.0-2.tar.gz"
  sha256 "06972179e1e986e8c2a0ab0d823221b039ba9d0bbb3d08d2e00e28131c869b24"
  version "3.0.0-2"

  depends_on "qt"
  depends_on "python3" => :build
  depends_on "doxygen" => :build

  def file_replace(file, base, suffix)
    text = File.read(file)
    replace = text.gsub(base, "#{base}/../../../qtjsonserializer/#{version}/#{suffix}")
    File.open(file, "w") { |f| f << replace }
  end

  def install
    Dir.mkdir ".git"
    Dir.mkdir "build"
    Dir.chdir "build"
    system "qmake", "-config", "release", ".."
    system "make", "qmake_all"
    system "make"
    system "make", "doxygen"

    # ENV.deparallelize
    instdir = "#{buildpath}/install"
    system "make", "INSTALL_ROOT=#{instdir}", "install"
    prefix.install Dir["#{instdir}#{HOMEBREW_PREFIX}/Cellar/qt/5.9.2/*"]

    # overwrite pri include
    file_replace "#{prefix}/mkspecs/modules/qt_lib_jsonserializer.pri", "QT_MODULE_LIB_BASE", "lib"
    file_replace "#{prefix}/mkspecs/modules/qt_lib_jsonserializer.pri", "QT_MODULE_BIN_BASE", "bin"
    file_replace "#{prefix}/mkspecs/modules/qt_lib_jsonserializer_private.pri", "QT_MODULE_LIB_BASE", "lib"

    #create bash src
    File.open("#{prefix}/bashrc.sh", "w") { |file| file << "export QMAKEPATH=$QMAKEPATH:#{prefix}" }
    FileUtils.chmod 0755, "#{prefix}/bashrc.sh"
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
