#import <Foundation/Foundation.h>
#import <PDFKit/PDFKit.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 4) return 2;
        PDFDocument *document = [[PDFDocument alloc] initWithURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]]];
        NSInteger start = atoi(argv[2]);
        NSInteger end = atoi(argv[3]);
        for (NSInteger i = start; i < end && i < document.pageCount; i++) {
            PDFPage *page = [document pageAtIndex:i];
            printf("### PDF PAGE %ld ###\n%s\n", (long)i + 1, page.string.UTF8String ?: "");
        }
    }
    return 0;
}
