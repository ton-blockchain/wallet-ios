import Foundation
import UIKit
import AppBundle
import AsyncDisplayKit
import Display
import SwiftSignalKit
import OverlayStatusController
import WalletCore

private final class WalletConfigurationScreenArguments {
    let updateState: ((WalletConfigurationScreenState) -> WalletConfigurationScreenState) -> Void
    let dismissInput: () -> Void
    let updateNetwork: (LocalWalletConfiguration.ActiveNetwork) -> Void
    let updateSelectedMode: (WalletConfigurationScreenMode) -> Void
    let updateBlockchainName: (String) -> Void
    
    init(updateState: @escaping ((WalletConfigurationScreenState) -> WalletConfigurationScreenState) -> Void, dismissInput: @escaping () -> Void, updateNetwork: @escaping (LocalWalletConfiguration.ActiveNetwork) -> Void, updateSelectedMode: @escaping (WalletConfigurationScreenMode) -> Void, updateBlockchainName: @escaping (String) -> Void) {
        self.updateState = updateState
        self.dismissInput = dismissInput
        self.updateNetwork = updateNetwork
        self.updateSelectedMode = updateSelectedMode
        self.updateBlockchainName = updateBlockchainName
    }
}

private enum WalletConfigurationScreenMode {
    case url
    case customString
}

private enum WalletConfigurationScreenSection: Int32 {
    case network
    case mode
    case configString
    case blockchainName
}

private enum WalletConfigurationScreenEntryTag: ItemListItemTag {
    case configStringText
    
    func isEqual(to other: ItemListItemTag) -> Bool {
        if let other = other as? WalletConfigurationScreenEntryTag {
            return self == other
        } else {
            return false
        }
    }
}

private enum WalletConfigurationScreenEntry: ItemListNodeEntry, Equatable {
    /*case networkHeader(WalletTheme, String)
    case networkMainNet(WalletTheme, String, Bool)
    case networkTestNet(WalletTheme, String, Bool)*/
    case modeHeader(WalletTheme, String)
    case modeUrl(WalletTheme, String, Bool)
    case modeCustomString(WalletTheme, String, Bool)
    case modeInfo(WalletTheme, String)
    case configUrl(WalletTheme, WalletStrings, String, String)
    case configString(WalletTheme, String, String)
    case blockchainNameHeader(WalletTheme, String)
    case blockchainName(WalletTheme, WalletStrings, String, String)
    case blockchainNameInfo(WalletTheme, String)
   
    var section: ItemListSectionId {
        switch self {
        /*case .networkHeader, .networkMainNet, .networkTestNet:
            return WalletConfigurationScreenSection.network.rawValue*/
        case .modeHeader, .modeUrl, .modeCustomString, .modeInfo:
            return WalletConfigurationScreenSection.mode.rawValue
        case .configUrl, .configString:
            return WalletConfigurationScreenSection.configString.rawValue
        case .blockchainNameHeader, .blockchainName, .blockchainNameInfo:
            return WalletConfigurationScreenSection.blockchainName.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
        /*case .networkHeader:
            return 0
        case .networkMainNet:
            return 1
        case .networkTestNet:
            return 2*/
        case .modeHeader:
            return 3
        case .modeUrl:
            return 4
        case .modeCustomString:
            return 5
        case .modeInfo:
            return 6
        case .configUrl:
            return 7
        case .configString:
            return 8
        case .blockchainNameHeader:
            return 9
        case .blockchainName:
            return 10
        case .blockchainNameInfo:
            return 11
        }
    }
    
    static func <(lhs: WalletConfigurationScreenEntry, rhs: WalletConfigurationScreenEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(_ arguments: Any) -> ListViewItem {
        let arguments = arguments as! WalletConfigurationScreenArguments
        switch self {
        /*case let .networkHeader(theme, text):
            return ItemListSectionHeaderItem(theme: theme, text: text, sectionId: self.section)
        case let .networkMainNet(theme, text, isSelected):
            return ItemListCheckboxItem(theme: theme, title: text, style: .left, checked: isSelected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateNetwork(.mainNet)
            })
        case let .networkTestNet(theme, text, isSelected):
            return ItemListCheckboxItem(theme: theme, title: text, style: .left, checked: isSelected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateNetwork(.testNet)
            })*/
        case let .modeHeader(theme, text):
            return ItemListSectionHeaderItem(theme: theme, text: text, sectionId: self.section)
        case let .modeUrl(theme, text, isSelected):
            return ItemListCheckboxItem(theme: theme, title: text, style: .left, checked: isSelected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateSelectedMode(.url)
            })
        case let .modeCustomString(theme, text, isSelected):
            return ItemListCheckboxItem(theme: theme, title: text, style: .left, checked: isSelected, zeroSeparatorInsets: false, sectionId: self.section, action: {
                arguments.updateSelectedMode(.customString)
            })
        case let .modeInfo(theme, text):
            return ItemListTextItem(theme: theme, text: .plain(text), sectionId: self.section)
        case let .configUrl(theme, _, placeholder, text):
            return ItemListMultilineInputItem(theme: theme, text: text, placeholder: placeholder, maxLength: nil, sectionId: self.section, style: .blocks, capitalization: false, autocorrection: false, returnKeyType: .done, minimalHeight: nil, textUpdated: { value in
                arguments.updateState { state in
                    var state = state
                    state.storedConfigUrl[state.configuration.activeNetwork] = value
                    return state
                }
            }, shouldUpdateText: { _ in
                return true
            }, processPaste: nil, updatedFocus: nil, tag: WalletConfigurationScreenEntryTag.configStringText, action: nil, inlineAction: nil)
        case let .configString(theme, placeholder, text):
            return ItemListMultilineInputItem(theme: theme, text: text, placeholder: placeholder, maxLength: nil, sectionId: self.section, style: .blocks, capitalization: false, autocorrection: false, returnKeyType: .done, minimalHeight: nil, textUpdated: { value in
                arguments.updateState { state in
                    var state = state
                    state.storedConfigString[state.configuration.activeNetwork] = value
                    return state
                }
            }, shouldUpdateText: { _ in
                return true
            }, processPaste: nil, updatedFocus: nil, tag: WalletConfigurationScreenEntryTag.configStringText, action: nil, inlineAction: nil)
        case let .blockchainNameHeader(theme, title):
            return ItemListSectionHeaderItem(theme: theme, text: title, sectionId: self.section)
        case let .blockchainName(theme, strings, title, value):
            return ItemListSingleLineInputItem(theme: theme, strings: strings, title: NSAttributedString(string: ""), text: value, placeholder: title, type: .regular(capitalization: false, autocorrection: false), sectionId: self.section, textUpdated: { value in
                arguments.updateBlockchainName(value)
            }, action: {})
        case let .blockchainNameInfo(theme, text):
            return ItemListTextItem(theme: theme, text: .plain(text), sectionId: self.section)
        }
    }
}

private struct WalletConfigurationScreenState: Equatable {
    var configuration: LocalWalletConfiguration
    var storedConfigUrl: [LocalWalletConfiguration.ActiveNetwork: String]
    var storedConfigString: [LocalWalletConfiguration.ActiveNetwork: String]
    
    static func fromConfiguration(_ value: LocalWalletConfiguration) -> WalletConfigurationScreenState {
        var storedConfigUrl: [LocalWalletConfiguration.ActiveNetwork: String] = [:]
        var storedConfigString: [LocalWalletConfiguration.ActiveNetwork: String] = [:]
        /*switch value.mainNet.source {
        case let .url(url):
            storedConfigUrl[.mainNet] = url
            storedConfigString[.mainNet] = ""
        case let .string(string):
            storedConfigUrl[.mainNet] = ""
            storedConfigString[.mainNet] = string
        }*/
        switch value.testNet.source {
        case let .url(url):
            storedConfigUrl[.testNet] = url
            storedConfigString[.testNet] = ""
        case let .string(string):
            storedConfigUrl[.testNet] = ""
            storedConfigString[.testNet] = string
        }
        
        return WalletConfigurationScreenState(configuration: value, storedConfigUrl: storedConfigUrl, storedConfigString: storedConfigString)
    }
    
    func deriveValidatedConfiguration() -> LocalWalletConfiguration? {
        /*let mainSource: LocalWalletConfigurationSource
        switch self.configuration.mainNet.source {
        case .url:
            if let url = self.storedConfigUrl[.mainNet], !url.isEmpty, URL(string: url) != nil {
                mainSource = .url(url)
            } else {
                return nil
            }
        case .string:
            if let string = self.storedConfigString[.mainNet], !string.isEmpty {
                mainSource = .string(string)
            } else {
                return nil
            }
        }*/
        let testSource: LocalWalletConfigurationSource
        switch self.configuration.testNet.source {
        case .url:
            if let url = self.storedConfigUrl[.testNet], !url.isEmpty, URL(string: url) != nil {
                testSource = .url(url)
            } else {
                return nil
            }
        case .string:
            if let string = self.storedConfigString[.testNet], !string.isEmpty {
                testSource = .string(string)
            } else {
                return nil
            }
        }
        
        if self.configuration.testNet.customId == "mainnet" {
            return nil
        }
        
        return LocalWalletConfiguration(
            //mainNet: LocalBlockchainConfiguration(source: mainSource, customId: nil),
            testNet: LocalBlockchainConfiguration(source: testSource, customId: self.configuration.testNet.customId),
            activeNetwork: self.configuration.activeNetwork
        )
    }
    
    var isEmpty: Bool {
        let blockchainConfiguration: LocalBlockchainConfiguration
        switch self.configuration.activeNetwork {
        /*case .mainNet:
            blockchainConfiguration = self.configuration.mainNet*/
        case .testNet:
            blockchainConfiguration = self.configuration.testNet
        }
        
        if self.configuration.testNet.customId == "mainnet" {
            return true
        }
        
        switch blockchainConfiguration.source {
        case .url:
            if let url = self.storedConfigUrl[self.configuration.activeNetwork] {
                return url.isEmpty || URL(string: url) == nil
            } else {
                return true
            }
        case .string:
            if let string = self.storedConfigString[self.configuration.activeNetwork] {
                return string.isEmpty
            } else {
                return true
            }
        }
    }
}

private func walletConfigurationScreenEntries(presentationData: WalletPresentationData, state: WalletConfigurationScreenState) -> [WalletConfigurationScreenEntry] {
    var entries: [WalletConfigurationScreenEntry] = []
    
    let blockchainConfiguration: LocalBlockchainConfiguration
    let isMainNet: Bool
    switch state.configuration.activeNetwork {
    /*case .mainNet:
        blockchainConfiguration = state.configuration.mainNet
        isMainNet = true*/
    case .testNet:
        blockchainConfiguration = state.configuration.testNet
        isMainNet = false
    }
    
    /*entries.append(.networkHeader(presentationData.theme, "TON BLOCKCHAIN"))
    entries.append(.networkMainNet(presentationData.theme, "Main Network", isMainNet))
    entries.append(.networkTestNet(presentationData.theme, "Test Network", !isMainNet))*/
    
    let isUrl: Bool
    switch blockchainConfiguration.source {
    case .url:
        isUrl = true
    case .string:
        isUrl = false
    }
   
    entries.append(.modeHeader(presentationData.theme, presentationData.strings.Wallet_Configuration_SourceHeader))
    entries.append(.modeUrl(presentationData.theme, presentationData.strings.Wallet_Configuration_SourceURL, isUrl))
    entries.append(.modeCustomString(presentationData.theme, presentationData.strings.Wallet_Configuration_SourceJSON, !isUrl))
    entries.append(.modeInfo(presentationData.theme, presentationData.strings.Wallet_Configuration_SourceInfo))
    
    switch blockchainConfiguration.source {
    case .url:
        entries.append(.configUrl(presentationData.theme, presentationData.strings, presentationData.strings.Wallet_Configuration_SourceURL, state.storedConfigUrl[state.configuration.activeNetwork] ?? ""))
    case .string:
        entries.append(.configString(presentationData.theme, presentationData.strings.Wallet_Configuration_SourceJSON, state.storedConfigString[state.configuration.activeNetwork] ?? ""))
    }
    
    if case .testNet = state.configuration.activeNetwork {
        entries.append(.blockchainNameHeader(presentationData.theme, presentationData.strings.Wallet_Configuration_BlockchainIdHeader))
        entries.append(.blockchainName(presentationData.theme, presentationData.strings, presentationData.strings.Wallet_Configuration_BlockchainIdPlaceholder, blockchainConfiguration.customId ?? ""))
        entries.append(.blockchainNameInfo(presentationData.theme, presentationData.strings.Wallet_Configuration_BlockchainIdInfo))
    }
    
    return entries
}

protocol WalletConfigurationScreen {
}

private final class WalletConfigurationScreenImpl: ItemListController, WalletConfigurationScreen {
    override func preferredContentSizeForLayout(_ layout: ContainerViewLayout) -> CGSize? {
        return CGSize(width: layout.size.width, height: layout.size.height - 174.0)
    }
}

private func presentError(context: WalletContext, present: ((ViewController, Any?) -> Void)?, title: String?, text: String) {
    present?(standardTextAlertController(theme: context.presentationData.theme.alert, title: title, text: text, actions: [TextAlertAction(type: .defaultAction, title: context.presentationData.strings.Wallet_Alert_OK, action: {})]), nil)
}

func walletConfigurationScreen(context: WalletContext, currentConfiguration: LocalWalletConfiguration) -> ViewController {
    let initialState = WalletConfigurationScreenState.fromConfiguration(currentConfiguration)
    let statePromise = ValuePromise(initialState, ignoreRepeated: true)
    let stateValue = Atomic(value: initialState)
    let updateState: ((WalletConfigurationScreenState) -> WalletConfigurationScreenState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    
    var presentControllerImpl: ((ViewController, Any?) -> Void)?
    var dismissImpl: (() -> Void)?
    var dismissInputImpl: (() -> Void)?
    
    let arguments = WalletConfigurationScreenArguments(updateState: { f in
        updateState(f)
    }, dismissInput: {
        dismissInputImpl?()
    }, updateNetwork: { value in
        updateState { state in
            var state = state
            state.configuration.activeNetwork = value
            return state
        }
    }, updateSelectedMode: { mode in
        updateState { state in
            var state = state
            
            let source: LocalWalletConfigurationSource
            switch mode {
            case .url:
                source = .url("")
            case .customString:
                source = .string("")
            }
            
            switch state.configuration.activeNetwork {
            /*case .mainNet:
                state.configuration.mainNet.source = source*/
            case .testNet:
                state.configuration.testNet.source = source
            }
            return state
        }
    }, updateBlockchainName: { value in
        updateState { state in
            var state = state
            switch state.configuration.activeNetwork {
            /*case .mainNet:
                break*/
            case .testNet:
                state.configuration.testNet.customId = value
            }
            return state
        }
    })
    
    let signal = combineLatest(queue: .mainQueue(), .single(context.presentationData), statePromise.get())
    |> map { presentationData, state -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let rightNavigationButton = ItemListNavigationButton(content: .text(presentationData.strings.Wallet_Configuration_Apply), style: .bold, enabled: !state.isEmpty, action: {
            let state = stateValue.with { $0 }
            
            guard let updatedConfiguration = state.deriveValidatedConfiguration() else {
                return
            }
            
            let currentBlockchainConfiguration: LocalBlockchainConfiguration
            switch currentConfiguration.activeNetwork {
            /*case .mainNet:
                currentBlockchainConfiguration = currentConfiguration.mainNet*/
            case .testNet:
                currentBlockchainConfiguration = currentConfiguration.testNet
            }
            
            let updatedBlockchainConfiguration: LocalBlockchainConfiguration
            let updatedEffectiveBlockchainName: String
            switch updatedConfiguration.activeNetwork {
            /*case .mainNet:
                updatedBlockchainConfiguration = updatedConfiguration.mainNet
                updatedEffectiveBlockchainName = "mainnet"*/
            case .testNet:
                updatedBlockchainConfiguration = updatedConfiguration.testNet
                updatedEffectiveBlockchainName = updatedConfiguration.testNet.customId ?? "testnet2"
            }
            
            if currentConfiguration.activeNetwork != updatedConfiguration.activeNetwork || currentBlockchainConfiguration != updatedBlockchainConfiguration {
                let applyResolved: (LocalWalletConfigurationSource, String) -> Void = { source, resolvedConfig in
                    let proceed: () -> Void = {
                        let _ = (context.updateResolvedWalletConfiguration(configuration: updatedConfiguration, source: source, resolvedConfig: resolvedConfig)
                        |> deliverOnMainQueue).start(completed: {
                            dismissImpl?()
                        })
                    }
                    
                    if currentConfiguration.activeNetwork != updatedConfiguration.activeNetwork {
                        let alertText: String
                        switch updatedConfiguration.activeNetwork {
                        /*case .mainNet:
                            alertText = "Are you sure you want to switch to the Main Gram network? Grams will have real value there.\n\nIf you proceed, you will need to reconnect your wallet using 24 secret words."*/
                        case .testNet:
                            alertText = "Are you sure you want to switch to the Test Gram network? It exists only for testing purposes.\n\nIf you proceed, you will need to reconnect your wallet using 24 secret words."
                        }
                        
                        presentControllerImpl?(standardTextAlertController(theme: context.presentationData.theme.alert, title: "Warning", text: alertText, actions: [
                            TextAlertAction(type: .genericAction, title: context.presentationData.strings.Wallet_Alert_Cancel, action: {}),
                            TextAlertAction(type: .destructiveAction, title: context.presentationData.strings.Wallet_Configuration_BlockchainNameChangedProceed, action: {
                                proceed()
                            }),
                        ]), nil)
                    } else if currentBlockchainConfiguration.customId != updatedBlockchainConfiguration.customId {
                        presentControllerImpl?(standardTextAlertController(theme: context.presentationData.theme.alert, title: context.presentationData.strings.Wallet_Configuration_BlockchainNameChangedTitle, text: context.presentationData.strings.Wallet_Configuration_BlockchainNameChangedText, actions: [
                            TextAlertAction(type: .genericAction, title: context.presentationData.strings.Wallet_Alert_Cancel, action: {}),
                            TextAlertAction(type: .destructiveAction, title: context.presentationData.strings.Wallet_Configuration_BlockchainNameChangedProceed, action: {
                                proceed()
                            }),
                        ]), nil)
                    } else {
                        proceed()
                    }
                }
                
                let presentationData = context.presentationData
                
                switch updatedBlockchainConfiguration.source {
                case let .url(url):
                    if let parsedUrl = URL(string: url) {
                        let statusController = OverlayStatusController(theme: presentationData.theme, type: .loading(cancelled: nil))
                        presentControllerImpl?(statusController, nil)
                        
                        let _ = (context.downloadFile(url: parsedUrl)
                        |> deliverOnMainQueue).start(next: { data in
                            statusController.dismiss()
                            
                            guard let string = String(data: data, encoding: .utf8) else {
                                let presentationData = context.presentationData
                                presentError(context: context, present: presentControllerImpl, title: presentationData.strings.Wallet_Configuration_ApplyErrorTitle, text: presentationData.strings.Wallet_Configuration_ApplyErrorTextURLInvalidData)
                                return
                            }
                            
                            let _ = (context.tonInstance.validateConfig(config: string, blockchainName: updatedEffectiveBlockchainName)
                            |> deliverOnMainQueue).start(error: { _ in
                                let presentationData = context.presentationData
                                presentError(context: context, present: presentControllerImpl, title: presentationData.strings.Wallet_Configuration_ApplyErrorTitle, text: presentationData.strings.Wallet_Configuration_ApplyErrorTextURLInvalidData)
                            }, completed: {
                                applyResolved(.url(url), string)
                            })
                        }, error: { _ in
                            statusController.dismiss()
                            
                            let presentationData = context.presentationData
                            presentError(context: context, present: presentControllerImpl, title: presentationData.strings.Wallet_Configuration_ApplyErrorTitle, text: presentationData.strings.Wallet_Configuration_ApplyErrorTextURLUnreachable(url).0)
                        })
                    } else {
                        presentError(context: context, present: presentControllerImpl, title: presentationData.strings.Wallet_Configuration_ApplyErrorTitle, text: presentationData.strings.Wallet_Configuration_ApplyErrorTextURLInvalid)
                        return
                    }
                case let .string(string):
                    let _ = (context.tonInstance.validateConfig(config: string, blockchainName: updatedEffectiveBlockchainName)
                    |> deliverOnMainQueue).start(error: { _ in
                        let presentationData = context.presentationData
                        presentError(context: context, present: presentControllerImpl, title: presentationData.strings.Wallet_Configuration_ApplyErrorTitle, text: presentationData.strings.Wallet_Configuration_ApplyErrorTextJSONInvalidData)
                    }, completed: {
                        applyResolved(.string(string), string)
                    })
                }
            } else {
                dismissImpl?()
            }
        })
        
        let controllerState = ItemListControllerState(theme: presentationData.theme, title: .text(presentationData.strings.Wallet_Configuration_Title), leftNavigationButton: nil, rightNavigationButton: rightNavigationButton, backNavigationButton: ItemListBackButton(title: presentationData.strings.Wallet_Navigation_Back), animateChanges: false)
        let listState = ItemListNodeState(entries: walletConfigurationScreenEntries(presentationData: presentationData, state: state), style: .blocks, focusItemTag: nil, ensureVisibleItemTag: nil, animateChanges: false)
        
        return (controllerState, (listState, arguments))
    }
    
    let controller = WalletConfigurationScreenImpl(theme: context.presentationData.theme, strings: context.presentationData.strings, updatedPresentationData: .single((context.presentationData.theme, context.presentationData.strings)), state: signal, tabBarItem: nil)
    controller.navigationPresentation = .modal
    controller.supportedOrientations = ViewControllerSupportedOrientations(regularSize: .all, compactSize: .portrait)
    controller.experimentalSnapScrollToItem = true
    controller.didAppear = { _ in
    }
    presentControllerImpl = { [weak controller] c, a in
        controller?.present(c, in: .window(.root), with: a)
    }
    dismissImpl = { [weak controller] in
        controller?.view.endEditing(true)
        let _ = controller?.dismiss()
    }
    dismissInputImpl = { [weak controller] in
        controller?.view.endEditing(true)
    }
    return controller
}
