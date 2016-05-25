//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Tony Arnold (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

// TODO: Reimplement using reactive delegates

//import ReactiveKit
//import Cocoa
//
//extension NSTableView {
//  private struct AssociatedKeys {
//    static var DataSourceKey = "r_DataSourceKey"
//  }
//}
//
//extension PropertyCollectionType where Collection.Index == Int, Event == PropertyCollectionEvent<Collection> {
//  public func bindTo(tableView: NSTableView, animated: Bool = true, proxyDataSource: RKTableViewProxyDataSource? = .None, proxyDelegate: RKTableViewProxyDelegate? = .None, createViewForCell: (NSTableView, NSTableColumn?, Int, Collection) -> NSView?, objectValue: ((Int, NSTableColumn?, Collection, NSTableView) -> AnyObject?)?) -> Disposable {
//
//    let dataSource = RKTableViewDataSource(
//      collection: self,
//      tableView: tableView,
//      animated: animated,
//      proxyDataSource: proxyDataSource,
//      proxyDelegate: proxyDelegate,
//      createViewForCell: createViewForCell,
//      objectValue: objectValue
//    )
//
//    objc_setAssociatedObject(tableView, &NSTableView.AssociatedKeys.DataSourceKey, dataSource, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//
//    return BlockDisposable { [weak tableView] in
//      if let tableView = tableView {
//        objc_setAssociatedObject(tableView, &NSTableView.AssociatedKeys.DataSourceKey, .None, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//      }
//    }
//  }
//}
//
//@objc public protocol RKTableViewProxyDataSource: NSTableViewDataSource {
//  /// Override to specify custom row animation when row is being inserted, deleted or updated
//  optional func tableView(tableView: NSTableView, animationForRowAtIndexes indexes: NSIndexSet) -> NSTableViewAnimationOptions
//}
//
//@objc public protocol RKTableViewProxyDelegate: NSTableViewDelegate {}
//
//public class RKTableViewDataSource<C: PropertyCollectionType where C.Collection.Index == Int, C.Event == PropertyCollectionEvent<C.Collection>>: NSObject, NSTableViewDataSource, NSTableViewDelegate {
//
//  private let PropertyCollection: C
//  private var sourceCollection: C.Collection
//  private weak var tableView: NSTableView!
//  private let createViewForCell: (NSTableView, NSTableColumn?, Int, C.Collection) -> NSView?
//  private let objectValue: ((Int, NSTableColumn?, C.Collection, NSTableView) -> AnyObject?)?
//  private weak var proxyDataSource: RKTableViewProxyDataSource?
//  private weak var proxyDelegate: RKTableViewProxyDelegate?
//  private let animated: Bool
//
//  public init(collection: C, tableView: NSTableView, animated: Bool, proxyDataSource: RKTableViewProxyDataSource? = .None, proxyDelegate: RKTableViewProxyDelegate? = .None, createViewForCell: (NSTableView, NSTableColumn?, Int, C.Collection) -> NSView?, objectValue: ((Int, NSTableColumn?, C.Collection, NSTableView) -> AnyObject?)? = .None) {
//    self.tableView = tableView
//    self.objectValue = objectValue
//    self.createViewForCell = createViewForCell
//    self.proxyDataSource = proxyDataSource
//    self.proxyDelegate = proxyDelegate
//    self.PropertyCollection = collection
//    self.sourceCollection = collection.collection
//    self.animated = animated
//    super.init()
//
//    self.tableView.setDataSource(self)
//    self.tableView.setDelegate(self)
//    self.tableView.reloadData()
//
//    PropertyCollection.skip(1).observe(on: ImmediateOnMainExecutionContext) { [weak self] event in
//      if let uSelf = self {
//        uSelf.sourceCollection = event.collection
//        if animated {
//          uSelf.tableView.beginUpdates()
//          RKTableViewDataSource.applyRowUnitChangeSet(event, tableView: uSelf.tableView, sectionIndex: 0, dataSource: uSelf.proxyDataSource)
//          uSelf.tableView.endUpdates()
//        } else {
//          uSelf.tableView.reloadData()
//        }
//      }
//      }.disposeIn(rBag)
//  }
//
//  private class func applyRowUnitChangeSet(changeSet: PropertyCollectionEvent<C.Collection>, tableView: NSTableView, sectionIndex: Int, dataSource: RKTableViewProxyDataSource?) {
//
//    if changeSet.inserts.count > 0 {
//      let indexes = NSMutableIndexSet()
//      for index in changeSet.inserts {
//        indexes.addIndex(index)
//      }
//      let animation = dataSource?.tableView?(tableView, animationForRowAtIndexes: indexes) ?? [ .EffectNone ]
//      tableView.insertRowsAtIndexes(indexes, withAnimation: animation)
//    }
//
//    if changeSet.updates.count > 0 {
//      let indexes = NSMutableIndexSet()
//      for index in changeSet.updates {
//        indexes.addIndex(index)
//      }
//
//      let allColumnIndexes = NSIndexSet(indexesInRange: NSRange(location: 0, length: tableView.numberOfColumns))
//      tableView.reloadDataForRowIndexes(indexes, columnIndexes: allColumnIndexes)
//    }
//
//    if changeSet.deletes.count > 0 {
//      let indexes = NSMutableIndexSet()
//      for index in changeSet.deletes {
//        indexes.addIndex(index)
//      }
//
//      let animation = dataSource?.tableView?(tableView, animationForRowAtIndexes: indexes) ?? [ .EffectNone ]
//      tableView.removeRowsAtIndexes(indexes, withAnimation: animation)
//    }
//
//  }
//
//  /// MARK - NSTableViewDataSource
//
//  @objc public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
//    return sourceCollection.count
//  }
//
//  @objc public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
//    return objectValue?(row, tableColumn, sourceCollection, tableView)
//  }
//
//  @objc public func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
//    proxyDataSource?.tableView?(tableView, setObjectValue: object, forTableColumn: tableColumn, row: row)
//  }
//
//  @objc public func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
//    proxyDataSource?.tableView?(tableView, sortDescriptorsDidChange: oldDescriptors)
//  }
//
//  @objc public func tableView(tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
//    return proxyDataSource?.tableView?(tableView, pasteboardWriterForRow: row)
//  }
//
//  @objc public func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forRowIndexes rowIndexes: NSIndexSet) {
//    proxyDataSource?.tableView?(tableView, draggingSession: session, willBeginAtPoint: screenPoint, forRowIndexes: rowIndexes)
//  }
//
//  @objc public func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, endedAtPoint screenPoint: NSPoint, operation: NSDragOperation) {
//    proxyDataSource?.tableView?(tableView, draggingSession: session, endedAtPoint: screenPoint, operation: operation)
//  }
//
//  @objc public func tableView(tableView: NSTableView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
//    proxyDataSource?.tableView?(tableView, updateDraggingItemsForDrag: draggingInfo)
//  }
//
//  @objc public func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
//    return proxyDataSource?.tableView?(tableView, writeRowsWithIndexes: rowIndexes, toPasteboard: pboard) ?? false
//  }
//
//  @objc public func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
//    return proxyDataSource?.tableView?(tableView, validateDrop: info, proposedRow: row, proposedDropOperation: dropOperation) ?? .None
//  }
//
//  @objc public func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
//    return proxyDataSource?.tableView?(tableView, acceptDrop: info, row: row, dropOperation: dropOperation) ?? false
//  }
//
//  @objc public func tableView(tableView: NSTableView, namesOfPromisedFilesDroppedAtDestination dropDestination: NSURL, forDraggedRowsWithIndexes indexSet: NSIndexSet) -> [String] {
//    return proxyDataSource?.tableView?(tableView, namesOfPromisedFilesDroppedAtDestination: dropDestination, forDraggedRowsWithIndexes: indexSet) ?? []
//  }
//
//  /// MARK - NSTableViewDelegate
//
//  @objc public func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
//    return createViewForCell(tableView, tableColumn, row, sourceCollection)
//  }
//
//  @objc public func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//    return proxyDelegate?.tableView?(tableView, rowViewForRow: row)
//  }
//
//  @objc public func tableView(tableView: NSTableView, didAddRowView rowView: NSTableRowView, forRow row: Int) {
//    proxyDelegate?.tableView?(tableView, didAddRowView: rowView, forRow: row)
//  }
//
//  @objc public func tableView(tableView: NSTableView, didRemoveRowView rowView: NSTableRowView, forRow row: Int) {
//    proxyDelegate?.tableView?(tableView, didRemoveRowView: rowView, forRow: row)
//  }
//
//  @objc public func tableView(tableView: NSTableView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, row: Int) {
//    proxyDelegate?.tableView?(tableView, willDisplayCell: cell, forTableColumn: tableColumn, row: row)
//  }
//
//  @objc public func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
//    return proxyDelegate?.tableView?(tableView, shouldEditTableColumn: tableColumn, row: row) ?? false
//  }
//
//  @objc public func tableView(tableView: NSTableView, toolTipForCell cell: NSCell, rect: NSRectPointer, tableColumn: NSTableColumn?, row: Int, mouseLocation: NSPoint) -> String {
//    return proxyDelegate?.tableView?(tableView, toolTipForCell: cell, rect: rect, tableColumn: tableColumn, row: row, mouseLocation: mouseLocation) ?? ""
//  }
//
//  @objc public func tableView(tableView: NSTableView, shouldShowCellExpansionForTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
//    return proxyDelegate?.tableView?(tableView, shouldShowCellExpansionForTableColumn: tableColumn, row: row) ?? false
//  }
//
//  @objc public func tableView(tableView: NSTableView, shouldTrackCell cell: NSCell, forTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
//    return proxyDelegate?.tableView?(tableView, shouldTrackCell: cell, forTableColumn: tableColumn, row: row) ?? false
//  }
//
//  @objc public func tableView(tableView: NSTableView, dataCellForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSCell? {
//    return proxyDelegate?.tableView?(tableView, dataCellForTableColumn: tableColumn, row: row)
//  }
//
//  @objc public func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
//    return proxyDelegate?.selectionShouldChangeInTableView?(tableView) ?? true
//  }
//
//  @objc public func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
//    return proxyDelegate?.tableView?(tableView, shouldSelectRow: row) ?? true
//  }
//
//  @objc public func tableView(tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
//    return proxyDelegate?.tableView?(tableView, selectionIndexesForProposedSelection: proposedSelectionIndexes) ?? proposedSelectionIndexes
//  }
//
//  @objc public func tableView(tableView: NSTableView, shouldSelectTableColumn tableColumn: NSTableColumn?) -> Bool {
//    return proxyDelegate?.tableView?(tableView, shouldSelectTableColumn: tableColumn) ?? true
//  }
//
//  @objc public func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
//    proxyDelegate?.tableView?(tableView, mouseDownInHeaderOfTableColumn: tableColumn)
//  }
//
//  @objc public func tableView(tableView: NSTableView, didClickTableColumn tableColumn: NSTableColumn) {
//    proxyDelegate?.tableView?(tableView, didClickTableColumn: tableColumn)
//  }
//
//  @objc public func tableView(tableView: NSTableView, didDragTableColumn tableColumn: NSTableColumn) {
//    proxyDelegate?.tableView?(tableView, didDragTableColumn: tableColumn)
//  }
//
//  @objc public func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//    return proxyDelegate?.tableView?(tableView, heightOfRow: row) ?? NSViewNoIntrinsicMetric
//  }
//
//  @objc public func tableView(tableView: NSTableView, typeSelectStringForTableColumn tableColumn: NSTableColumn?, row: Int) -> String? {
//    return proxyDelegate?.tableView?(tableView, typeSelectStringForTableColumn: tableColumn, row: row)
//  }
//
//  @objc public func tableView(tableView: NSTableView, nextTypeSelectMatchFromRow startRow: Int, toRow endRow: Int, forString searchString: String) -> Int {
//    return proxyDelegate?.tableView?(tableView, nextTypeSelectMatchFromRow: startRow, toRow: endRow, forString: searchString) ?? -1
//  }
//
//  @objc public func tableView(tableView: NSTableView, shouldTypeSelectForEvent event: NSEvent, withCurrentSearchString searchString: String?) -> Bool {
//    return proxyDelegate?.tableView?(tableView, shouldTypeSelectForEvent: event, withCurrentSearchString: searchString) ?? tableView.allowsTypeSelect
//  }
//
//  @objc public func tableView(tableView: NSTableView, isGroupRow row: Int) -> Bool {
//    return proxyDelegate?.tableView?(tableView, isGroupRow: row) ?? false
//  }
//
//  @objc public func tableView(tableView: NSTableView, sizeToFitWidthOfColumn column: Int) -> CGFloat {
//    return proxyDelegate?.tableView?(tableView, sizeToFitWidthOfColumn: column) ?? NSViewNoIntrinsicMetric
//  }
//
//  @objc public func tableView(tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
//    return proxyDelegate?.tableView?(tableView, shouldReorderColumn: columnIndex, toColumn: newColumnIndex) ?? false
//  }
//
//  @objc public func tableView(tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableRowActionEdge) -> [NSTableViewRowAction] {
//    return proxyDelegate?.tableView?(tableView, rowActionsForRow: row, edge: edge) ?? []
//  }
//
//  @objc public func tableViewSelectionDidChange(notification: NSNotification) {
//    proxyDelegate?.tableViewSelectionDidChange?(notification)
//  }
//
//  @objc public func tableViewColumnDidMove(notification: NSNotification) {
//    proxyDelegate?.tableViewColumnDidMove?(notification)
//  }
//
//  @objc public func tableViewColumnDidResize(notification: NSNotification) {
//    proxyDelegate?.tableViewColumnDidResize?(notification)
//  }
//
//  @objc public func tableViewSelectionIsChanging(notification: NSNotification) {
//    proxyDelegate?.tableViewSelectionIsChanging?(notification)
//  }
//  
//}

