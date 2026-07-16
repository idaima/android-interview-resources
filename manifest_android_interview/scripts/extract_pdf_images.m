#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

typedef struct {
    NSInteger page;
    NSInteger depth;
    NSString *outputDirectory;
} ExtractionContext;

static void extractXObjects(const char *key, CGPDFObjectRef object, void *info);

static void extractResourceImages(
    CGPDFDictionaryRef resources,
    NSInteger page,
    NSInteger depth,
    NSString *outputDirectory
) {
    if (resources == NULL) return;
    CGPDFDictionaryRef xObjects = NULL;
    if (!CGPDFDictionaryGetDictionary(resources, "XObject", &xObjects)) return;
    ExtractionContext context = { page, depth, outputDirectory };
    CGPDFDictionaryApplyFunction(xObjects, extractXObjects, &context);
}

static void writeRawRgbPng(
    CFDataRef data,
    CGPDFInteger width,
    CGPDFInteger height,
    NSString *path
) {
    if (CFDataGetLength(data) != width * height * 3) return;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef image = CGImageCreate(
        width,
        height,
        8,
        24,
        width * 3,
        colorSpace,
        kCGImageAlphaNone | kCGBitmapByteOrderDefault,
        provider,
        NULL,
        false,
        kCGRenderingIntentDefault
    );
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(
        (__bridge CFURLRef)url,
        CFSTR("public.png"),
        1,
        NULL
    );
    if (destination != NULL) {
        CGImageDestinationAddImage(destination, image, NULL);
        CGImageDestinationFinalize(destination);
        CFRelease(destination);
    }
    CGImageRelease(image);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
}

static void extractXObjects(const char *key, CGPDFObjectRef object, void *info) {
    ExtractionContext *context = info;
    CGPDFStreamRef stream = NULL;
    if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeStream, &stream)) return;

    CGPDFDictionaryRef dictionary = CGPDFStreamGetDictionary(stream);
    const char *subtype = NULL;
    if (!CGPDFDictionaryGetName(dictionary, "Subtype", &subtype)) return;

    if (strcmp(subtype, "Image") == 0) {
        CGPDFInteger width = 0;
        CGPDFInteger height = 0;
        CGPDFDictionaryGetInteger(dictionary, "Width", &width);
        CGPDFDictionaryGetInteger(dictionary, "Height", &height);
        CGPDFDataFormat format = CGPDFDataFormatRaw;
        CFDataRef data = CGPDFStreamCopyData(stream, &format);
        NSString *name = [NSString stringWithUTF8String:key];
        NSString *path = [context->outputDirectory stringByAppendingPathComponent:
            [NSString stringWithFormat:@"page-%03ld-%@.png", (long)context->page, name]];
        if (data != NULL && format == CGPDFDataFormatRaw) {
            writeRawRgbPng(data, width, height, path);
        }
        if (data != NULL) CFRelease(data);
        return;
    }

    if (strcmp(subtype, "Form") == 0 && context->depth < 8) {
        CGPDFDictionaryRef resources = NULL;
        if (CGPDFDictionaryGetDictionary(dictionary, "Resources", &resources)) {
            extractResourceImages(resources, context->page, context->depth + 1, context->outputDirectory);
        }
    }
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc != 3) return 2;
        NSString *pdfPath = [NSString stringWithUTF8String:argv[1]];
        NSString *outputDirectory = [NSString stringWithUTF8String:argv[2]];
        [[NSFileManager defaultManager] createDirectoryAtPath:outputDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(
            (__bridge CFURLRef)[NSURL fileURLWithPath:pdfPath]
        );
        if (document == NULL) return 1;
        size_t pageCount = CGPDFDocumentGetNumberOfPages(document);
        for (size_t index = 1; index <= pageCount; index++) {
            CGPDFPageRef page = CGPDFDocumentGetPage(document, index);
            CGPDFDictionaryRef pageDictionary = CGPDFPageGetDictionary(page);
            CGPDFDictionaryRef resources = NULL;
            if (CGPDFDictionaryGetDictionary(pageDictionary, "Resources", &resources)) {
                extractResourceImages(resources, index, 0, outputDirectory);
            }
        }
        CGPDFDocumentRelease(document);
    }
    return 0;
}
