//
// Created by Ubaldo Cotta on 4/1/17.
//

import Foundation
private let COMPARABLE = "<>=!".characters

public var TEMPLATE_DEFAULT_LOCALE = Locale.current

enum FilterAction {
    case ok, removeNode, returnNone, remainNodes, plus, replace
}
