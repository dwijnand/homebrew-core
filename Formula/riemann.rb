class Riemann < Formula
  desc "Event stream processor"
  homepage "https://riemann.io/"
  url "https://github.com/riemann/riemann/releases/download/0.3.2/riemann-0.3.2.tar.bz2"
  sha256 "9bb045acf9e85956089130945234a4100e6d70b073d0a45f431e6b4440f6076f"

  bottle :unneeded

  def shim_script
    <<~EOS
      #!/bin/bash
      if [ -z "$1" ]
      then
        config="#{etc}/riemann.config"
      else
        config=$@
      fi
      exec "#{libexec}/bin/riemann" $config
    EOS
  end

  def install
    etc.install "etc/riemann.config" => "riemann.config.guide"

    # Install jars in libexec to avoid conflicts
    libexec.install Dir["*"]

    (bin+"riemann").write shim_script
  end

  def caveats; <<~EOS
    You may also wish to install these Ruby gems:
      riemann-client
      riemann-tools
      riemann-dash
  EOS
  end

  plist_options :manual => "riemann"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/riemann</string>
          <string>#{etc}/riemann.config</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>StandardErrorPath</key>
        <string>#{var}/log/riemann.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/riemann.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    system "#{bin}/riemann", "-help", "0"
  end
end
