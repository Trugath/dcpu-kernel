

; Let's reserve three regions.
; set X, 5
; jsr heapalloc
; set [ptr_a], A

; set X, 6
; jsr heapalloc
; set [ptr_b], A

; set X, 7
; jsr heapalloc
; set [ptr_c], A

; We free the middle one.
; set A, [ptr_b]
; jsr heapfree

; We allocate a smaller region, the system will put it at the beginning of the
; new freed region.
; set X, 3
; jsr heapalloc
; set [ptr_b], A

; Free ptr_c, so that we have 3 free regions at the end: the small caused by
; allocating a smaller ptr_b, the one left by ptr_c, and the rest of the heap.
; set A, [ptr_c]
; jsr heapfree

; Consolidate these three regions into one.
; jsr heapmergefree

; :ptr_a DAT 0
; :ptr_b DAT 0
; :ptr_c DAT 0

; The library.
;=============

;==========
; heapsetup
;==========
; Input parameters:
;     X: Maximum allocatable space.
:heapsetup
    set PUSH, A
    ; The free regions list points to the single free region.
    set A, heapfirst
    add A, 1 ; The first region starts just after heapfirst.
    set [heapfirst], A
    ; Allocate all the memory inside one single free region.
    set [A], X ; Size of the data-zone.
    add A, 1   ; Move into the data-zone.
    set [A], 0xffff ; End of list: there is only one region.
    set A, POP
    set PC, POP


;==========
; heapfree
;==========
; Input parameters:
;     A: the pointer to free, given by alloc.
; Output parameters:
;     None.
; Note that A may be modified.  You're not planning to reuse a freed pointer
; anyway, are you?
:heapfree
    ife [heapfirst], 0xffff ; Out of memory?
        set PC, heapfree_nomem ; This region becomes the only free region.
    ; Find where to insert the current region in the free regions list.
    set PUSH, B
    set PUSH, C
    ;
    sub A, 1 ; The region begins 1 word before, with the header.
    set B, 0 ; B: The free region before the current region.
    set C, [heapfirst] ; C: The free region after the current region.
:heapfree_loop_start
    ifg C, A
        set PC, heapfree_loop_end ; Found the regions before and after A.
    set B, C ; Keep searching, going to the next free region.
    add C, 1 ; The second word of a free region is the address
    set C, [C] ; of the next free region.
    set PC, heapfree_loop_start
:heapfree_loop_end
    ; We found where to insert.
    ; Make the previous free region point to the current region.
    ife B, 0
        set PC, heapfree_noprev ; There is no previous free region.
    add B, 1 ; Second word is the pointer to the next region.
    set [B], A ; Set it to the current region.
    set PC, heapfree_noprev_end
:heapfree_noprev
    set [heapfirst], A ; Set the head of the list to the current region.
:heapfree_noprev_end
    ; Make the current region point to the next free region.
    add A, 1 ; Second word is the pointer to the next region.
    set [A], C ; Works even if C is 0xffff, marking 'no more regions'.
    ;
    set C, POP
    set B, POP
    set PC, POP
:heapfree_nomem
    ; We're out of memory, so the region we're freeing becomes the only free
    ; region.
    set [A], 0xffff ; Next free region is invalid, because there is none.
    sub A, 1
    set [heapfirst], A ; First free region is current region.
    set PC, POP

;=============
; heapreserve
; FOR INTERNAL USE ONLY, NOT PART OF THE API.
;=============
; Input parameters:
;     A: the region in which to allocate.
;     B: the previous free region.
;        If there is no previous free region, then heapfirst-1.
;     X: the requested size to allocate.
:heapreserve
    ; Y contains the free space left in the region after allocation.
    set PUSH, Y
    set Y, [A] ; First word contains the size of the region.
    sub Y, X ; From which we remove the requested size.
    ; Enough free space left to create a new free region?
    ifg Y, 1; Free region needs 2 words for the header.
        set PC, heapreserve_split
    ; There is not enough free space in the region to split, so we reserve the
    ; full region.  That means, remove the current region from the free region
    ; list.  To do so, make the next of the previous point to the next of the
    ; current.
    add B, 1 ; Next of the previous.
    add A, 1 ; Next of the current.
    set [B], [A] ; Make the free region list skip the current region.
    sub A, 1 ; Restore the registers A and B.
    sub B, 1
    set Y, POP
    set PC, POP
:heapreserve_split
    ; We split the current region in two, reserving the first part, and
    ; making the second part free.
    set [A], X ; Set the size of the current region.
    ; Create the new free region.
    set PUSH, C
    set C, A
    add C, X
    add C, 1 ; Here is the beginning of the free region.
    sub Y, 1 ; Don't count the header in the size.
    set [C], Y ; Here is its allocatable size, which excludes the header.
    ; Make the previous free region point to the new free region.
    add B, 1 ; Works even if no previous because heapfirst-1.
    set [B], C
    sub B, 1 ; Restore B because we just messed it up.
    ; And make the new free region point to the next free region.
    add C, 1 ; Next of the new.
    add A, 1 ; Next of the current.
    set [C], [A]
    sub A, 1
    set C, POP
    ;
    set Y, POP
    set PC, POP

;==========
; heapfind
; FOR INTERNAL USE ONLY, NOT PART OF THE API.
;==========
; Input parameters:
;     X: the requested size to allocate.
; Output parameters:
;     A: the region to allocate, or 0 if can't find any.
;     B: the free region preceeding the region to allocate, or heapfirst-1
;        if none.
:heapfind
    sub X, 1 ; Because IFG is a strict inequality, see later.
    set B, 0
    set A, [heapfirst]
:heapfind_loop
    ife A, 0xffff ; Out of memory?
        set PC, heapfind_nomem
    ifg [A], X ; region is big enough?
        set PC, heapfind_found
    set B, A
    add A, 1
    set A, [A]
    set PC, heapfind_loop
:heapfind_nomem
    set A, 0 ; Never a valid address, so means "out of memory".
:heapfind_found
    add X, 1 ; Restore X.
    set PC, POP

;===========
; heapalloc
;===========
; Input parameter:
;     X: the requested size to allocate.
; Output parameter:
;     A: Pointer to the allocated region, or 0 if couldn't allocate.
:heapalloc
    set PUSH, B
    jsr heapfind
    ife A, 0 ; Out of memory.
        set PC, heapalloc_end
    ; Here, some trick to avoid a couple of 'if' and labels in heapreserve.
    ; When there is no free region before the region to allocate, then we fake
    ; one.  heapreserve wants the previous region to point to the next region,
    ; in order to remove the allocated region from the free regions list.
    ; When there is no previous region, then we make reserve write to heapfirst
    ; instead, which has the effect of making the next region the first.
    ifn B, 0
        set PC, heapalloc_reserve
    set B, heapfirst
    sub B, 1
:heapalloc_reserve
    jsr heapreserve
    add A, 1 ; Give the user a handle to the data, not the header.
:heapalloc_end
    set B, POP
    set PC, POP

;===============
; heapmergefree
;===============
:heapmergefree
    set PUSH, A
    set PUSH, B
    set PUSH, C
    set A, [heapfirst]
    ife A, 0xffff
        set PC, heapmergefree_end
:heapmergefree_loop
    ; A is the current free region.
    ; B is the next free region.
    ; If B is just after A, then they must be merged.
    set B, A
    add B, 1   ; This word contains the address of the next region.
    set B, [B] ; Jump there.
    ; C is the end of the current region.
    set C, A ; Start at the current region.
    add C, [A] ; Add the size of the current region.
    add C, 1 ; Add 1 to have the beginning of the next region.
    ife B, C ; If next free region starts just after the current ends,
        set PC, heapmergefree_merge ; then they must be merged.
    ; Cannot merge A (any more), move to the next region.
    set A, B
    ife A, 0xffff ; Reached the last free region?
        set PC, heapmergefree_end ; Then we're done.
    set PC, heapmergefree_loop ; Continue merging.
:heapmergefree_merge
    ; Here we do the actual merging.
    ; Add the sizes.
    add [A], [B]
    add [A], 1
    ; Set the next of the current to the next of the next.
    add A, 1
    add B, 1
    set [A], [B]
    sub A, 1 ; Restore A, but no need to restore B.
    set PC, heapmergefree_loop ; Maybe the new bigger A can be merged further?
:heapmergefree_end
    set C, POP
    set B, POP
    set A, POP
    set PC, POP
