# Summary
1. INDEX Page
   * FSEG Header
2. INODE Page
   * INODE Entry
     * List Base Node
3. XDES Page
   * XDES Entry
     * List Node
4. Extent
   * Page

# Data Structure
## FSEG: File Segment

## FIL Header: File Header

## FIL Trailer: File Trailer

## FSP_HDR: File Space Header
containing FSP header structure, which tracks things like
* the size of the space
* lists of free, fragmented, and full extents

## XDES: Extent Descriptor

## Extent
* pages are grouped into blocks of 1 MiB

## IBUF_BITMAP
which is used for bookkeeping information related to insert buffering

## INODE

## Size
* One extent size                                 = 1 MB
* One page size                                   = 16 KB
* Total pages in one extent                       = 64 Pages
* Total XDES entries in one XDES page             = 256
* Total Extents could be covered in one XDES page = 256
* Total pages could be covered with one XDES Page = 16384

## Link
TableSpace and Page Structure
* https://blog.jcole.us/2013/01/03/the-basics-of-innodb-space-file-layout/

Page Management
* https://blog.jcole.us/2013/01/04/page-management-in-innodb-space-files/

Index Structure
* https://blog.jcole.us/2013/01/07/the-physical-structure-of-innodb-index-pages/

B+Tree Structure
* https://blog.jcole.us/2013/01/10/btree-index-structures-in-innodb/
* https://blog.jcole.us/2013/01/14/efficiently-traversing-innodb-btrees-with-the-page-directory/

Record Structure
* https://blog.jcole.us/2013/01/10/the-physical-structure-of-records-in-innodb/

UNDO
* https://blog.jcole.us/2014/04/16/the-basics-of-the-innodb-undo-logging-and-history-system/
