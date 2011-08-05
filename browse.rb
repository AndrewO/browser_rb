framework 'Cocoa'
framework 'WebKit'

require 'optparse'

class Browser
  attr_accessor :view
  attr_reader :window
  
  def initialize
    @view   = WebView.alloc.initWithFrame([0, 0, 1040, 520])
    @window = NSWindow.alloc.initWithContentRect([200, 200, 1040, 520],
                                                styleMask:NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask, 
                                                backing:NSBackingStoreBuffered, 
                                                defer:false)
    @window.contentView = view
    # Use the screen stylesheet, rather than the print one.
    view.mediaStyle = 'screen'
    view.customUserAgent = 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_2; en-us) AppleWebKit/531.21.8 (KHTML, like Gecko) Version/4.0.4 Safari/531.21.10'
    # Make sure we don't save any of the prefs that we change.
    view.preferences.autosaves = false
    # Set some useful options.
    view.preferences.shouldPrintBackgrounds = true
    view.preferences.javaScriptCanOpenWindowsAutomatically = false
    # view.preferences.allowsAnimatedImages = false
    view.preferences.plugInsEnabled = false
    view.mainFrame.frameView.allowsScrolling = true
    view.frameLoadDelegate = self
  end

  def show(url, string)
    view.mainFrame.loadHTMLString(string, baseURL: (url.kind_of?(NSURL) ? url : NSURL.URLWithString(url.to_s)))
  end

  def fetch(url)
    page_url = NSURL.URLWithString(url)
    view.mainFrame.loadRequest(NSURLRequest.requestWithURL(page_url))
  end
  
  # Delegate methods
  def webView(view, didFinishLoadForFrame: frame)
    @window.display
    @window.orderFrontRegardless
    @window.makeKeyWindow
  end
end

url = nil

opts = OptionParser.new
opts.on("-u", "--url URL", String) {|val| url = val}
opts.parse(*ARGV)

NSApplication.sharedApplication
# Gives the App a Dock, allows windows
# NSApplication.sharedApplication.activationPolicy = NSApplicationActivationPolicyRegular
# Gives the main window focus
# NSApplication.sharedApplication.activateIgnoringOtherApps(true)

# class AppDelegate
#   # Exits the script when the window is closed
#   def applicationShouldTerminateAfterLastWindowClosed(app)
#     true
#   end
# end
# NSApplication.sharedApplication.delegate = AppDelegate.new

# Enable the webkit development console
# NSUserDefaults.standardUserDefaults.registerDefaults("WebKitDeveloperExtras" => true)

browser = Browser.new

if STDIN.tty?
  browser.fetch(url)
else  
  browser.show(url, STDIN.read)
end


# NSApplication.sharedApplication.run
NSRunLoop.currentRunLoop.runUntilDate(NSDate.distantFuture)