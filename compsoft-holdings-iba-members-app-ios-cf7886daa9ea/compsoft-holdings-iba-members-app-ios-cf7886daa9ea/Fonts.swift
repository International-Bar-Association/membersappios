//
//  Fonts.swift
//  TWEKit
//
//  Created by Myles Eynon on 14/12/2017.
//  Copyright © 2017 Compsoft Ltd. All rights reserved.
//


import UIKit

public enum Fonts {
    
    public enum Weight {
        case regular
        case medium
        case semibold
        case bold

        
        private static let fontNameRegular = "AmericanTypewriter"
        private static let fontNameBold = "AmericanTypewriter-Bold"
        private static let fontNameMedium = "AmericanTypewriter-Semibold"
        private static let fontNameLight = "AmericanTypewriter-Light"
        private static let fontNameSemibold = "AmericanTypewriter-Semibold"
        
        public var weightValue: UIFont.Weight {
            switch self {
            case .regular:
                return UIFont.Weight.regular
            case .medium:
                return UIFont.Weight.medium
            case .semibold:
                return UIFont.Weight.semibold
            case .bold:
                return UIFont.Weight.bold
            }
        }
        
        public var fontName: String {
            switch self {
            case .regular:
                return Weight.fontNameRegular
            case .medium:
                return Weight.fontNameMedium
            case .semibold:
                return Weight.fontNameSemibold
            case .bold:
                return Weight.fontNameBold

            }
        }
    }
    
    /** Use the given font or use the system font as the base font*/
    private static let useSystemFont = true
    
    //TODO: Comment these with actual font size so we can see in quick help what they represent? 
   
    case tiny(Weight?)
    case extraSmallHalf(Weight?)
    case extraSmall(Weight?)
    case smallHalf(Weight?)
    case small(Weight?)
    case standard(Weight?)
    case regularHalf(Weight?)
    case regular(Weight?)
    case largeHalf(Weight?)
    case large(Weight?)
    case grandeHalf(Weight?)
    case grande(Weight?)

    ///32pt
    case superGrandePlusHalf(Weight?)
    case superGrandePlus(Weight?)
    case whooper(Weight?)
    


    private static let extraTinyHalfSize:CGFloat = 8.5
    private static let extraTinySize:CGFloat = 9
    private static let tinySize:CGFloat = 10
    private static let extraSmallHalfSize:CGFloat = 11
    private static let extraSmallSize:CGFloat = 12
    private static let smallHalfSize:CGFloat = 13
    private static let smallSize:CGFloat = 14
    private static let standardSize:CGFloat = 15
    private static let regularHalfSize:CGFloat = 16
    private static let regularSize:CGFloat = 17
    private static let largeHalfSize:CGFloat = 19
    private static let largeSize:CGFloat = 20
    private static let grandeHalfSize:CGFloat = 24
    private static let grandeSize:CGFloat = 26
    private static let superGrandePlusHalfSize:CGFloat = 26
    private static let superGrandePlusSize: CGFloat = 30
    private static let enormaySize: CGFloat = 40
    private static let whooperSize: CGFloat = 96
    
    private var size: CGFloat {
        
        var fontSize: CGFloat = Fonts.regularSize
        
        switch self {
        case .tiny:
            fontSize = Fonts.tinySize
        case .extraSmallHalf:
            fontSize = Fonts.extraSmallHalfSize
        case .extraSmall:
            fontSize = Fonts.extraSmallSize
        case .smallHalf:
            fontSize = Fonts.smallHalfSize
        case .small:
            fontSize = Fonts.smallSize
        case .standard:
            fontSize = Fonts.standardSize
        case .regularHalf:
            fontSize = Fonts.regularHalfSize
        case .regular:
            fontSize = Fonts.regularSize
        case .largeHalf:
            fontSize = Fonts.largeHalfSize
        case .large:
            fontSize = Fonts.largeSize
        case .grandeHalf:
            fontSize = Fonts.grandeHalfSize
        case .grande:
            fontSize = Fonts.grandeSize
        case .superGrandePlusHalf:
            fontSize = Fonts.superGrandePlusHalfSize
        case .superGrandePlus:
            fontSize = Fonts.superGrandePlusSize
        case .whooper:
            fontSize = Fonts.whooperSize
        }
        return fontSize
    }
    
    private var weightValue: Weight {
        switch self {
        case .tiny(let weight):
            return weight ?? .regular
        case .extraSmallHalf(let weight):
            return weight ?? .regular
        case .extraSmall(let weight):
            return weight ?? .regular
        case .smallHalf(let weight):
            return weight ?? .regular
        case .small(let weight):
            return weight ?? .regular
        case .standard(let weight):
            return weight ?? .regular
        case .regularHalf(let weight):
            return weight ?? .regular
        case .regular(let weight):
            return weight ?? .regular
        case .largeHalf(let weight):
            return weight ?? .regular
        case .large(let weight):
            return weight ?? .regular
        case .grandeHalf(let weight):
            return weight ?? .regular
        case .grande(let weight):
            return weight ?? .regular
        case .whooper(let weight):
            return weight ?? .regular
        case .superGrandePlusHalf(let weight):
            return weight ?? .regular
        case .superGrandePlus(let weight):
            return weight ?? .regular
        }
    }
    
    public var font: UIFont {
        switch self {
        case .tiny(.none):
            return Fonts.tinyRegular
            
        case .tiny(let weight?):
            switch weight {
            case .regular: return Fonts.tinyRegular
            case .medium: return Fonts.tinyMedium
            case .semibold: return Fonts.tinySemiBold
            case .bold: return Fonts.tinyBold
            }
            
        case .extraSmallHalf(.none):
            return Fonts.extraSmallHalfRegular
        case .extraSmallHalf(let weight?):
            switch weight {
            case .regular: return Fonts.extraSmallHalfRegular
            case .medium: return Fonts.extraSmallHalfMedium
            case .semibold: return Fonts.extraSmallHalfSemiBold
            case .bold: return Fonts.extraSmallHalfBold
            }
        case .extraSmall(.none):
            return Fonts.extraSmallRegular
        case .extraSmall(let weight?):
            switch weight {
            case .regular: return Fonts.extraSmallRegular
            case .medium: return Fonts.extraSmallMedium
            case .semibold: return Fonts.extraSmallSemiBold
            case .bold: return Fonts.extraSmallBold
            }
        case .smallHalf(.none):
            return Fonts.smallHalfRegular
        case .smallHalf(let weight?):
            switch weight {
            case .regular: return Fonts.smallHalfRegular
            case .medium: return Fonts.smallHalfMedium
            case .semibold: return Fonts.smallHalfSemiBold
            case .bold: return Fonts.smallHalfBold
            }
        case .small(.none):
            return Fonts.smallRegular
        case .small(let weight?):
            switch weight {
            case .regular: return Fonts.smallRegular
            case .medium: return Fonts.smallMedium
            case .semibold: return Fonts.smallSemiBold
            case .bold: return Fonts.smallBold
            }
        case .standard(.none):
            return Fonts.standardRegular
        case .standard(let weight?):
            switch weight {
            case .regular: return Fonts.standardRegular
            case .medium: return Fonts.standardMedium
            case .semibold: return Fonts.standardSemiBold
            case .bold: return Fonts.standardBold
            }
        case .regularHalf(.none):
            return Fonts.regularHalfRegular
        case .regularHalf(let weight?):
            switch weight {
            case .regular: return Fonts.regularHalfRegular
            case .medium: return Fonts.regularHalfMedium
            case .semibold: return Fonts.regularHalfSemiBold
            case .bold: return Fonts.regularHalfBold
            }
            
        case .regular(.none):
            return Fonts.regularRegular
        case .regular(let weight?):
            switch weight {
            case .regular: return Fonts.regularRegular
            case .medium: return Fonts.regularMedium
            case .semibold: return Fonts.regularSemiBold
            case .bold: return Fonts.regularBold
            }
        case .largeHalf(.none):
            return Fonts.largeHalfRegular
        case .largeHalf(let weight?):
            switch weight {
            case .regular: return Fonts.largeHalfRegular
            case .medium: return Fonts.largeHalfMedium
            case .semibold: return Fonts.largeHalfSemiBold
            case .bold: return Fonts.largeHalfBold
            }
        case .large(.none):
            return Fonts.largeRegular
        case .large(let weight?):
            switch weight {
            case .regular: return Fonts.largeRegular
            case .medium: return Fonts.largeMedium
            case .semibold: return Fonts.largeSemiBold
            case .bold: return Fonts.largeBold
            }
        case .grandeHalf(.none):
            return Fonts.grandeHalfRegular
        case .grandeHalf(let weight?):
            switch weight {
            case .regular: return Fonts.grandeHalfRegular
            case .medium: return Fonts.grandeHalfMedium
            case .semibold: return Fonts.grandeHalfSemiBold
            case .bold: return Fonts.grandeHalfBold
            }
        case .grande(.none):
            return Fonts.grandeRegular
        case .grande(let weight?):
            switch weight {
            case .regular: return Fonts.grandeRegular
            case .medium: return Fonts.grandeMedium
            case .semibold: return Fonts.grandeSemiBold
            case .bold: return Fonts.grandeBold
            }
        case .superGrandePlusHalf(.none):
            return Fonts.superGrandePlusHalfRegular
        case .superGrandePlusHalf(let weight?):
            switch weight {
            case .regular: return Fonts.superGrandePlusHalfRegular
            case .medium: return Fonts.superGrandePlusHalfMedium
            case .semibold: return Fonts.superGrandePlusHalfSemiBold
            case .bold: return Fonts.superGrandePlusHalfBold
            }
        case .superGrandePlus(.none):
            return Fonts.superGrandePlusRegular
        case .superGrandePlus(let weight?):
            switch weight {
            case .regular: return Fonts.superGrandePlusRegular
            case .medium: return Fonts.superGrandePlusMedium
            case .semibold: return Fonts.superGrandePlusSemiBold
            case .bold: return Fonts.superGrandePlusBold
            }
        case .whooper(.none):
            return Fonts.whooperRegular
        case .whooper(let weight?):
            switch weight {
            case .regular: return Fonts.whooperRegular
            case .medium: return Fonts.whooperMedium
            case .semibold: return Fonts.whooperSemiBold
            case .bold: return Fonts.whooperBold
            }
        }
    }
    
    private static var tinyRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.tinySize, weight: UIFont.Weight.regular)
    }()
    private static var tinyMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.tinySize, weight: UIFont.Weight.medium)
    }()
    private static var tinySemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.tinySize, weight: UIFont.Weight.semibold)
    }()
    private static var tinyBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.tinySize, weight: UIFont.Weight.bold)
    }()
    
    private static var extraSmallHalfRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.extraSmallHalfSize, weight: UIFont.Weight.regular)
    }()
    private static var extraSmallHalfMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.extraSmallHalfSize, weight: UIFont.Weight.medium)
    }()
    private static var extraSmallHalfSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.extraSmallHalfSize, weight: UIFont.Weight.semibold)
    }()
    private static var extraSmallHalfBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.extraSmallHalfSize, weight: UIFont.Weight.bold)
    }()
    
    private static var extraSmallRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.extraSmallSize, weight: UIFont.Weight.regular)
    }()
    private static var extraSmallMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.extraSmallSize, weight: UIFont.Weight.medium)
    }()
    private static var extraSmallSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.extraSmallSize, weight: UIFont.Weight.semibold)
    }()
    private static var extraSmallBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.extraSmallSize, weight: UIFont.Weight.bold)
    }()
    
    private static var smallHalfRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.smallHalfSize, weight: UIFont.Weight.regular)
    }()
    private static var smallHalfMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.smallHalfSize, weight: UIFont.Weight.medium)
    }()
    private static var smallHalfSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.smallHalfSize, weight: UIFont.Weight.semibold)
    }()
    private static var smallHalfBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.smallHalfSize, weight: UIFont.Weight.bold)
    }()
    
    private static var smallRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.smallSize, weight: UIFont.Weight.regular)
    }()
    private static var smallMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.smallSize, weight: UIFont.Weight.medium)
    }()
    private static var smallSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.smallSize, weight: UIFont.Weight.semibold)
    }()
    private static var smallBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.smallSize, weight: UIFont.Weight.bold)
    }()
    
    private static var standardRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.standardSize, weight: UIFont.Weight.regular)
    }()
    private static var standardMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.standardSize, weight: UIFont.Weight.medium)
    }()
    private static var standardSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.standardSize, weight: UIFont.Weight.semibold)
    }()
    private static var standardBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.standardSize, weight: UIFont.Weight.bold)
    }()
    
    private static var regularHalfRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.regularHalfSize, weight: UIFont.Weight.regular)
    }()
    private static var regularHalfMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.regularHalfSize, weight: UIFont.Weight.medium)
    }()
    private static var regularHalfSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.regularHalfSize, weight: UIFont.Weight.semibold)
    }()
    private static var regularHalfBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.regularHalfSize, weight: UIFont.Weight.bold)
    }()
    
    private static var regularRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.regularSize, weight: UIFont.Weight.regular)
    }()
    private static var regularMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.regularSize, weight: UIFont.Weight.medium)
    }()
    private static var regularSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.regularSize, weight: UIFont.Weight.semibold)
    }()
    private static var regularBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.regularSize, weight: UIFont.Weight.bold)
    }()
    
    private static var largeHalfRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.largeHalfSize, weight: UIFont.Weight.regular)
    }()
    private static var largeHalfMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.largeHalfSize, weight: UIFont.Weight.medium)
    }()
    private static var largeHalfSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.largeHalfSize, weight: UIFont.Weight.semibold)
    }()
    private static var largeHalfBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.largeHalfSize, weight: UIFont.Weight.bold)
    }()
    
    private static var largeRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.largeSize, weight: UIFont.Weight.regular)
    }()
    private static var largeMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.largeSize, weight: UIFont.Weight.medium)
    }()
    private static var largeSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.largeSize, weight: UIFont.Weight.semibold)
    }()
    private static var largeBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.largeSize, weight: UIFont.Weight.bold)
    }()
    
    private static var grandeHalfRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.grandeHalfSize, weight: UIFont.Weight.regular)
    }()
    private static var grandeHalfMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.grandeHalfSize, weight: UIFont.Weight.medium)
    }()
    private static var grandeHalfSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.grandeHalfSize, weight: UIFont.Weight.semibold)
    }()
    private static var grandeHalfBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.grandeHalfSize, weight: UIFont.Weight.bold)
    }()
    
    private static var grandeRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.grandeSize, weight: UIFont.Weight.regular)
    }()
    private static var grandeMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.grandeSize, weight: UIFont.Weight.medium)
    }()
    private static var grandeSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.grandeSize, weight: UIFont.Weight.semibold)
    }()
    private static var grandeBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.grandeSize, weight: UIFont.Weight.bold)
    }()
    
    private static var superGrandePlusHalfRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.superGrandePlusHalfSize, weight: UIFont.Weight.regular)
    }()
    private static var superGrandePlusHalfMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.superGrandePlusHalfSize, weight: UIFont.Weight.medium)
    }()
    private static var superGrandePlusHalfSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.superGrandePlusHalfSize, weight: UIFont.Weight.semibold)
    }()
    private static var superGrandePlusHalfBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.superGrandePlusHalfSize, weight: UIFont.Weight.bold)
    }()
    
    private static var superGrandePlusRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.superGrandePlusSize, weight: UIFont.Weight.regular)
    }()
    private static var superGrandePlusMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.superGrandePlusSize, weight: UIFont.Weight.medium)
    }()
    private static var superGrandePlusSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.superGrandePlusSize, weight: UIFont.Weight.semibold)
    }()
    private static var superGrandePlusBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.superGrandePlusSize, weight: UIFont.Weight.bold)
    }()
    
    private static var whooperRegular: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.whooperSize, weight: UIFont.Weight.regular)
    }()
    private static var whooperMedium: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.whooperSize, weight: UIFont.Weight.medium)
    }()
    private static var whooperSemiBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.whooperSize, weight: UIFont.Weight.semibold)
    }()
    private static var whooperBold: UIFont = {
        return UIFont.systemFont(ofSize: Fonts.whooperSize, weight: UIFont.Weight.bold)
    }()
}

