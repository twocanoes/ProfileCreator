//
//  MainWindowToolbarItems.swift
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright © 2018 Erik Berglund. All rights reserved.
//

import Cocoa
import ProfilePayloads

class ProfileEditorWindowToolbarItemSearch: NSObject {

    // MARK: -
    // MARK: Variables

    weak var profile: Profile?
    weak var profileEditor: ProfileEditor?

    var selectedPayloadPlaceholder: PayloadPlaceholder?
    var toolbarItem: NSToolbarItem?

    // MARK: -
    // MARK: Initialization

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(profile: Profile, editor: ProfileEditor) {
        super.init()
        // ---------------------------------------------------------------------
        //  Setup Variables
        // ---------------------------------------------------------------------
        self.profile = profile
        self.profileEditor = editor

        // ---------------------------------------------------------------------
        //  Create the actual toolbar item
        // ---------------------------------------------------------------------
        let toolbarItem = NSSearchToolbarItem(itemIdentifier: .editorSearch)
        toolbarItem.toolTip = NSLocalizedString("Filter items", comment: "")
        toolbarItem.isBordered = true
        toolbarItem.target = self
        toolbarItem.action = #selector(search)
        toolbarItem.isEnabled = true

        // TODO: Fix adding payload keys

        self.toolbarItem = toolbarItem

        // ---------------------------------------------------------------------
        //  Setup Notification Observers
        // ---------------------------------------------------------------------
        self.profileEditor?.addObserver(self, forKeyPath: editor.selectedPayloadPlaceholderUpdatedSelector, options: .new, context: nil)
    }

    deinit {
        if let editor = self.profileEditor {
            editor.removeObserver(self, forKeyPath: editor.selectedPayloadPlaceholderUpdatedSelector, context: nil)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let editor = self.profileEditor else { return }
        if keyPath == editor.selectedPayloadPlaceholderUpdatedSelector {
            self.selectedPayloadPlaceholder = editor.selectedPayloadPlaceholder
        } else {
            Log.shared.error(message: "ERROR", category: String(describing: self))
        }

        self.toolbarItem?.isEnabled = !(self.selectedPayloadPlaceholder?.payload.unique ?? false)
    }

    @objc func search() {
        if let searchToolBarItem = self.toolbarItem as? NSSearchToolbarItem{
            let searchText = searchToolBarItem.searchField.stringValue

            if searchText.isEmpty {
                self.profileEditor!.filterString = nil
            }
            else {
                self.profileEditor!.filterString = searchText

            }
            self.profileEditor!.reloadTableView(updateCellViews: true)


        }

    }

}
