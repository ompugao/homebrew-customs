require 'formula'

class Tmux < Formula
  homepage 'http://tmux.sourceforge.net'
  url 'https://downloads.sourceforge.net/project/tmux/tmux/tmux-1.9/tmux-1.9a.tar.gz'
  sha1 '815264268e63c6c85fe8784e06a840883fcfc6a2'

  bottle do
    cellar :any
    revision 1
    sha1 "5a5e180e33339671bc8c82ed58c26862da037f30" => :yosemite
    sha1 "6092f92f5cd7eeb6ddf3b555cd4e655c4c85e826" => :mavericks
    sha1 "981c8c199a2ea3df18b6651205b4616459ae1f8c" => :mountain_lion
  end

  def pour_bottle?
    false
  end

  head do
    url 'git://git.code.sf.net/p/tmux/tmux-code'

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on 'pkg-config' => :build
  depends_on 'libevent'
  depends_on 'homebrew/dupes/ncurses'

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1399751/raw/e60e879335bf3b91fef4592b194cc524bcb95388/tmux-ambiguous-width-cjk.patch"
    sha256 "b77fa3de2cd43f1fe0c0423576b38e363d387343e8d0ed8a2702e67068d64fdf"
  end

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1399751/raw/d581fc517db8173581e4518e2025916a5cf5de09/tmux-do-not-combine-utf8.patch"
    sha256 "97ec3f8375ce9e5e0d823cc79c056064c4da829d791eb8cc485d19bd43ae3eb2"
  end

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1399751/raw/5914827c8f7fecfdb73c641e02c471acd55eb2af/tmux-pane-border-ascii.patch"
    sha256 "d8ccd3696f08eabdf9dd823452fba4acfecda65f4238e8ef3851855c268dcbec"
  end

  def install
    system "sh", "autogen.sh" if build.head?

    ncurses = Formula["ncurses"]

    ENV.append "LDFLAGS", '-lresolv'
    ENV.append "LDFLAGS", "-L#{ncurses.lib} -lncursesw"
    ENV.append "CPPFLAGS", "-I#{ncurses.include}/ncursesw"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"
    system "make install"

    bash_completion.install "examples/bash_completion_tmux.sh" => 'tmux'
    (share/'tmux').install "examples"
  end

  def caveats; <<-EOS.undent
    Example configurations have been installed to:
      #{share}/tmux/examples
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
