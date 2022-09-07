import class SafariServices.SFSafariViewController

public final class WalletBuyGramsScreen: SFSafariViewController {
	
	// MARK: - Override
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 11.0, *) {
			dismissButtonStyle = .cancel
		}
	}
}
