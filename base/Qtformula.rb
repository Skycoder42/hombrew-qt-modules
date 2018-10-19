class Qtformula < Formula	
	def create_qtpath_pri(base)
		File.open("#{base}/mkspecs/modules/brew.pri", "w") { |f|
			f << "QT_MODULE_BIN_BASE = \"#{base}/bin\"\n"
			f << "QT_MODULE_INCLUDE_BASE = \"#{base}/include\"\n"
			f << "QT_MODULE_LIB_BASE = \"#{base}/lib\"\n"
			f << "QT_MODULE_HOST_LIB_BASE = \"#{base}/lib\"\n"
		}
	end
	
	def create_mod_pri(base, mod)
		File.open("#{base}/mkspecs/modules/qt_lib_#{mod}.pri", "w") { |f|
			f << "include($$PWD/brew.pri)\n"
			f << "include($$PWD/../modules-inst/qt_lib_#{mod}.pri)\n"
			f << "QT.#{mod}.priority = 1\n"
		}
		File.open("#{base}/mkspecs/modules/qt_lib_#{mod}_private.pri", "w") { |f|
			f << "include($$PWD/brew.pri)\n"
			f << "include($$PWD/../modules-inst/qt_lib_#{mod}_private.pri)\n"
			f << "QT.#{mod}_private.priority = 1\n"
		}
	end
	
	def create_tool_pri(base, tool)
		File.open("#{base}/mkspecs/modules/qt_tool_#{tool}.pri", "w") { |f|
			f << "QT_TOOL.#{tool}.binary = \"#{base}/bin/#{tool}\"\n"
			f << "QT_TOOL.#{tool}.depends = core\n"
		}
	end
	
	def add_modules(*mods)
		for mod in mods do
			ENV["QMAKEPATH"] = "#{ENV["QMAKEPATH"]}:#{HOMEBREW_PREFIX}/Cellar/#{mod}/#{Formula[mod].pkg_version}"
		end
	end
	
	def build_and_install(*qmake_args)
		Dir.mkdir ".git"
		Dir.mkdir "build"
		Dir.chdir "build"
		
		ENV["QPMX_CACHE_DIR"] = "#{ENV["HOME"]}/.qpmx-cache"
		system "mkdir", "-p", "#{ENV["QPMX_CACHE_DIR"]}"
		
		system "qmake", qmake_args, ".."
		system "make", "qmake_all"
		system "make"
		system "make", "lrelease"
		
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
		
		#create bash src
		File.open("#{prefix}/bashrc.sh", "w") { |f|
			f << "export QMAKEPATH=$QMAKEPATH:#{prefix}\n\n"
			f << "echo 'WARNING: In order to find eventual plugins, you must export QT_PLUGIN_PATH before running an application built against this library'\n"
		}
	end
	
	def build_and_install_default
		build_and_install "CONFIG+=release"
	end
end
