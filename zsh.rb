require 'formula'

class Zsh < Formula
  desc "A UNIX shell (command interpreter)"
  homepage 'http://www.zsh.org/'
  url 'https://downloads.sourceforge.net/project/zsh/zsh/5.0.8/zsh-5.0.8.tar.bz2'
  mirror 'http://www.zsh.org/pub/zsh-5.0.8.tar.bz2'
  sha256 '8079cf08cb8beff22f84b56bd72bb6e6962ff4718d816f3d83a633b4c9e17d23'

  bottle do
    sha1 "83d646649569ade648db6a44c480709d63268a25" => :yosemite
    sha1 "935990ced3a6d3a3027bac4b32ac8f031e8fa244" => :mavericks
    sha1 "c6e8055106d0b939cec5674469099bfd63d53f9e" => :mountain_lion
  end

  def pour_bottle?
    false
  end

  depends_on 'gdbm'
  depends_on 'pcre'
  depends_on 'homebrew/dupes/ncurses'

  option 'disable-etcdir', 'Disable the reading of Zsh rc files in /etc'

  patch :p1 do
    url "https://gist.githubusercontent.com/waltarix/1407905/raw/c691d18f93269711bee64b985730de58e41bcaa0/zsh-ambiguous-width-cjk.patch"
    sha256 "c38ecf9efd60873b43f3d5742690aecc982799592db165a6ff7d42fecf4eb0fa"
  end

  def install
    ncurses = Formula["ncurses"]
    ENV.append "LDFLAGS", "-L#{ncurses.lib}"
    ENV.append "CPPFLAGS", "-I#{ncurses.include}"

    args = %W[
      --prefix=#{prefix}
      --enable-fndir=#{share}/zsh/functions
      --enable-scriptdir=#{share}/zsh/scripts
      --enable-site-fndir=#{HOMEBREW_PREFIX}/share/zsh/site-functions
      --enable-site-scriptdir=#{HOMEBREW_PREFIX}/share/zsh/site-scripts
      --enable-runhelpdir=#{share}/zsh/help
      --enable-cap
      --enable-maildir-support
      --enable-multibyte
      --enable-pcre
      --enable-zsh-secure-free
      --with-tcsetpgrp
      --enable-locale
      --with-term-lib=ncursesw
      zsh_cv_c_broken_wcwidth=yes
    ]

    if build.include? 'disable-etcdir'
      args << '--disable-etcdir'
    else
      args << '--enable-etcdir=/etc'
    end

    system "./configure", *args

    # Do not version installation directories.
    inreplace ["Makefile", "Src/Makefile"],
      "$(libdir)/$(tzsh)/$(VERSION)", "$(libdir)"

    system "make", "install"
    system "make", "install.info"
  end

  test do
    system "#{bin}/zsh", "--version"
  end

  def caveats; <<-EOS.undent
    Add the following to your zshrc to access the online help:
      unalias run-help
      autoload run-help
      HELPDIR=#{HOMEBREW_PREFIX}/share/zsh/help
    EOS
  end
end
