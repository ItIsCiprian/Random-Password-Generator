import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptor = CLKComplicationDescriptor(
            identifier: "cipher_generator",
            displayName: "Cipher Generator",
            supportedFamilies: CLKComplicationFamily.allCases
        )
        handler([descriptor])
    }

    func handleSharedComplicationDescriptors(_ descriptors: [CLKComplicationDescriptor]) {}

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let count = HistoryManager.shared.entries.count
        let template = template(for: complication, entryCount: count)
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }

    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        handler(nil)
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        handler(nil)
    }

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = template(for: complication, entryCount: 12)
        handler(template)
    }

    private func template(for complication: CLKComplication, entryCount: Int) -> CLKComplicationTemplate {
        let countText = "\(entryCount)"
        let label = entryCount == 1 ? "password" : "passwords"

        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKTextProvider(format: countText)
            template.line2TextProvider = CLKTextProvider(format: label)
            return template

        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKTextProvider(format: "Cipher")
            template.body1TextProvider = CLKTextProvider(format: "\(entryCount) \(label) saved")
            template.body2TextProvider = CLKTextProvider(format: "Tap to generate")
            return template

        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKTextProvider(format: countText)
            template.imageProvider = CLKImageProvider(
                onePieceImage: UIImage(systemName: "key.fill") ?? UIImage()
            )
            return template

        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKTextProvider(format: countText)
            template.imageProvider = CLKImageProvider(
                onePieceImage: UIImage(systemName: "key.fill") ?? UIImage()
            )
            return template

        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKTextProvider(format: "Cipher: \(entryCount) \(label)")
            template.imageProvider = CLKImageProvider(
                onePieceImage: UIImage(systemName: "key.fill") ?? UIImage()
            )
            return template

        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallStackText()
            template.line1TextProvider = CLKTextProvider(format: countText)
            template.line2TextProvider = CLKTextProvider(format: label)
            return template

        case .extraLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKTextProvider(format: "Cipher")
            template.body1TextProvider = CLKTextProvider(format: "\(entryCount) \(label)")
            template.body2TextProvider = CLKTextProvider(format: "Tap to generate")
            return template

        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerCircularImage()
            template.imageProvider = CLKFullColorImageProvider(
                fullColorImage: UIImage(systemName: "lock.fill")?.withTintColor(.purple) ?? UIImage()
            )
            return template

        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = CLKFullColorImageProvider(
                fullColorImage: UIImage(systemName: "key.fill")?.withTintColor(.purple) ?? UIImage()
            )
            return template

        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = CLKFullColorImageProvider(
                fullColorImage: UIImage(systemName: "key.fill")?.withTintColor(.purple) ?? UIImage()
            )
            return template

        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKTextProvider(format: "Cipher Generator")
            template.body1TextProvider = CLKTextProvider(format: "\(entryCount) \(label) saved")
            template.body2TextProvider = CLKTextProvider(format: "Tap to generate new")
            return template

        case .graphicExtraLarge:
            let template = CLKComplicationTemplateGraphicRectangularStandardBody()
            template.headerTextProvider = CLKTextProvider(format: "Cipher Generator")
            template.body1TextProvider = CLKTextProvider(format: "\(entryCount) \(label) saved")
            template.body2TextProvider = CLKTextProvider(format: "Tap to generate new")
            return template

        @unknown default:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKTextProvider(format: countText)
            template.line2TextProvider = CLKTextProvider(format: label)
            return template
        }
    }
}
