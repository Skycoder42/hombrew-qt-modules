class Qdep < Formula
	include Language::Python::Virtualenv
	
	version "1.0.1"
	revision 1
	desc "A very basic yet simple to use dependency management tool for qmake based projects"
	homepage "https://github.com/Skycoder42/qdep"
	url "https://github.com/Skycoder42/qdep/archive/#{version}.tar.gz"
	sha256 "e5a94160e60f4d0dee2ec62ed1fe1925739793868f6aac1a94d124d683a99c83"
	
	depends_on "python3"
	
	### setup_requires dependencies	
	resource "lockfile" do
		url "https://files.pythonhosted.org/packages/17/47/72cb04a58a35ec495f96984dddb48232b551aafb95bde614605b754fe6f7/lockfile-0.12.2.tar.gz"
		sha256 "6aed02de03cba24efabcd600b30540140634fc06cfa603822d508d5361e9f799"
	end
	
	resource "argcomplete" do
		url "https://files.pythonhosted.org/packages/3c/21/9741e5e5e63245a8cdafb32ffc738bff6e7ef6253b65953e77933e56ce88/argcomplete-1.9.4.tar.gz"
		sha256 "06c8a54ffaa6bfc9006314498742ec8843601206a3b94212f82657673662ecf1"
	end
	
	resource "appdirs" do
		url "https://files.pythonhosted.org/packages/48/69/d87c60746b393309ca30761f8e2b49473d43450b150cb08f3c6df5c11be5/appdirs-1.4.3.tar.gz"
		sha256 "9e5896d1372858f8dd3344faf4e5014d21849c756c8d5701f78f8a103b372d92"
	end
	
	def install
		virtualenv_install_with_resources
	end
	
	test do
		system "qdep", "--version"
	end
end
