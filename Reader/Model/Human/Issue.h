#import "_Issue.h"

/*
 An issue in the state IssueStateAdded is added to the library but it is not ready to be displayed in the shelf. 
 An issue in the state IssueStateReadyForDisplayInShelf is ready to be displayed in the shelf / rack  - it has the previews and cover downloaded but not the documnt
 An issue in the state IssueStateReadyForReading is ready to be read - it has the document downloaded.
 */
typedef enum{
    IssueStateAdded,
    IssueStateReadyForDisplayInShelf,
    IssueStateReadyForReading
} IssueState;

@interface Issue : _Issue {}
// Custom logic goes here.
@end
