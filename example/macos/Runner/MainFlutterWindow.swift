import Cocoa
import FlutterMacOS
import QuartzCore

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // Enable EDR (Extended Dynamic Range) on the underlying Metal layer
    DispatchQueue.main.async {
      func enableEDR(layer: CALayer?) {
        guard let layer = layer else { return }
        if let metalLayer = layer as? CAMetalLayer {
          metalLayer.wantsExtendedDynamicRangeContent = true
        }
        layer.sublayers?.forEach { enableEDR(layer: $0) }
      }
      enableEDR(layer: flutterViewController.view.layer)
    }
  }
}
