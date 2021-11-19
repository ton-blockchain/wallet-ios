import UIKit
import WebKit
import Display

public final class WalletBuyGramsScreen: ViewController, WKNavigationDelegate {
	
	private let request: URLRequest
	private lazy var webView: WKWebView = {
		let webView = WKWebView()
		webView.allowsBackForwardNavigationGestures = true
		webView.navigationDelegate = self
		return webView
	}()
	
	// MARK: - Initialization
	
	public init(with url: URL, context: WalletContext) {
		request = URLRequest(url: url)
		super.init(navigationBarPresentationData: nil)
		
		title = "Buy Toncoin"
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: context.presentationData.strings.Wallet_Navigation_Close,
														   style: .plain,
														   target: self,
														   action: #selector(closeTapped))
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Lifecycle
	
	public override func loadView() {
		view = webView
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		webView.load(request)
	}
	
	// MARK: - Private
	
	@objc
	private func closeTapped() {
		if let container = navigationController {
			container.dismiss(animated: true)
		} else {
			dismiss()
		}
	}
}
