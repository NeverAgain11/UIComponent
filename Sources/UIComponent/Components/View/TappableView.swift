//  Created by Luke Zhao on 6/8/21.

import UIKit
import BaseToolbox

public struct TappableViewConfiguration {
    public static var `default` = TappableViewConfiguration(onHighlightChanged: nil, didTap: nil)

    // place to apply highlight state or animation to the TappableView
    public var onHighlightChanged: ((TappableView, Bool) -> Void)?

    // hook before the actual onTap is called
    public var didTap: ((TappableView) -> Void)?
    
    public init(onHighlightChanged: ((TappableView, Bool) -> Void)? = nil, didTap: ((TappableView) -> Void)? = nil) {
        self.onHighlightChanged = onHighlightChanged
        self.didTap = didTap
    }
}

open class TappableView: ComponentView {
    public var configuration: TappableViewConfiguration?

    public private(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
    public private(set) lazy var doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap)).then {
        $0.numberOfTapsRequired = 2
    }
    
    public private(set) lazy var longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
    
    private var _contextMenuInteraction: Any? = nil
    @available(iOS 13.4, *)
    fileprivate var contextMenuInteraction: UIContextMenuInteraction {
        if _contextMenuInteraction == nil {
            _contextMenuInteraction = UIContextMenuInteraction(delegate: self)
        }
        return _contextMenuInteraction as! UIContextMenuInteraction
    }
    
    public var previewBackgroundColor: UIColor?
    public var onTap: ((TappableView) -> Void)? {
        didSet {
            if onTap != nil {
                addGestureRecognizer(tapGestureRecognizer)
            } else {
                removeGestureRecognizer(tapGestureRecognizer)
            }
        }
    }

    public var onLongPress: ((TappableView, UILongPressGestureRecognizer) -> Void)? {
        didSet {
            if onLongPress != nil {
                addGestureRecognizer(longPressGestureRecognizer)
            } else {
                removeGestureRecognizer(longPressGestureRecognizer)
            }
        }
    }

    public var onDoubleTap: ((TappableView) -> Void)? {
        didSet {
            if onDoubleTap != nil {
                addGestureRecognizer(doubleTapGestureRecognizer)
            } else {
                removeGestureRecognizer(doubleTapGestureRecognizer)
            }
        }
    }

    private var dropInteraction: UIDropInteraction?
    public weak var dropDelegate: UIDropInteractionDelegate? {
        didSet {
            guard dropDelegate !== oldValue else { return }
            if let dropDelegate {
                dropInteraction = UIDropInteraction(delegate: dropDelegate)
                addInteraction(dropInteraction!)
            } else {
                if let dropInteraction {
                    removeInteraction(dropInteraction)
                }
            }
        }
    }

    private var _previewProvider: (() -> UIViewController?)?
    
    @available(iOS 13.4, *)
    public var previewProvider: (() -> UIViewController?)? {
        get {
            _previewProvider
        }
        set {
            if _previewProvider != nil || contextMenuProvider != nil {
                addInteraction(contextMenuInteraction)
            } else {
                removeInteraction(contextMenuInteraction)
            }
        }
    }

    private var _onCommitPreview: Any?
    
    @available(iOS 13.4, *)
    public var onCommitPreview: ((UIContextMenuInteractionCommitAnimating) -> Void)? {
        get { _onCommitPreview as? ((UIContextMenuInteractionCommitAnimating) -> Void) }
        set { _onCommitPreview = newValue }
    }
    
    private var _contextMenuProvider: Any?
    
    @available(iOS 13.4, *)
    public var contextMenuProvider: ((TappableView) -> UIMenu?)? {
        get { _contextMenuProvider as? ((TappableView) -> UIMenu?) }
        set {
            _contextMenuProvider = newValue
            if previewProvider != nil || _contextMenuProvider != nil {
                addInteraction(contextMenuInteraction)
            } else {
                removeInteraction(contextMenuInteraction)
            }
        }
    }

    private var _pointerStyleProvider: Any?
    
    @available(iOS 13.4, *)
    public var pointerStyleProvider: (() -> UIPointerStyle?)? {
        get { _pointerStyleProvider as? () -> UIPointerStyle? }
        set { _pointerStyleProvider = newValue }
    }

    open var isHighlighted: Bool = false {
        didSet {
            guard isHighlighted != oldValue else { return }
            let config = configuration ?? TappableViewConfiguration.default
            config.onHighlightChanged?(self, isHighlighted)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityTraits = .button
        if #available(iOS 13.4, *) {
            addInteraction(UIPointerInteraction(delegate: self))
        }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
    }

    @objc open func didTap() {
        let config = configuration ?? TappableViewConfiguration.default
        config.didTap?(self)
        onTap?(self)
    }

    @objc open func didDoubleTap() {
        onDoubleTap?(self)
    }

    @objc open func didLongPress() {
        onLongPress?(self, longPressGestureRecognizer)
    }
}

@available(iOS 13.4, *)
extension TappableView: UIPointerInteractionDelegate {
    public func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        if let pointerStyleProvider {
            return pointerStyleProvider()
        } else {
            return UIPointerStyle(effect: .automatic(UITargetedPreview(view: self)), shape: nil)
        }
    }
}

@available(iOS 13.4, *)
extension TappableView: UIContextMenuInteractionDelegate {
    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        if let previewProvider {
            return UIContextMenuConfiguration(identifier: nil) {
                previewProvider()
            } actionProvider: { [weak self] _ in
                guard let self else { return nil }
                return self.contextMenuProvider?(self)
            }
        } else {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
                guard let self else { return nil }
                return self.contextMenuProvider?(self)
            }
        }
    }

    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction, previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration)
        -> UITargetedPreview?
    {
        if let previewBackgroundColor {
            let param = UIPreviewParameters()
            param.backgroundColor = previewBackgroundColor
            return UITargetedPreview(view: self, parameters: param)
        }
        return nil
    }

    public func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating
    ) {
        if let onCommitPreview {
            onCommitPreview(animator)
        } else {
            animator.addAnimations {
                self.onTap?(self)
            }
        }
    }
}

extension Component {
    public func tappableView(
        configuration: TappableViewConfiguration? = nil,
        _ onTap: @escaping (TappableView) -> Void
    ) -> ViewUpdateComponent<ComponentViewComponent<TappableView>> {
        ComponentViewComponent<TappableView>(component: self)
            .update {
                $0.onTap = onTap
                $0.configuration = configuration
            }
    }
    public func tappableView(
        configuration: TappableViewConfiguration? = nil,
        _ onTap: @escaping () -> Void
    ) -> ViewUpdateComponent<ComponentViewComponent<TappableView>> {
        tappableView(configuration: configuration) { _ in
            onTap()
        }
    }
}
