import UIKit

@IBDesignable
public class NibDesignable: UIView {
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }
    
    // MARK: - NSCoding
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }
    
    // MARK: - Nib loading
    
    /**
     Called in init(frame:) and init(aDecoder:) to load the nib and add it as a subview.
     */
    private func setupNib() {
        backgroundColor = .clear
        let view = self.loadNib()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(view)
    }
    
    /**
     Called to load the nib in setupNib().
     
     :returns: UIView instance loaded from a nib file.
     */
    public func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        return bundle.loadNibNamed(self.nibName(), owner: self, options: nil)![0] as! UIView
    }
    
    /**
     Called in the default implementation of loadNib(). Default is class name.
     
     :returns: Name of a single view nib file.
     */
    public func nibName() -> String {
        return type(of: self).description().components(separatedBy: ".").last!
    }
}
