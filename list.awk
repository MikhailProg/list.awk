#!/usr/bin/awk -f

function assert(cond, emsg)
{
    if (!cond) {
        print "error:", emsg >> "/dev/stderr"
        exit 42
    }
}

function list_new(list)
{
    list_del(list)
    # Head is referencing itself.
    list[0, "next"] = 0
    list[0, "prev"] = 0
    list[0, "val"] = "n/a"
}

function list_del(list)
{
    delete list
    list["#"] = 0
}

function list_insert(list, prev, val,       node)
{
    # Insert new node after specified node (prev)
    node = ++list["#"]

    # Node allocaton.
    list[node, "val"] = val

    # C code to translate to awk:
    #
    # prev->next->prev = node;
    # node->next = prev->next;
    # node->prev = prev;
    # prev->next = node;

    list[list[prev, "next"], "prev"] = node
    list[node, "next"] = list[prev, "next"]
    list[node, "prev"] = prev
    list[prev, "next"] = node
}

function list_remove(list, node)
{
    assert(node != 0, "can't remove head")
    # C code to translate to awk:
    #
    # node->prev->next = node->next;
    # node->next->prev = node->prev;

    list[list[node, "prev"], "next"] = list[node, "next"]
    list[list[node, "next"], "prev"] = list[node, "prev"]
}

function list_empty(list)
{
    return list[0, "next"] == 0
}

function list_first(list)
{
    return list[0, "next"]
}

function list_last(list)
{
    return list[0, "prev"]
}

function list_next(list, node)
{
    return list[node, "next"]
}

function list_prev(list, node)
{
    return list[node, "prev"]
}

function list_print(list,       node)
{
    for (node = list_first(list); node; node = list_next(list, node))
        print list[node, "val"]
}

function list_find(list, val,       node)
{
    for (node = list_first(list); node; node = list_next(list, node))
        if (list[node, "val"] == val)
            return node

    return 0
}

function list_to_array(list, arr,       i, node)
{
    i = 0

    for (node = list_first(list); node; node = list_next(list, node))
        arr[i++] = list[node, "val"]

    return i
}

function list_prepend(list, val)
{
    # 0 is a head node
    list_insert(list, 0, val)
}

function list_append(list, val)
{
    list_insert(list, list_last(list), val)
}

function TEST(cond, txt,    t)
{
    printf "%-40s: %s\n", txt, (cond ? "\033[32mPASS\033[0m" : "\033[31mFAIL\033[0m")
}

BEGIN {
    list_new(list)
    TEST(list_empty(list), "Check list is empty")
    TEST(list_first(list) == 0, "Check first (empty)")
    TEST(list_last(list) == 0, "Check last (empty)")
    list_del(list)

    list_new(list)
    list_prepend(list, 10)
    TEST(!list_empty(list), "Check list is not empty (prepend)")
    fst = list_first(list)
    TEST(list[fst, "val"] == 10, "Check first (prepend)")
    lst = list_last(list)
    TEST(list[lst, "val"] == 10, "Check last (prepend)")
    list_del(list)

    list_new(list)
    list_append(list, 20)
    TEST(!list_empty(list), "Check list is not empty (append)")
    fst = list_first(list)
    TEST(list[fst, "val"] == 20, "Check first (append)")
    lst = list_last(list)
    TEST(list[lst, "val"] == 20, "Check last (append)")
    list_del(list)

    list_new(list)
    list_append(list, 20)
    TEST(list_find(list, 20), "Check find single entry")
    list_del(list)

    list_new(list)
    list_append(list, 20)
    list_append(list, 30)
    list_append(list, 40)
    node = list_find(list, 30)
    TEST(node, "Check find several entries")
    node = list_remove(list, node)
    node = list_find(list, 30)
    TEST(!node, "Check node is not found after remove")
    list_del(list)

    list_new(list)
    for (i = 0; i < 10; i++)
        list_append(list, 42 + i)

    n = list_to_array(list, arr)
    TEST(n == 10, "Check list size == array size")

    for (i = 0; i < 10; i++)
        TEST(arr[i] == 42 + i, "Check array[" i "] to list values " arr[i] " == " 42 + i)
    list_del(list)

    list_new(list)
    for (i = 0; i < 10; i++) {
        list_append(list, 42 + i)
        list_prepend(list, 42 + i)
    }

    fst = list_first(list)
    lst = list_last(list)
    n = 0

    while (fst && lst) {
        TEST(list[fst, "val"] == list[lst, "val"], "Check mirrored list "  list[fst, "val"] " == " list[lst, "val"])
        fst = list_next(list, fst)
        lst = list_prev(list, lst)
        ++n
    }

    TEST(n == 2 * 10, "Check mirrored list size")
    list_del(list)
}

